import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/tag_definitions.dart';
import '../providers/category_providers.dart';
import '../theme/app_colors.dart';

class TagChip extends ConsumerWidget {
  final TagDefinition tag;
  final bool isSelected;
  final bool isExcluded;
  final bool showRemove;
  final VoidCallback? onTap;

  /// Called when the remove (×) icon is tapped.
  /// If null and showRemove is true, tapping the icon calls [onTap] instead.
  final VoidCallback? onRemove;

  const TagChip({
    super.key,
    required this.tag,
    this.isSelected = false,
    this.isExcluded = false,
    this.showRemove = false,
    this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final color = ref.watch(categoryMapProvider)[tag.category]?.color
        ?? Colors.grey;

    final Color bgColor;
    final Color borderColor;
    final Color textColor;

    if (isExcluded) {
      bgColor = colors.chipExcludedBackground;
      borderColor = color;
      textColor = color;
    } else if (isSelected) {
      bgColor = colors.surface;
      borderColor = color;
      textColor = color;
    } else {
      bgColor = colors.surface;
      borderColor = colors.divider;
      textColor = colors.textSecondary;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.only(
          left: 10,
          top: 6,
          bottom: 6,
          right: showRemove ? 6 : 10,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Placeholder icon — colored dot, replace with real icons later
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              tag.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
            if (showRemove) ...[
              const SizedBox(width: 2),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                child: InkWell(
                  onTap: onRemove ?? onTap,
                  borderRadius: BorderRadius.circular(20),
                  child: Center(
                    child: Icon(Icons.close, size: 14, color: textColor),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
