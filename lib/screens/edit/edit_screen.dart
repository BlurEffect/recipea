import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import '../../data/seed_data.dart';
import '../../data/tag_definitions.dart';
import '../../l10n/app_localizations.dart';
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
  final _servingsController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _imagePath;
  String? _existingImagePath;
  Set<String> _selectedTagIds = {};
  List<Ingredient> _ingredients = [];
  List<RecipeStep> _steps = [];
  bool _saving = false;

  // Composite recipe state
  List<String> _componentOrder = [];
  List<String> _compositeStepOrder = [];
  Map<String, TextEditingController> _ownStepControllerMap = {};

  bool get _isNew => widget.recipeId == 'new';
  bool get _isComposite => _componentOrder.isNotEmpty;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _requestMicIfNeeded());
    if (!_isNew) {
      final recipe = ref
          .read(recipeListProvider)
          .cast<Recipe?>()
          .firstWhere((r) => r?.id == widget.recipeId, orElse: () => null);
      if (recipe != null) {
        _titleController.text = recipe.title;
        _servingsController.text = recipe.servings.toString();
        _descriptionController.text = recipe.description ?? '';
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

  Future<void> _requestMicIfNeeded() async {
    if (!mounted) return;
    final status = await Permission.microphone.status;
    if (status.isGranted || !mounted) return;

    final l = AppLocalizations.of(context)!;

    if (status.isPermanentlyDenied) {
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(l.editMicTitle),
          content: Text(l.editMicDeniedBody),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l.notNow)),
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: Text(l.openSettings)),
          ],
        ),
      );
      return;
    }

    final allow = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.editVoiceInputTitle),
        content: Text(l.editVoiceInputBody),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l.notNow)),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l.allow)),
        ],
      ),
    );
    if (allow == true) await Permission.microphone.request();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _servingsController.dispose();
    _descriptionController.dispose();
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
    final l = AppLocalizations.of(context)!;
    final selfId = _isNew ? '' : widget.recipeId;
    final alreadyLinked = _componentOrder.where((id) => id != 'self').toSet();

    final available = allRecipes
        .where((r) => r.id != selfId)
        .where((r) => !r.isComposite)
        .where((r) => !alreadyLinked.contains(r.id))
        .where((r) => !wouldCreateCycle(selfId, r.id, allRecipes))
        .toList()
      ..sort((a, b) => a.title.compareTo(b.title));

    if (available.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.editNoRecipesAvailable)),
      );
      return;
    }

    String query = '';

    final selected = await showDialog<Recipe>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocalState) {
          final ll = AppLocalizations.of(ctx)!;
          final filtered = query.isEmpty
              ? available
              : available
                  .where((r) =>
                      r.title.toLowerCase().contains(query.toLowerCase()))
                  .toList();

          return AlertDialog(
            title: Text(ll.editPickComponent),
            contentPadding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: TextField(
                      autofocus: true,
                      onChanged: (v) => setLocalState(() => query = v),
                      decoration: InputDecoration(
                        hintText: ll.editSearchRecipesHint,
                        prefixIcon: const Icon(Icons.search, size: 20),
                        isDense: true,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  Flexible(
                    child: filtered.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              ll.editNoRecipesMatch,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: filtered.length,
                            itemBuilder: (_, i) => ListTile(
                              title: Text(filtered[i].title),
                              onTap: () => Navigator.pop(ctx, filtered[i]),
                            ),
                          ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(ll.cancel),
              ),
            ],
          );
        },
      ),
    );

    if (selected == null || !mounted) return;

    setState(() {
      if (_componentOrder.isEmpty) {
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
        SnackBar(
          content: Text(AppLocalizations.of(context)!.editStepsInOrder),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Color? _componentColorFor(String sourceRecipeId) {
    if (sourceRecipeId == 'self') return null;
    return componentColor(sourceRecipeId);
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (_isComposite) _syncOwnSteps();

    final l = AppLocalizations.of(context)!;
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.editPleaseAddTitle)),
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
      final servings = (int.tryParse(_servingsController.text.trim()) ?? 1).clamp(1, 99);
      final descriptionText = _descriptionController.text.trim();
      final description = descriptionText.isEmpty ? null : descriptionText;
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
              servings: servings,
              description: description,
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
                servings: servings,
                description: description,
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
          SnackBar(content: Text(AppLocalizations.of(context)!.editSaveFailed(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
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
            _isNew ? l.editNewRecipe : l.editExistingRecipe,
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
                  _isNew ? l.save : l.update,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
          ],
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: SingleChildScrollView(
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
              _FieldLabel(text: l.editTitleLabel),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(hintText: l.editTitleHint),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              // Servings
              Row(
                children: [
                  _FieldLabel(text: l.editServingsLabel),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 70,
                    child: TextField(
                      controller: _servingsController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _ServingsRangeFormatter(),
                      ],
                      decoration: const InputDecoration(
                        hintText: '1',
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Cook's notes / description
              _FieldLabel(text: l.detailDescription),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: l.editDescriptionHint,
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                ),
              ),
              const SizedBox(height: 24),
              // Components
              _buildComponentsSection(allRecipes, recipeMap),
              const SizedBox(height: 24),
              // Tags
              Row(
                children: [
                  _FieldLabel(text: l.editTagsLabel),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => showTagSelectorSheet(
                      context: context,
                      currentFilter: TagFilterState(included: _selectedTagIds),
                      onChanged: (f) =>
                          setState(() => _selectedTagIds = f.included),
                    ),
                    icon: const Icon(Icons.add, size: 16),
                    label: Text(l.editAddTagsButton),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_selectedTagIds.isEmpty)
                Text(
                  l.editNoTagsSelected,
                  style:
                      const TextStyle(color: AppColors.textSecondary, fontSize: 14),
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
              if (_isComposite) ..._buildLinkedTagChips(allTags, recipeMap),
              const SizedBox(height: 24),
              // Ingredients
              _FieldLabel(text: l.editIngredientsLabel),
              const SizedBox(height: 12),
              if (_isComposite)
                ..._buildOrderedIngredients(recipeMap)
              else
                IngredientListEditor(
                  ingredients: _ingredients,
                  onChanged: (list) => setState(() => _ingredients = list),
                ),
              const SizedBox(height: 24),
              // Steps
              _FieldLabel(text: l.editStepsLabel),
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
      ),
    );
  }

  // ── Linked component tag chips (read-only) ────────────────────────────────

  List<Widget> _buildLinkedTagChips(
      List<TagDefinition> allTags, Map<String, Recipe> recipeMap) {
    final l = AppLocalizations.of(context)!;
    final linkedTagIds = <String>[];
    for (final id in _componentOrder) {
      if (id == 'self') continue;
      final comp = recipeMap[id];
      if (comp == null) continue;
      for (final tagId in comp.tagIds) {
        if (!linkedTagIds.contains(tagId)) {
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
      Text(
        l.editFromComponents,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
      const SizedBox(height: 6),
      Wrap(spacing: 8, runSpacing: 8, children: chips),
    ];
  }

  // ── Ingredient section for composite recipes (respects componentOrder) ──────

  List<Widget> _buildOrderedIngredients(Map<String, Recipe> recipeMap) {
    final widgets = <Widget>[];
    for (final id in _componentOrder) {
      if (id == 'self') {
        widgets.add(IngredientListEditor(
          ingredients: _ingredients,
          onChanged: (list) => setState(() => _ingredients = list),
        ));
        continue;
      }
      final comp = recipeMap[id];
      if (comp == null || comp.ingredients.isEmpty) continue;
      final color = componentColor(id);
      widgets.add(const SizedBox(height: 12));
      widgets.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            comp.title,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white),
          ),
        ),
      );
      widgets.add(const SizedBox(height: 8));
      for (final ing in comp.ingredients) {
        final amountStr = ing.quantity != null
            ? '${_fmtQty(ing.quantity!)}${ing.unit != null ? ' ${ing.unit}' : ''}'
            : (ing.note ?? '');
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 90,
                  child: Text(
                    amountStr,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    ing.name,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
    return widgets;
  }

  // ── Components section ────────────────────────────────────────────────────

  Widget _buildComponentsSection(
      List<Recipe> allRecipes, Map<String, Recipe> recipeMap) {
    final l = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(text: l.editComponentsLabel),
        const SizedBox(height: 4),
        Text(
          l.editComponentsDescription,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
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
                  ? l.editComponentSelf
                  : (linkedRecipe?.title ?? l.editComponentDeleted);

              final color = isSelf ? null : componentColor(entry);

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
            label: Text(l.editAddComponent),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          ),
        ),
      ],
    );
  }

  // ── Composite steps section ───────────────────────────────────────────────

  Widget _buildCompositeStepsSection(
      List<Recipe> allRecipes, Map<String, Recipe> recipeMap) {
    final l = AppLocalizations.of(context)!;
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
          Text(
            l.editNoStepsYet,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
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
                  : (recipeMap[entry.sourceRecipeId]?.title ?? l.editComponentDeleted);

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
            label: Text(l.editAddStepToRecipe),
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
    final l = AppLocalizations.of(context)!;
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
                maxLines: null,
                decoration: InputDecoration(
                  hintText: l.editStepHint(index + 1),
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
                          l.detailFromComponent(sourceTitle),
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

String _fmtQty(double v) {
  if (v == v.truncateToDouble()) return v.toInt().toString();
  return v.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
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

class _ServingsRangeFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    final n = int.tryParse(newValue.text);
    if (n == null) return oldValue;
    if (n < 1) return newValue.copyWith(text: '1');
    if (n > 99) return oldValue;
    return newValue;
  }
}
