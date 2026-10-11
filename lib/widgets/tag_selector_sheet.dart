import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../data/tag_definitions.dart';
import '../models/category_definition.dart';
import '../providers/category_providers.dart';
import '../providers/custom_tag_providers.dart';
import '../providers/recipe_providers.dart';
import '../theme/app_colors.dart';
import 'category_manager_sheet.dart';
import 'tag_chip.dart';

/// Shows a bottom sheet that lets the user pick tags.
/// [currentFilter] — current included/excluded tag state
/// [onChanged] — called whenever selection changes
void showTagSelectorSheet({
  required BuildContext context,
  required TagFilterState currentFilter,
  required void Function(TagFilterState) onChanged,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _TagSelectorSheet(
      currentFilter: currentFilter,
      onChanged: onChanged,
    ),
  );
}

class _TagSelectorSheet extends ConsumerStatefulWidget {
  final TagFilterState currentFilter;
  final void Function(TagFilterState) onChanged;

  const _TagSelectorSheet({
    required this.currentFilter,
    required this.onChanged,
  });

  @override
  ConsumerState<_TagSelectorSheet> createState() => _TagSelectorSheetState();
}

class _TagSelectorSheetState extends ConsumerState<_TagSelectorSheet> {
  late Set<String> _included;
  late Set<String> _excluded;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _included = {...widget.currentFilter.included};
    _excluded = {...widget.currentFilter.excluded};
  }

  void _toggle(String id) {
    setState(() {
      if (_included.contains(id)) {
        _included.remove(id);
        _excluded.add(id);
      } else if (_excluded.contains(id)) {
        _excluded.remove(id);
      } else {
        _included.add(id);
      }
    });
    widget.onChanged(TagFilterState(
      included: {..._included},
      excluded: {..._excluded},
    ));
  }

  void _showCreateDialog(BuildContext dialogContext) {
    final categories = ref.read(categoryProvider);
    if (categories.isEmpty) return;

    final controller = TextEditingController();
    CategoryDefinition selectedCategory = categories.first;

    showDialog<void>(
      context: dialogContext,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('New Tag'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                maxLength: 30,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(hintText: 'Tag name'),
              ),
              const SizedBox(height: 4),
              DropdownButtonFormField<CategoryDefinition>(
                initialValue: selectedCategory,
                items: categories
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c.name),
                        ))
                    .toList(),
                onChanged: (v) => setDialogState(() => selectedCategory = v!),
                decoration: const InputDecoration(labelText: 'Category'),
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
                final label = controller.text.trim();
                if (label.isEmpty) return;
                final tag = TagDefinition(
                  id: const Uuid().v4(),
                  label: label,
                  category: selectedCategory.id,
                  isCustom: true,
                );
                ref.read(customTagsProvider.notifier).save(tag);
                Navigator.pop(ctx);
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext sheetContext, TagDefinition tag) {
    showDialog<void>(
      context: sheetContext,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete tag?'),
        content: Text("'${tag.label}' will be removed from the tag list."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(customTagsProvider.notifier).delete(tag.id);
              // Remove from active filter sets if present
              if (_included.contains(tag.id) || _excluded.contains(tag.id)) {
                setState(() {
                  _included.remove(tag.id);
                  _excluded.remove(tag.id);
                });
                widget.onChanged(TagFilterState(
                  included: {..._included},
                  excluded: {..._excluded},
                ));
              }
              Navigator.pop(ctx);
            },
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allTags = ref.watch(allTagsProvider);
    final categoryMap = ref.watch(categoryMapProvider);

    // Group tags by category ID, preserving category order
    final grouped = <String, List<TagDefinition>>{};
    final filtered = _query.isEmpty
        ? allTags
        : allTags
            .where((t) => t.label.toLowerCase().contains(_query.toLowerCase()))
            .toList();
    for (final tag in filtered) {
      grouped.putIfAbsent(tag.category, () => []).add(tag);
    }

    final hasSelection = _included.isNotEmpty || _excluded.isNotEmpty;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (sheetContext, scrollController) {
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Tags',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Tap once to include · tap twice to exclude',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (hasSelection)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _included.clear();
                          _excluded.clear();
                        });
                        widget.onChanged(const TagFilterState());
                      },
                      child: const Text('Clear all'),
                    ),
                ],
              ),
            ),
            // Search field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: const InputDecoration(
                  hintText: 'Search tags...',
                  prefixIcon: Icon(Icons.search, size: 20),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(height: 4),
            // Tag grid
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  for (final entry in grouped.entries) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 8),
                      child: Text(
                        categoryMap[entry.key]?.name ?? entry.key,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: entry.value.map((tag) {
                        return TagChip(
                          tag: tag,
                          isSelected: _included.contains(tag.id),
                          isExcluded: _excluded.contains(tag.id),
                          showRemove: tag.isCustom,
                          onTap: () => _toggle(tag.id),
                          onRemove: tag.isCustom
                              ? () => _confirmDelete(sheetContext, tag)
                              : null,
                        );
                      }).toList(),
                    ),
                  ],
                  if (_query.isEmpty) ...[
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          onPressed: () => _showCreateDialog(sheetContext),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('New tag'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: () => showCategoryManagerSheet(
                            context: sheetContext,
                          ),
                          icon: const Icon(Icons.category_outlined, size: 16),
                          label: const Text('Manage categories'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
