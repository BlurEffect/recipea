import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../data/seed_data.dart';
import '../models/category_definition.dart';
import '../providers/category_providers.dart';
import '../providers/custom_tag_providers.dart';
import '../providers/recipe_providers.dart';
import '../theme/app_colors.dart';

void showCategoryManagerSheet({required BuildContext context}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const _CategoryManagerSheet(),
  );
}

class _CategoryManagerSheet extends ConsumerStatefulWidget {
  const _CategoryManagerSheet();

  @override
  ConsumerState<_CategoryManagerSheet> createState() =>
      _CategoryManagerSheetState();
}

class _CategoryManagerSheetState extends ConsumerState<_CategoryManagerSheet> {
  void _showEditDialog({CategoryDefinition? existing}) {
    final isNew = existing == null;
    final controller = TextEditingController(text: existing?.name ?? '');
    Color selectedColor =
        existing?.color ?? categoryColorPalette.first;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isNew ? 'New Category' : 'Edit Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                maxLength: 30,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(hintText: 'Category name'),
              ),
              const SizedBox(height: 12),
              const Text(
                'Color',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categoryColorPalette.map((color) {
                  final isSelected = selectedColor == color;
                  return GestureDetector(
                    onTap: () => setDialogState(() => selectedColor = color),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                                color: AppColors.textPrimary, width: 2.5)
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check,
                              size: 16, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isEmpty) return;
                final category = CategoryDefinition(
                  id: existing?.id ?? const Uuid().v4(),
                  name: name,
                  color: selectedColor,
                );
                ref.read(categoryProvider.notifier).save(category);
                Navigator.pop(ctx);
              },
              child: Text(isNew ? 'Create' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(CategoryDefinition category) {
    final allTags = ref.read(allTagsProvider);
    final tagsInCategory =
        allTags.where((t) => t.category == category.id).toList();
    final tagIds = tagsInCategory.map((t) => t.id).toSet();
    final allRecipes = ref.read(recipeListProvider);
    final affectedRecipes =
        allRecipes.where((r) => r.tagIds.any(tagIds.contains)).toList();

    final tagCount = tagsInCategory.length;
    final recipeCount = affectedRecipes.length;

    String message = "'${category.name}' will be permanently deleted.";
    if (tagCount > 0) {
      message +=
          '\n\nThis will also delete $tagCount tag${tagCount == 1 ? '' : 's'}';
      if (recipeCount > 0) {
        message +=
            ' and remove them from $recipeCount recipe${recipeCount == 1 ? '' : 's'}';
      }
      message += '.';
    }

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete category?'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _cascadeDelete(category, tagsInCategory, tagIds,
                  affectedRecipes);
            },
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Future<void> _cascadeDelete(
    CategoryDefinition category,
    List tagsInCategory,
    Set<String> tagIds,
    List affectedRecipes,
  ) async {
    // 1. Delete all tags in the category
    final tagNotifier = ref.read(customTagsProvider.notifier);
    for (final tag in tagsInCategory) {
      await ref.read(customTagRepositoryProvider).delete(tag.id);
    }
    tagNotifier.refresh();

    // 2. Strip deleted tag IDs from affected recipes
    final recipeNotifier = ref.read(recipeListProvider.notifier);
    for (final recipe in affectedRecipes) {
      final updated = recipe.copyWith(
        tagIds: recipe.tagIds.where((id) => !tagIds.contains(id)).toList(),
      );
      await recipeNotifier.save(updated);
    }

    // 3. Delete the category itself
    await ref.read(categoryProvider.notifier).delete(category.id);
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) {
        return Column(
          children: [
            // Handle
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text(
                    'Manage Categories',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: 'Add category',
                    onPressed: _showEditDialog,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: categories.isEmpty
                  ? const Center(
                      child: Text(
                        'No categories yet',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: categories.length,
                      itemBuilder: (_, index) {
                        final cat = categories[index];
                        return ListTile(
                          leading: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: cat.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          title: Text(cat.name),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 20),
                                tooltip: 'Edit',
                                onPressed: () =>
                                    _showEditDialog(existing: cat),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete_outline,
                                    size: 20, color: AppColors.error),
                                tooltip: 'Delete',
                                onPressed: () => _confirmDelete(cat),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
