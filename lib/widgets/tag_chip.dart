import 'package:flutter/material.dart';
import '../data/tag_definitions.dart';
import '../theme/app_colors.dart';

class TagChip extends StatelessWidget {
  final TagDefinition tag;
  final bool isSelected;
  final bool isExcluded;
  final bool showRemove;
  final VoidCallback? onTap;

  const TagChip({
    super.key,
    required this.tag,
    this.isSelected = false,
    this.isExcluded = false,
    this.showRemove = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = tag.category.color;

    final Color bgColor;
    final Color borderColor;
    final Color textColor;

    if (isExcluded) {
      bgColor = const Color(0xFFFFEBEE);
      borderColor = color;
      textColor = color;
    } else if (isSelected) {
      bgColor = AppColors.surface;
      borderColor = color;
      textColor = color;
    } else {
      bgColor = AppColors.surface;
      borderColor = AppColors.divider;
      textColor = AppColors.textSecondary;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
              const SizedBox(width: 4),
              Icon(Icons.close, size: 14, color: textColor),
            ],
          ],
        ),
      ),
    );
  }
}
