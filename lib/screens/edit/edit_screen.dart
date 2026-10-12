import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../data/seed_data.dart';
import '../../data/tag_definitions.dart';
import '../../models/ingredient.dart';
import '../../models/recipe.dart';
import '../../models/recipe_step.dart';
import '../../providers/custom_tag_providers.dart';
import '../../providers/recipe_providers.dart';
import '../../theme/app_colors.dart';
import '../../utils/recipe_graph.dart';
import '../../widgets/tag_chip.dart';
import '../../widgets/tag_selector_sheet.dart';
import 'widgets/image_picker_field.dart';
import 'widgets/ingredient_list_editor.dart';
import 'widgets/steps_list_editor.dart';

class EditScreen extends ConsumerStatefulWidget {
  final String recipeId;

  const EditScreen({super.key, required this.recipeId});

  @override
  ConsumerState<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends ConsumerState<EditScreen> {
  final _titleController = TextEditingController();
  String? _imagePath;
  String? _existingImagePath;
  Set<String> _selectedTagIds = {};
  List<Ingredient> _ingredients = [];
  List<RecipeStep> _steps = [];
  bool _saving = false;

  // Composite recipe state
  List<String> _componentOrder = [];
  List<String> _compositeStepOrder = [];
  // Controllers for own steps in composite mode (stepId → controller).
  Map<String, TextEditingController> _ownStepControllerMap = {};

  bool get _isNew => widget.recipeId == 'new';
  bool get _isComposite => _componentOrder.isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (!_isNew) {
      final recipe = ref
          .read(recipeListProvider)
          .cast<Recipe?>()
          .firstWhere((r) => r?.id == widget.recipeId, orElse: () => null);
      if (recipe != null) {
        _titleController.text = recipe.title;
        _imagePath = recipe.imagePath;
        _selectedTagIds = {...recipe.tagIds};
        _ingredients = List.from(recipe.ingredients);
        _steps = List.from(recipe.steps);
        _componentOrder = List.from(recipe.componentOrder);
        _compositeStepOrder = List.from(recipe.compositeStepOrder);
        if (recipe.isComposite) {
          _ownStepControllerMap = {
            for (final s in recipe.steps)
              s.id: TextEditingController(text: s.instruction),
          };
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (final c in _ownStepControllerMap.values) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Composite component management ────────────────────────────────────────

  void _reorderComponent(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _componentOrder.removeAt(oldIndex);
      _componentOrder.insert(newIndex, item);
    });
  }

  void _removeComponent(String recipeId) {
    final newOrder =
        List<String>.from(_componentOrder)..removeWhere((id) => id == recipeId);
    final stillHasLinked = newOrder.any((id) => id != 'self');
    if (!stillHasLinked) {
      // Revert to standalone mode — sync text before clearing controllers
      _syncOwnSteps();
      for (final c in _ownStepControllerMap.values) {
        c.dispose();
      }
      setState(() {
        _ownStepControllerMap = {};
        _componentOrder = [];
        _compositeStepOrder = [];
      });
    } else {
      // Remove this component's steps from compositeStepOrder
      final allRecipes = ref.read(recipeListProvider);
      final compRecipe = allRecipes
          .cast<Recipe?>()
          .firstWhere((r) => r?.id == recipeId, orElse: () => null);
      setState(() {
        if (compRecipe != null) {
          final stepIds = compRecipe.steps.map((s) => s.id).toSet();
          _compositeStepOrder = _compositeStepOrder
              .where((id) => !stepIds.contains(id))
              .toList();
        }
        _componentOrder = newOrder;
      });
    }
  }

  Future<void> _showAddComponentDialog(List<Recipe> allRecipes) async {
    final selfId = _isNew ? '' : widget.recipeId;
    final alreadyLinked = _componentOrder.where((id) => id != 'self').toSet();

    final available = allRecipes
        .where((r) => r.id != selfId)
        .where((r) => !alreadyLinked.contains(r.id))
        .where((r) => !wouldCreateCycle(selfId, r.id, allRecipes))
        .toList()
      ..sort((a, b) => a.title.compareTo(b.title));

    if (available.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No recipes available to link')),
      );
      return;
    }

    final selected = await showDialog<Recipe>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Add component recipe'),
        children: available
            .map((r) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(ctx, r),
                  child: Text(r.title),
                ))
            .toList(),
      ),
    );

    if (selected == null || !mounted) return;

    setState(() {
      if (_componentOrder.isEmpty) {
        // First component: initialise own step controllers from current _steps
        _ownStepControllerMap = {
          for (final s in _steps)
            s.id: TextEditingController(text: s.instruction),
        };
        _componentOrder = ['self', selected.id];
      } else {
        _componentOrder = [..._componentOrder, selected.id];
      }
    });
  }

  // ── Composite step management ─────────────────────────────────────────────

  /// Rebuilds [_steps] from [_ownStepControllerMap], preserving the current
  /// [_steps] ordering. Call before save or before re-entering standalone mode.
  void _syncOwnSteps() {
    final newSteps = <RecipeStep>[];
    for (int i = 0; i < _steps.length; i++) {
      final step = _steps[i];
      final controller = _ownStepControllerMap[step.id];
      if (controller != null && controller.text.trim().isNotEmpty) {
        newSteps.add(RecipeStep(
          id: step.id,
          order: i,
          instruction: controller.text.trim(),
        ));
      }
    }
    _steps = newSteps;
  }

  void _addOwnStep() {
    final newId = const Uuid().v4();
    _ownStepControllerMap[newId] = TextEditingController();
    setState(() {
      _steps = [
        ..._steps,
        RecipeStep(id: newId, order: _steps.length, instruction: ''),
      ];
      if (_compositeStepOrder.isNotEmpty) {
        _compositeStepOrder = [..._compositeStepOrder, newId];
      }
    });
  }

  void _deleteOwnStep(String stepId) {
    final controller = _ownStepControllerMap.remove(stepId);
    controller?.dispose();
    setState(() {
      _steps = _steps.where((s) => s.id != stepId).toList();
      _compositeStepOrder =
          _compositeStepOrder.where((id) => id != stepId).toList();
    });
  }

  void _reorderCompositeStep(
    int oldIndex,
    int newIndex,
    List<({RecipeStep step, String sourceRecipeId})> currentOrder,
    List<Recipe> allRecipes,
  ) {
    if (newIndex > oldIndex) newIndex--;
    final reordered = List.of(currentOrder);
    final moved = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, moved);
    final proposedOrder = reordered.map((e) => e.step.id).toList();

    final tempRecipe = Recipe(
      id: _isNew ? '' : widget.recipeId,
      title: '',
      tagIds: const [],
      ingredients: const [],
      steps: _steps,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      componentOrder: _componentOrder,
      compositeStepOrder: proposedOrder,
    );

    if (validateStepOrder(proposedOrder, tempRecipe, allRecipes)) {
      setState(() {
        _compositeStepOrder = proposedOrder;
        // Keep _steps order aligned with the composite own-step ordering
        // so block-fallback and future syncs stay consistent.
        final ownIds =
            proposedOrder.where((id) => _ownStepControllerMap.containsKey(id));
        final ownMap = {for (final s in _steps) s.id: s};
        final reorderedOwn = <RecipeStep>[];
        int order = 0;
        for (final id in ownIds) {
          final s = ownMap[id];
          if (s != null) {
            reorderedOwn.add(
                RecipeStep(id: s.id, order: order++, instruction: s.instruction));
          }
        }
        if (reorderedOwn.isNotEmpty) _steps = reorderedOwn;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Steps within a recipe must stay in order'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Color? _componentColorFor(String sourceRecipeId) {
    if (sourceRecipeId == 'self') return null;
    final linkedIds = _componentOrder.where((id) => id != 'self').toList();
    final idx = linkedIds.indexOf(sourceRecipeId);
    if (idx < 0) return null;
    return componentColors[idx % componentColors.length];
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (_isComposite) _syncOwnSteps();

    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a title')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final repo = ref.read(recipeRepositoryProvider);
      String? finalImagePath = _imagePath;

      if (_imagePath != null &&
          _imagePath != _existingImagePath &&
          !_imagePath!.contains('recipea_images')) {
        finalImagePath = await repo.saveImage(_imagePath!);
        if (_existingImagePath != null) {
          repo.deleteImageFile(_existingImagePath!);
        }
      }

      final now = DateTime.now();
      final recipe = _isNew
          ? Recipe(
              id: generateRecipeId(),
              title: title,
              imagePath: finalImagePath,
              tagIds: _selectedTagIds.toList(),
              ingredients: _ingredients,
              steps: _steps,
              createdAt: now,
              updatedAt: now,
              componentOrder: _componentOrder,
              compositeStepOrder: _compositeStepOrder,
            )
          : ref
              .read(recipeListProvider)
              .firstWhere((r) => r.id == widget.recipeId)
              .copyWith(
                title: title,
                imagePath: finalImagePath,
                tagIds: _selectedTagIds.toList(),
                ingredients: _ingredients,
                steps: _steps,
                updatedAt: now,
                componentOrder: _componentOrder,
                compositeStepOrder: _compositeStepOrder,
              );

      await ref.read(recipeListProvider.notifier).save(recipe);

      if (mounted) {
        if (_isNew) {
          context.go('/recipes/${recipe.id}');
        } else {
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final allTags = ref.watch(allTagsProvider);
    final allRecipes = ref.watch(recipeListProvider);
    final recipeMap = {for (final r in allRecipes) r.id: r};

    return PopScope(
      canPop: !_isNew,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _isNew) context.go('/recipes');
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            _isNew ? 'New Recipe' : 'Edit Recipe',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            if (_saving)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            else
              TextButton(
                onPressed: _save,
                child: Text(
                  _isNew ? 'Save' : 'Update',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo
              ImagePickerField(
                imagePath: _imagePath,
                onImagePicked: (path) => setState(() {
                  _existingImagePath ??= _imagePath;
                  _imagePath = path;
                }),
                onRemove: () => setState(() {
                  if (_imagePath == _existingImagePath) {
                    ref
                        .read(recipeRepositoryProvider)
                        .deleteImageFile(_imagePath!);
                  }
                  _imagePath = null;
                  _existingImagePath = null;
                }),
              ),
              const SizedBox(height: 20),
              // Title
              const _FieldLabel(text: 'Title'),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(hintText: 'Recipe name'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 24),
              // Components
              _buildComponentsSection(allRecipes, recipeMap),
              const SizedBox(height: 24),
              // Tags
              Row(
                children: [
                  const _FieldLabel(text: 'Tags'),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => showTagSelectorSheet(
                      context: context,
                      currentFilter: TagFilterState(included: _selectedTagIds),
                      onChanged: (f) =>
                          setState(() => _selectedTagIds = f.included),
                    ),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add tags'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_selectedTagIds.isEmpty)
                const Text(
                  'No tags selected',
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 14),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedTagIds
                      .map((id) => tagByIdAll(id, allTags))
                      .whereType<TagDefinition>()
                      .map((tag) => TagChip(
                            tag: tag,
                            isSelected: true,
                            showRemove: true,
                            onTap: () =>
                                setState(() => _selectedTagIds.remove(tag.id)),
                          ))
                      .toList(),
                ),
              // Read-only tags from linked component recipes
              if (_isComposite) ..._buildLinkedTagChips(allTags, recipeMap),
              const SizedBox(height: 24),
              // Ingredients
              const _FieldLabel(text: 'Ingredients'),
              const SizedBox(height: 12),
              IngredientListEditor(
                ingredients: _ingredients,
                onChanged: (list) => setState(() => _ingredients = list),
              ),
              const SizedBox(height: 24),
              // Steps
              const _FieldLabel(text: 'Steps'),
              const SizedBox(height: 12),
              _isComposite
                  ? _buildCompositeStepsSection(allRecipes, recipeMap)
                  : StepsListEditor(
                      steps: _steps,
                      onChanged: (list) => setState(() => _steps = list),
                    ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ── Linked component tag chips (read-only) ────────────────────────────────

  List<Widget> _buildLinkedTagChips(
      List<TagDefinition> allTags, Map<String, Recipe> recipeMap) {
    final linkedTagIds = <String>[];
    for (final id in _componentOrder) {
      if (id == 'self') continue;
      final comp = recipeMap[id];
      if (comp == null) continue;
      for (final tagId in comp.tagIds) {
        if (!_selectedTagIds.contains(tagId) && !linkedTagIds.contains(tagId)) {
          linkedTagIds.add(tagId);
        }
      }
    }
    if (linkedTagIds.isEmpty) return const [];
    final chips = linkedTagIds
        .map((id) => tagByIdAll(id, allTags))
        .whereType<TagDefinition>()
        .map((tag) => TagChip(tag: tag, isSelected: true))
        .toList();
    if (chips.isEmpty) return const [];
    return [
      const SizedBox(height: 8),
      const Text(
        'From components',
        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
      const SizedBox(height: 6),
      Wrap(spacing: 8, runSpacing: 8, children: chips),
    ];
  }

  // ── Components section ────────────────────────────────────────────────────

  Widget _buildComponentsSection(
      List<Recipe> allRecipes, Map<String, Recipe> recipeMap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel(text: 'Components'),
        const SizedBox(height: 4),
        const Text(
          'Link other recipes as building blocks. Their steps and ingredients will be combined into this recipe.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        if (_componentOrder.isNotEmpty) ...[
          const SizedBox(height: 8),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _componentOrder.length,
            onReorder: _reorderComponent,
            itemBuilder: (ctx, i) {
              final entry = _componentOrder[i];
              final isSelf = entry == 'self';
              final linkedRecipe = isSelf ? null : recipeMap[entry];
              final isDeleted = !isSelf && linkedRecipe == null;
              final title = isSelf
                  ? 'This recipe'
                  : (linkedRecipe?.title ?? '(deleted)');

              final linkedIndex = _componentOrder
                  .where((id) => id != 'self')
                  .toList()
                  .indexOf(entry);
              final color = isSelf
                  ? null
                  : componentColors[linkedIndex % componentColors.length];

              return ListTile(
                key: ValueKey(entry),
                contentPadding: const EdgeInsets.symmetric(vertical: 2),
                leading: isSelf
                    ? const Icon(Icons.restaurant_menu,
                        color: AppColors.textSecondary, size: 20)
                    : Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: isDeleted ? Colors.orange.shade200 : color,
                          shape: BoxShape.circle,
                        ),
                      ),
                title: Text(
                  title,
                  style: TextStyle(
                    fontStyle: isSelf ? FontStyle.italic : FontStyle.normal,
                    color: isDeleted ? Colors.orange : null,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isSelf)
                      IconButton(
                        icon:
                            const Icon(Icons.remove_circle_outline, size: 20),
                        color: AppColors.textSecondary,
                        onPressed: () => _removeComponent(entry),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    const SizedBox(width: 8),
                    ReorderableDragStartListener(
                      index: i,
                      child: const Icon(Icons.drag_handle,
                          color: AppColors.divider),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => _showAddComponentDialog(allRecipes),
            icon: const Icon(Icons.add_link, size: 18),
            label: const Text('Add component recipe'),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          ),
        ),
      ],
    );
  }

  // ── Composite steps section ───────────────────────────────────────────────

  Widget _buildCompositeStepsSection(
      List<Recipe> allRecipes, Map<String, Recipe> recipeMap) {
    final tempRecipe = Recipe(
      id: _isNew ? '' : widget.recipeId,
      title: '',
      tagIds: const [],
      ingredients: const [],
      steps: _steps,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      componentOrder: _componentOrder,
      compositeStepOrder: _compositeStepOrder,
    );
    final ordered = resolveStepOrder(tempRecipe, allRecipes);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (ordered.isEmpty)
          const Text(
            'No steps yet',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          )
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: ordered.length,
            onReorder: (oldIndex, newIndex) =>
                _reorderCompositeStep(oldIndex, newIndex, ordered, allRecipes),
            itemBuilder: (ctx, i) {
              final entry = ordered[i];
              final isOwn = entry.sourceRecipeId == 'self';
              final color = _componentColorFor(entry.sourceRecipeId);
              final sourceTitle = isOwn
                  ? null
                  : (recipeMap[entry.sourceRecipeId]?.title ?? '(deleted)');

              return _buildCompositeStepTile(
                key: ValueKey(entry.step.id),
                index: i,
                entry: entry,
                isOwn: isOwn,
                color: color,
                sourceTitle: sourceTitle,
              );
            },
          ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _addOwnStep,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add step to this recipe'),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildCompositeStepTile({
    required Key key,
    required int index,
    required ({RecipeStep step, String sourceRecipeId}) entry,
    required bool isOwn,
    required Color? color,
    required String? sourceTitle,
  }) {
    final badgeColor = color ?? AppColors.primary;
    final badge = Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '${index + 1}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: badgeColor,
          ),
        ),
      ),
    );

    final dragHandle = Listener(
      onPointerDown: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      child: ReorderableDragStartListener(
        index: index,
        child: const Padding(
          padding: EdgeInsets.only(top: 8, left: 4, right: 4),
          child: Icon(Icons.drag_handle, color: AppColors.divider),
        ),
      ),
    );

    if (isOwn) {
      final controller = _ownStepControllerMap[entry.step.id];
      return Container(
        key: key,
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: AppColors.primary.withValues(alpha: 0.25),
              width: 3,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 12, right: 12),
              child: badge,
            ),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: (_) => setState(() => _syncOwnSteps()),
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Step ${index + 1}...',
                  isDense: true,
                ),
                textInputAction: TextInputAction.newline,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 20),
                color: AppColors.textSecondary,
                onPressed: () => _deleteOwnStep(entry.step.id),
                padding: const EdgeInsets.only(left: 8),
                constraints: const BoxConstraints(),
              ),
            ),
            dragHandle,
          ],
        ),
      );
    } else {
      // Read-only linked step
      return Container(
        key: key,
        decoration: BoxDecoration(
          color: color?.withValues(alpha: 0.08),
          border: color != null
              ? Border(left: BorderSide(color: color, width: 3))
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 12, right: 12),
              child: badge,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.step.instruction,
                      style: const TextStyle(fontSize: 16),
                    ),
                    if (sourceTitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'from $sourceTitle',
                          style: TextStyle(
                            fontSize: 12,
                            color: color ?? AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            dragHandle,
          ],
        ),
      );
    }
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.3,
      ),
    );
  }
}
