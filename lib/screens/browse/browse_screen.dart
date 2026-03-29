import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/tag_definitions.dart';
import '../../providers/recipe_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/tag_chip.dart';
import '../../widgets/tag_selector_sheet.dart';
import 'widgets/recipe_list_tile.dart';

class BrowseScreen extends ConsumerWidget {
  const BrowseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipes = ref.watch(filteredRecipesProvider);
    final activeTags = ref.watch(tagFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Recipes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/recipes/new/edit'),
            tooltip: 'Create recipe',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TagFilterBar(
            activeTags: activeTags,
            onAddTags: () => showTagSelectorSheet(
              context: context,
              selectedIds: activeTags,
              onChanged: (ids) {
                final notifier = ref.read(tagFilterProvider.notifier);
                // Sync the full selection with what the sheet returns
                final toAdd = ids.difference(activeTags);
                final toRemove = activeTags.difference(ids);
                for (final id in toAdd) {
                  notifier.toggle(id);
                }
                for (final id in toRemove) {
                  notifier.toggle(id);
                }
              },
            ),
            onRemoveTag: (id) => ref.read(tagFilterProvider.notifier).toggle(id),
            onClear: () => ref.read(tagFilterProvider.notifier).clear(),
          ),
          const Divider(height: 1),
          Expanded(
            child: recipes.isEmpty
                ? EmptyState(
                    icon: activeTags.isEmpty
                        ? Icons.menu_book_outlined
                        : Icons.search_off,
                    message: activeTags.isEmpty
                        ? 'No recipes yet'
                        : 'No recipes match these tags',
                    subMessage: activeTags.isEmpty
                        ? 'Tap + to add your first recipe'
                        : 'Try removing some filters',
                    action: activeTags.isNotEmpty
                        ? TextButton(
                            onPressed: () =>
                                ref.read(tagFilterProvider.notifier).clear(),
                            child: const Text('Clear filters'),
                          )
                        : null,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = recipes[index];
                      return RecipeListTile(
                        recipe: recipe,
                        onTap: () => context.go('/recipes/${recipe.id}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _TagFilterBar extends StatelessWidget {
  final Set<String> activeTags;
  final VoidCallback onAddTags;
  final void Function(String) onRemoveTag;
  final VoidCallback onClear;

  const _TagFilterBar({
    required this.activeTags,
    required this.onAddTags,
    required this.onRemoveTag,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: activeTags.isEmpty
                ? GestureDetector(
                    onTap: onAddTags,
                    child: const Row(
                      children: [
                        Icon(Icons.filter_list, size: 18, color: AppColors.textSecondary),
                        SizedBox(width: 8),
                        Text(
                          'Filter by tags...',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final id in activeTags)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Builder(builder: (context) {
                              final tag = tagById(id);
                              if (tag == null) return const SizedBox.shrink();
                              return TagChip(
                                tag: tag,
                                isSelected: true,
                                showRemove: true,
                                onTap: () => onRemoveTag(id),
                              );
                            }),
                          ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onAddTags,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.tune, size: 18, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
