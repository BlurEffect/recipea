import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../data/seed_data.dart';
import '../data/tag_definitions.dart';
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
  // ── Category CRUD ──────────────────────────────────────────────────────────

  void _showEditCategoryDialog({CategoryDefinition? existing}) {
    final isNew = existing == null;
    final controller = TextEditingController(text: existing?.name ?? '');
    Color selectedColor = existing?.color ?? categoryColorPalette.first;

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
                            ? Border.all(color: AppColors.textPrimary, width: 2.5)
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
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
                ref.read(categoryProvider.notifier).save(CategoryDefinition(
                      id: existing?.id ?? const Uuid().v4(),
                      name: name,
                      color: selectedColor,
                    ));
                Navigator.pop(ctx);
              },
              child: Text(isNew ? 'Create' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteCategory(CategoryDefinition category) {
    final allTags = ref.read(allTagsProvider);
    final tagsInCategory = allTags.where((t) => t.category == category.id).toList();
    final tagIds = tagsInCategory.map((t) => t.id).toSet();
    final affectedRecipes = ref
        .read(recipeListProvider)
        .where((r) => r.tagIds.any(tagIds.contains))
        .toList();

    final tagCount = tagsInCategory.length;
    final recipeCount = affectedRecipes.length;

    String message = "'${category.name}' will be permanently deleted.";
    if (tagCount > 0) {
      message += '\n\nThis will also delete $tagCount tag${tagCount == 1 ? '' : 's'}';
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
              await _cascadeDeleteCategory(
                  category, tagsInCategory, tagIds, affectedRecipes);
            },
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Future<void> _cascadeDeleteCategory(
    CategoryDefinition category,
    List tagsInCategory,
    Set<String> tagIds,
    List affectedRecipes,
  ) async {
    final tagNotifier = ref.read(customTagsProvider.notifier);
    for (final tag in tagsInCategory) {
      await ref.read(customTagRepositoryProvider).delete(tag.id);
    }
    tagNotifier.refresh();

    final recipeNotifier = ref.read(recipeListProvider.notifier);
    for (final recipe in affectedRecipes) {
      await recipeNotifier.save(recipe.copyWith(
        tagIds: recipe.tagIds.where((id) => !tagIds.contains(id)).toList(),
      ));
    }

    await ref.read(categoryProvider.notifier).delete(category.id);
  }

  // ── Tag CRUD ───────────────────────────────────────────────────────────────

  void _confirmDeleteTag(TagDefinition tag) {
    final affectedRecipes = ref
        .read(recipeListProvider)
        .where((r) => r.tagIds.contains(tag.id))
        .toList();
    final recipeCount = affectedRecipes.length;

    String message = "'${tag.label}' will be permanently deleted.";
    if (recipeCount > 0) {
      message +=
          '\n\nIt will be removed from $recipeCount recipe${recipeCount == 1 ? '' : 's'}.';
    }

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete tag?'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _deleteSingleTag(tag, affectedRecipes);
            },
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSingleTag(TagDefinition tag, List affectedRecipes) async {
    await ref.read(customTagRepositoryProvider).delete(tag.id);
    ref.read(customTagsProvider.notifier).refresh();

    final recipeNotifier = ref.read(recipeListProvider.notifier);
    for (final recipe in affectedRecipes) {
      await recipeNotifier.save(recipe.copyWith(
        tagIds: recipe.tagIds.where((id) => id != tag.id).toList(),
      ));
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryProvider);
    final allTags = ref.watch(allTagsProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: 'Add category',
                    onPressed: _showEditCategoryDialog,
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
                        final tagsInCat = allTags
                            .where((t) => t.category == cat.id)
                            .toList();
                        return _CategorySection(
                          category: cat,
                          tags: tagsInCat,
                          onEdit: () => _showEditCategoryDialog(existing: cat),
                          onDelete: () => _confirmDeleteCategory(cat),
                          onDeleteTag: _confirmDeleteTag,
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

class _CategorySection extends StatelessWidget {
  final CategoryDefinition category;
  final List<TagDefinition> tags;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final void Function(TagDefinition) onDeleteTag;

  const _CategorySection({
    required this.category,
    required this.tags,
    required this.onEdit,
    required this.onDelete,
    required this.onDeleteTag,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category header row
        Row(
          children: [
            const SizedBox(width: 16),
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: category.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                category.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18),
              tooltip: 'Edit',
              visualDensity: VisualDensity.compact,
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(Icons.delete_outline,
                  size: 18, color: AppColors.error),
              tooltip: 'Delete category',
              visualDensity: VisualDensity.compact,
              onPressed: onDelete,
            ),
            const SizedBox(width: 4),
          ],
        ),
        // Tags
        if (tags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 0, 16, 8),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: tags.map((tag) {
                return InputChip(
                  label: Text(
                    tag.label,
                    style: const TextStyle(fontSize: 12),
                  ),
                  onDeleted: () => onDeleteTag(tag),
                  deleteIconColor: AppColors.textSecondary,
                  visualDensity: VisualDensity.compact,
                  backgroundColor: AppColors.surface,
                  side: const BorderSide(color: AppColors.divider),
                );
              }).toList(),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 0, 16, 8),
            child: Text(
              'No tags',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        const Divider(height: 1),
      ],
    );
  }
}
