import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/tag_definitions.dart';
import '../../models/ingredient.dart';
import '../../models/recipe.dart';
import '../../models/recipe_step.dart';
import '../../providers/recipe_providers.dart';
import '../../theme/app_colors.dart';
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
  String? _existingImagePath; // track if we replaced an existing image
  Set<String> _selectedTagIds = {};
  List<Ingredient> _ingredients = [];
  List<RecipeStep> _steps = [];
  bool _saving = false;

  bool get _isNew => widget.recipeId == 'new';

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
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
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

      // If image changed and is a temp path (not already in docs dir), copy it
      if (_imagePath != null &&
          _imagePath != _existingImagePath &&
          !_imagePath!.contains('recipea_images')) {
        finalImagePath = await repo.saveImage(_imagePath!);
        // Clean up old image if editing
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  ref.read(recipeRepositoryProvider).deleteImageFile(_imagePath!);
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
            // Tags
            Row(
              children: [
                const _FieldLabel(text: 'Tags'),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => showTagSelectorSheet(
                    context: context,
                    selectedIds: _selectedTagIds,
                    onChanged: (ids) => setState(() => _selectedTagIds = ids),
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
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedTagIds
                    .map(tagById)
                    .whereType<TagDefinition>()
                    .map((tag) => TagChip(
                          tag: tag,
                          isSelected: true,
                          showRemove: true,
                          onTap: () => setState(
                            () => _selectedTagIds.remove(tag.id),
                          ),
                        ))
                    .toList(),
              ),
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
            StepsListEditor(
              steps: _steps,
              onChanged: (list) => setState(() => _steps = list),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
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
