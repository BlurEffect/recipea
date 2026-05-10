import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/tag_definitions.dart';
import '../../models/recipe.dart';
import '../../providers/custom_tag_providers.dart';
import '../../providers/recipe_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/add_to_meal_plan_sheet.dart';
import '../../widgets/tag_chip.dart';

class DetailScreen extends ConsumerWidget {
  final String recipeId;

  const DetailScreen({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipe = ref
        .watch(recipeListProvider)
        .cast<Recipe?>()
        .firstWhere((r) => r?.id == recipeId, orElse: () => null);

    final allTags = ref.watch(allTagsProvider);

    if (recipe == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Recipe not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _RecipeAppBar(recipe: recipe),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    recipe.title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Tags
                  if (recipe.tagIds.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: recipe.tagIds
                          .map((id) => tagByIdAll(id, allTags))
                          .whereType<TagDefinition>()
                          .map((t) => TagChip(tag: t, isSelected: true))
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                  // Ingredients
                  if (recipe.ingredients.isNotEmpty) ...[
                    _SectionHeader(title: 'Ingredients'),
                    const SizedBox(height: 12),
                    ...recipe.ingredients.map(
                      (ing) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 7),
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: AppColors.textPrimary,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '${ing.amount}  ',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    TextSpan(text: ing.name),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  // Steps
                  if (recipe.steps.isNotEmpty) ...[
                    _SectionHeader(title: 'Steps'),
                    const SizedBox(height: 12),
                    ...recipe.steps.map(
                      (step) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${step.order + 1}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  step.instruction,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    height: 1.5,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeAppBar extends ConsumerWidget {
  final Recipe recipe;

  const _RecipeAppBar({required this.recipe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverAppBar(
      expandedHeight: recipe.imagePath != null ? 280 : 0,
      pinned: true,
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: () => context.go('/recipes/${recipe.id}/edit'),
          tooltip: 'Edit recipe',
        ),
        PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'add_to_plan') {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: AppColors.surface,
                shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (_) => AddToMealPlanSheet(
                  recipeId: recipe.id,
                  recipeTitle: recipe.title,
                ),
              );
            } else if (value == 'export') {
              try {
                final repo = ref.read(recipeRepositoryProvider);
                final customTags = ref.read(customTagsProvider);
                final json = await repo.exportToJson([recipe.id], customTags);
                final dir = await getTemporaryDirectory();
                final file = File('${dir.path}/recipea_export.json');
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
            } else if (value == 'delete') {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Delete recipe?'),
                  content: Text('Delete "${recipe.title}"? This cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                await ref.read(recipeListProvider.notifier).delete(recipe.id);
                if (context.mounted) context.go('/recipes');
              }
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'add_to_plan',
              child: Text('Add to Meal Plan'),
            ),
            PopupMenuItem(value: 'export', child: Text('Export recipe')),
            PopupMenuItem(
              value: 'delete',
              child: Text('Delete', style: TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      ],
      flexibleSpace: recipe.imagePath != null
          ? FlexibleSpaceBar(
              background: Image.file(
                File(recipe.imagePath!),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(color: AppColors.divider),
              ),
            )
          : null,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }
}
