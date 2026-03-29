import 'package:flutter/material.dart';

import '../data/tag_definitions.dart';
import '../theme/app_colors.dart';
import 'tag_chip.dart';

/// Shows a bottom sheet that lets the user pick tags.
/// [selectedIds] — currently selected tag IDs
/// [onChanged] — called whenever selection changes
void showTagSelectorSheet({
  required BuildContext context,
  required Set<String> selectedIds,
  required void Function(Set<String>) onChanged,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _TagSelectorSheet(
      selectedIds: selectedIds,
      onChanged: onChanged,
    ),
  );
}

class _TagSelectorSheet extends StatefulWidget {
  final Set<String> selectedIds;
  final void Function(Set<String>) onChanged;

  const _TagSelectorSheet({
    required this.selectedIds,
    required this.onChanged,
  });

  @override
  State<_TagSelectorSheet> createState() => _TagSelectorSheetState();
}

class _TagSelectorSheetState extends State<_TagSelectorSheet> {
  late Set<String> _selected;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _selected = {...widget.selectedIds};
  }

  List<TagDefinition> get _filtered {
    if (_query.isEmpty) return tagDefinitions;
    final q = _query.toLowerCase();
    return tagDefinitions
        .where((t) => t.label.toLowerCase().contains(q))
        .toList();
  }

  void _toggle(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
    widget.onChanged({..._selected});
  }

  @override
  Widget build(BuildContext context) {
    final grouped = <TagCategory, List<TagDefinition>>{};
    for (final tag in _filtered) {
      grouped.putIfAbsent(tag.category, () => []).add(tag);
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
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
                    'Select Tags',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (_selected.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        setState(() => _selected.clear());
                        widget.onChanged({});
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
                        entry.key.displayName,
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
                          isSelected: _selected.contains(tag.id),
                          onTap: () => _toggle(tag.id),
                        );
                      }).toList(),
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
