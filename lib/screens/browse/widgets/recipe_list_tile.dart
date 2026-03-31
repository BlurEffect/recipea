import 'dart:io';

import 'package:flutter/material.dart';
import '../../../data/tag_definitions.dart';
import '../../../models/recipe.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/tag_chip.dart';

class RecipeListTile extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;
  final List<TagDefinition> allTags;

  const RecipeListTile({
    super.key,
    required this.recipe,
    required this.onTap,
    required this.allTags,
  });

  @override
  Widget build(BuildContext context) {
    final firstTags = recipe.tagIds
        .take(3)
        .map((id) => tagByIdAll(id, allTags))
        .whereType<TagDefinition>()
        .toList();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
              child: SizedBox(
                width: 88,
                height: 88,
                child: recipe.imagePath != null
                    ? Image.file(
                        File(recipe.imagePath!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (firstTags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        children: firstTags
                            .map((t) => TagChip(tag: t, isSelected: false))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        color: AppColors.divider,
        child: const Center(
          child: Icon(Icons.restaurant, color: AppColors.textSecondary, size: 28),
        ),
      );
}
