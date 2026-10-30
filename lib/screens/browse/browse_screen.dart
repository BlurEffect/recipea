import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/tag_definitions.dart';
import '../../providers/category_providers.dart';
import '../../providers/custom_tag_providers.dart';
import '../../providers/recipe_providers.dart';
import '../../repositories/recipe_repository.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/tag_chip.dart';
import '../../widgets/tag_selector_sheet.dart';
import 'widgets/recipe_list_tile.dart';

class BrowseScreen extends ConsumerStatefulWidget {
  const BrowseScreen({super.key});

  @override
  ConsumerState<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends ConsumerState<BrowseScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    // Reset search when screen is removed from the tree.
    ref.read(recipeSearchProvider.notifier).state = '';
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(recipeSearchProvider.notifier).state = '';
  }

  @override
  Widget build(BuildContext context) {
    final recipes = ref.watch(filteredRecipesProvider);
    final filter = ref.watch(tagFilterProvider);
    final query = ref.watch(recipeSearchProvider);
    final allTags = ref.watch(allTagsProvider);

    final anyFilter = filter.isNotEmpty || query.isNotEmpty;

    Widget emptyState;
    if (!anyFilter) {
      emptyState = const EmptyState(
        icon: Icons.menu_book_outlined,
        message: 'No recipes yet',
        subMessage: 'Tap the + button to add your first recipe',
      );
    } else if (query.isNotEmpty && filter.isEmpty) {
      emptyState = EmptyState(
        icon: Icons.search_off,
        message: 'No recipes match "$query"',
        subMessage: 'Try a different search term',
        action: TextButton(
          onPressed: _clearSearch,
          child: const Text('Clear search'),
        ),
      );
    } else if (query.isEmpty && filter.isNotEmpty) {
      emptyState = EmptyState(
        icon: Icons.search_off,
        message: 'No recipes match these filters',
        subMessage: 'Try removing some filters',
        action: TextButton(
          onPressed: () => ref.read(tagFilterProvider.notifier).clear(),
          child: const Text('Clear filters'),
        ),
      );
    } else {
      emptyState = EmptyState(
        icon: Icons.search_off,
        message: 'No recipes found',
        subMessage: 'Try clearing the search or filters',
        action: TextButton(
          onPressed: () {
            _clearSearch();
            ref.read(tagFilterProvider.notifier).clear();
          },
          child: const Text('Clear all'),
        ),
      );
    }

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
              PopupMenuItem(value: 'export_all', child: Text('Export database')),
              PopupMenuItem(value: 'import', child: Text('Import recipes')),
            ],
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/recipes/new/edit'),
        tooltip: 'Create recipe',
        child: const Icon(Icons.add),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SearchField(
            controller: _searchController,
            query: query,
            onChanged: (value) =>
                ref.read(recipeSearchProvider.notifier).state = value,
            onClear: _clearSearch,
          ),
          _TagFilterBar(
            filter: filter,
            allTags: allTags,
            sort: ref.watch(recipeSortProvider),
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
            onSort: (opt) =>
                ref.read(recipeSortProvider.notifier).state = opt,
          ),
          const Divider(height: 1),
          Expanded(
            child: recipes.isEmpty
                ? emptyState
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = recipes[index];
                      return RecipeListTile(
                        recipe: recipe,
                        allTags: allTags,
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
    final allTags = ref.read(allTagsProvider);
    final allCategories = ref.read(categoryProvider);
    final json = await repo.exportToJson([], allTags, allCategories);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/database.recipea');
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
    allowedExtensions: ['recipea', 'json'],
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
      final msg = e is FormatException
          ? e.message
          : 'Import failed. Make sure you\'re using a .recipea or .json file exported from this app.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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

  if (result.categories.isNotEmpty) {
    await ref.read(categoryRepositoryProvider).mergeAll(result.categories);
    ref.read(categoryProvider.notifier).refresh();
  }
  if (result.customTags.isNotEmpty) {
    ref.read(customTagRepositoryProvider).mergeAll(result.customTags);
    ref.read(customTagsProvider.notifier).refresh();
  }

  ref.read(recipeListProvider.notifier).refresh();

  if (context.mounted) {
    final msg = totalImported == 0
        ? 'Nothing new to import'
        : 'Imported $totalImported recipe(s)';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchField({
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        autofocus: false,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search recipes…',
          hintStyle:
              const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textSecondary),
          suffixIcon: query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  color: AppColors.textSecondary,
                  onPressed: onClear,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              : null,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _TagFilterBar extends StatelessWidget {
  final TagFilterState filter;
  final List<TagDefinition> allTags;
  final SortOption sort;
  final VoidCallback onAddTags;
  final void Function(String) onRemoveIncluded;
  final void Function(String) onRemoveExcluded;
  final VoidCallback onClear;
  final void Function(SortOption) onSort;

  const _TagFilterBar({
    required this.filter,
    required this.allTags,
    required this.sort,
    required this.onAddTags,
    required this.onRemoveIncluded,
    required this.onRemoveExcluded,
    required this.onClear,
    required this.onSort,
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
                              final tag = tagByIdAll(id, allTags);
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
                              final tag = tagByIdAll(id, allTags);
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
          PopupMenuButton<SortOption>(
            tooltip: 'Sort',
            padding: EdgeInsets.zero,
            onSelected: onSort,
            itemBuilder: (_) => [
              _sortMenuItem(SortOption.titleAsc,    'A → Z',        sort),
              _sortMenuItem(SortOption.titleDesc,   'Z → A',        sort),
              _sortMenuItem(SortOption.newestFirst, 'Newest first', sort),
              _sortMenuItem(SortOption.oldestFirst, 'Oldest first', sort),
            ],
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.sort, size: 18, color: AppColors.primary),
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

PopupMenuItem<SortOption> _sortMenuItem(
    SortOption opt, String label, SortOption current) =>
    PopupMenuItem(
      value: opt,
      child: Row(
        children: [
          Expanded(child: Text(label)),
          if (current == opt)
            const Icon(Icons.check, size: 16, color: AppColors.primary),
        ],
      ),
    );
