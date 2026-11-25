import 'dart:io';

import 'package:flutter/material.dart';
import '../../../models/recipe.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radius.dart';

class RecipeListTile extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;

  const RecipeListTile({
    super.key,
    required this.recipe,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Row(
          children: [
            // Thumbnail
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.button),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: recipe.imagePath != null
                      ? Image.file(
                          File(recipe.imagePath!),
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _placeholder(colors),
                        )
                      : _placeholder(colors),
                ),
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
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.chevron_right,
              color: colors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
          ],
        ),
        ),
      ),
    );
  }

  Widget _placeholder(AppColors colors) => Container(
        color: colors.divider,
        child: Center(
          child: Icon(Icons.restaurant, color: colors.textSecondary, size: 28),
        ),
      );
}
