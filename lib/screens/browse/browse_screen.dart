import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/tag_definitions.dart';
import '../../providers/recipe_providers.dart';
import '../../repositories/recipe_repository.dart';
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
    final filter = ref.watch(tagFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Recipes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'export_all') {
                await _exportAll(context, ref);
              } else if (value == 'import') {
                await _importRecipes(context, ref);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'export_all', child: Text('Export all')),
              PopupMenuItem(value: 'import', child: Text('Import recipes')),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/recipes/new/edit'),
        tooltip: 'Create recipe',
        child: const Icon(Icons.add),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TagFilterBar(
            filter: filter,
            onAddTags: () => showTagSelectorSheet(
              context: context,
              currentFilter: filter,
              onChanged: (f) =>
                  ref.read(tagFilterProvider.notifier).setBoth(f),
            ),
            onRemoveIncluded: (id) =>
                ref.read(tagFilterProvider.notifier).toggleIncluded(id),
            onRemoveExcluded: (id) =>
                ref.read(tagFilterProvider.notifier).toggleExcluded(id),
            onClear: () => ref.read(tagFilterProvider.notifier).clear(),
          ),
          const Divider(height: 1),
          Expanded(
            child: recipes.isEmpty
                ? EmptyState(
                    icon: filter.isEmpty
                        ? Icons.menu_book_outlined
                        : Icons.search_off,
                    message: filter.isEmpty
                        ? 'No recipes yet'
                        : 'No recipes match these filters',
                    subMessage: filter.isEmpty
                        ? 'Tap the + button to add your first recipe'
                        : 'Try removing some filters',
                    action: filter.isNotEmpty
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

Future<void> _exportAll(BuildContext context, WidgetRef ref) async {
  try {
    final repo = ref.read(recipeRepositoryProvider);
    final json = await repo.exportToJson([]);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/recipea_export_all.json');
    await file.writeAsString(json);
    if (context.mounted) {
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/json')],
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }
}

Future<void> _importRecipes(BuildContext context, WidgetRef ref) async {
  final picked = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['json'],
  );
  if (picked == null) return;
  final path = picked.files.single.path;
  if (path == null) return;

  String jsonString;
  ImportResult result;
  try {
    jsonString = await File(path).readAsString();
    result = await ref.read(recipeRepositoryProvider).importFromJson(jsonString);
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import failed: $e')),
      );
    }
    return;
  }

  int totalImported = result.imported;

  if (result.conflicts.isNotEmpty && context.mounted) {
    final replace = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Duplicate recipes'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${result.conflicts.length} recipe(s) already exist:',
            ),
            const SizedBox(height: 8),
            ...result.conflicts.map(
              (t) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• $t',
                    style: const TextStyle(fontWeight: FontWeight.w500)),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Replace them with the imported versions?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Skip'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Replace'),
          ),
        ],
      ),
    );
    if (replace == true && context.mounted) {
      await ref
          .read(recipeRepositoryProvider)
          .forceImport(jsonString, result.conflictIds);
      totalImported += result.conflicts.length;
    }
  }

  ref.read(recipeListProvider.notifier).refresh();

  if (context.mounted) {
    final msg = totalImported == 0
        ? 'Nothing new to import'
        : 'Imported $totalImported recipe(s)';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _TagFilterBar extends StatelessWidget {
  final TagFilterState filter;
  final VoidCallback onAddTags;
  final void Function(String) onRemoveIncluded;
  final void Function(String) onRemoveExcluded;
  final VoidCallback onClear;

  const _TagFilterBar({
    required this.filter,
    required this.onAddTags,
    required this.onRemoveIncluded,
    required this.onRemoveExcluded,
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
            child: filter.isEmpty
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
                        for (final id in filter.included)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Builder(builder: (context) {
                              final tag = tagById(id);
                              if (tag == null) return const SizedBox.shrink();
                              return TagChip(
                                tag: tag,
                                isSelected: true,
                                showRemove: true,
                                onTap: () => onRemoveIncluded(id),
                              );
                            }),
                          ),
                        for (final id in filter.excluded)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Builder(builder: (context) {
                              final tag = tagById(id);
                              if (tag == null) return const SizedBox.shrink();
                              return TagChip(
                                tag: tag,
                                isExcluded: true,
                                showRemove: true,
                                onTap: () => onRemoveExcluded(id),
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
