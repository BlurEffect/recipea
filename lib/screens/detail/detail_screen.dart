import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/seed_data.dart';
import '../../data/tag_definitions.dart';
import '../../models/ingredient.dart';
import '../../models/recipe.dart';
import '../../providers/category_providers.dart';
import '../../providers/custom_tag_providers.dart';
import '../../providers/recipe_providers.dart';
import '../../theme/app_colors.dart';
import '../../utils/recipe_graph.dart';
import '../../widgets/add_to_meal_plan_sheet.dart';
import '../../widgets/tag_chip.dart';

class DetailScreen extends ConsumerStatefulWidget {
  final String recipeId;

  const DetailScreen({super.key, required this.recipeId});

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  bool _showCombinedIngredients = false;

  @override
  Widget build(BuildContext context) {
    final recipe = ref
        .watch(recipeListProvider)
        .cast<Recipe?>()
        .firstWhere((r) => r?.id == widget.recipeId, orElse: () => null);

    final allTags = ref.watch(allTagsProvider);
    final allRecipes = ref.watch(recipeListProvider);
    final recipeMap = {for (final r in allRecipes) r.id: r};

    if (recipe == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Recipe not found')),
      );
    }

    // Always use allTagIds — for standalone it returns recipe.tagIds unchanged;
    // for composite it adds linked component tags (deduped, own tags first).
    final tagIds = allTagIds(recipe, allRecipes);

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
                  // Component chips (composite only)
                  if (recipe.isComposite) ...[
                    const SizedBox(height: 12),
                    _buildComponentChips(recipe, recipeMap),
                  ],
                  const SizedBox(height: 12),
                  // Tags
                  if (tagIds.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: tagIds
                          .map((id) => tagByIdAll(id, allTags))
                          .whereType<TagDefinition>()
                          .map((t) => TagChip(tag: t, isSelected: true))
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                  // Ingredients
                  if (recipe.isComposite)
                    _buildCompositeIngredients(recipe, allRecipes, recipeMap)
                  else if (recipe.ingredients.isNotEmpty) ...[
                    _SectionHeader(title: 'Ingredients'),
                    const SizedBox(height: 12),
                    ..._ingredientRows(recipe.ingredients),
                    const SizedBox(height: 24),
                  ],
                  // Steps
                  if (recipe.isComposite)
                    _buildCompositeSteps(recipe, allRecipes, recipeMap)
                  else if (recipe.steps.isNotEmpty) ...[
                    _SectionHeader(title: 'Steps'),
                    const SizedBox(height: 12),
                    ...recipe.steps.map(
                      (step) => _StandalonStepTile(
                        number: step.order + 1,
                        instruction: step.instruction,
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

  // ── Component chips header ─────────────────────────────────────────────────

  Widget _buildComponentChips(Recipe recipe, Map<String, Recipe> recipeMap) {
    final linkedIds = recipe.linkedRecipeIds;
    final chips = <Widget>[];
    for (int i = 0; i < linkedIds.length; i++) {
      final id = linkedIds[i];
      final linked = recipeMap[id];
      if (linked == null) {
        chips.add(Chip(
          avatar: const Icon(Icons.warning_amber_rounded,
              size: 16, color: Colors.orange),
          label: Text(
            '$id (not found)',
            style: const TextStyle(fontSize: 12, color: Colors.orange),
          ),
          backgroundColor: Colors.orange.shade50,
          side: BorderSide(color: Colors.orange.shade200),
          padding: EdgeInsets.zero,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ));
      } else {
        chips.add(Chip(
          avatar: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: componentColors[i % componentColors.length],
              shape: BoxShape.circle,
            ),
          ),
          label: Text(linked.title, style: const TextStyle(fontSize: 12)),
          backgroundColor: componentColors[i % componentColors.length]
              .withValues(alpha: 0.15),
          side: BorderSide(
              color: componentColors[i % componentColors.length]
                  .withValues(alpha: 0.4)),
          padding: EdgeInsets.zero,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ));
      }
    }
    return Wrap(spacing: 8, runSpacing: 6, children: chips);
  }

  // ── Composite ingredients ──────────────────────────────────────────────────

  Widget _buildCompositeIngredients(
      Recipe recipe, List<Recipe> allRecipes, Map<String, Recipe> recipeMap) {
    final hasIngredients = allIngredients(recipe, allRecipes).isNotEmpty;
    if (!hasIngredients) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(child: _SectionHeader(title: 'Ingredients')),
            SegmentedButton<bool>(
              style: SegmentedButton.styleFrom(
                textStyle: const TextStyle(fontSize: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                minimumSize: const Size(0, 32),
              ),
              segments: const [
                ButtonSegment(value: false, label: Text('Separate')),
                ButtonSegment(value: true, label: Text('Combined')),
              ],
              selected: {_showCombinedIngredients},
              onSelectionChanged: (v) =>
                  setState(() => _showCombinedIngredients = v.first),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_showCombinedIngredients)
          ..._ingredientRows(allIngredients(recipe, allRecipes))
        else
          _buildSeparateIngredients(recipe, allRecipes, recipeMap),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSeparateIngredients(
      Recipe recipe, List<Recipe> allRecipes, Map<String, Recipe> recipeMap) {
    final linkedIds = recipe.linkedRecipeIds;
    final blocks = <Widget>[];

    for (final entry in recipe.componentOrder) {
      if (entry == 'self') {
        if (recipe.ingredients.isEmpty) continue;
        blocks.add(_IngredientBlock(
          title: 'This recipe',
          ingredients: recipe.ingredients,
          color: null,
        ));
      } else {
        final linked = recipeMap[entry];
        if (linked == null) continue; // skip deleted
        if (linked.ingredients.isEmpty) continue;
        final colorIdx = linkedIds.indexOf(entry);
        blocks.add(_IngredientBlock(
          title: linked.title,
          ingredients: linked.ingredients,
          color: colorIdx >= 0
              ? componentColors[colorIdx % componentColors.length]
              : null,
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: blocks,
    );
  }

  // ── Composite steps ───────────────────────────────────────────────────────

  Widget _buildCompositeSteps(
      Recipe recipe, List<Recipe> allRecipes, Map<String, Recipe> recipeMap) {
    final ordered = resolveStepOrder(recipe, allRecipes);
    if (ordered.isEmpty) return const SizedBox.shrink();

    final linkedIds = recipe.linkedRecipeIds;
    final tiles = <Widget>[];
    for (int i = 0; i < ordered.length; i++) {
      final entry = ordered[i];
      final isOwn = entry.sourceRecipeId == 'self';
      final colorIdx =
          isOwn ? -1 : linkedIds.indexOf(entry.sourceRecipeId);
      final color = colorIdx >= 0
          ? componentColors[colorIdx % componentColors.length]
          : null;
      final sourceTitle = isOwn
          ? null
          : (recipeMap[entry.sourceRecipeId]?.title ?? '(deleted)');
      tiles.add(_CompositeStepTile(
        number: i + 1,
        instruction: entry.step.instruction,
        color: color,
        sourceTitle: sourceTitle,
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'Steps'),
        const SizedBox(height: 12),
        ...tiles,
      ],
    );
  }

  // ── Shared helper ─────────────────────────────────────────────────────────

  List<Widget> _ingredientRows(List<Ingredient> ingredients) {
    return ingredients
        .map((ing) => Padding(
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
            ))
        .toList();
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

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
                final allTags = ref.read(allTagsProvider);
                final allCategories = ref.read(categoryProvider);
                final json =
                    await repo.exportToJson([recipe.id], allTags, allCategories);
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
                  content:
                      Text('Delete "${recipe.title}"? This cannot be undone.'),
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
                errorBuilder: (_, _, _) =>
                    Container(color: AppColors.divider),
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

class _StandalonStepTile extends StatelessWidget {
  final int number;
  final String instruction;

  const _StandalonStepTile({required this.number, required this.instruction});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                '$number',
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
                instruction,
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
    );
  }
}

class _CompositeStepTile extends StatelessWidget {
  final int number;
  final String instruction;
  final Color? color;
  final String? sourceTitle;

  const _CompositeStepTile({
    required this.number,
    required this.instruction,
    required this.color,
    required this.sourceTitle,
  });

  @override
  Widget build(BuildContext context) {
    final badgeColor = color ?? AppColors.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: color?.withValues(alpha: 0.06),
          border: color != null
              ? Border(left: BorderSide(color: color!, width: 3))
              : null,
          borderRadius: color != null
              ? const BorderRadius.only(
                  topRight: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                )
              : null,
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$number',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: badgeColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      instruction,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (sourceTitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'from $sourceTitle',
                        style: TextStyle(
                          fontSize: 12,
                          color: color ?? AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IngredientBlock extends StatelessWidget {
  final String title;
  final List<Ingredient> ingredients;
  final Color? color;

  const _IngredientBlock({
    required this.title,
    required this.ingredients,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (color != null)
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color != null ? AppColors.textPrimary : AppColors.textSecondary,
                fontStyle:
                    color == null ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...ingredients.map((ing) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 7),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: color ?? AppColors.primary,
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
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: color ?? AppColors.primary,
                            ),
                          ),
                          TextSpan(text: ing.name),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )),
        const SizedBox(height: 16),
      ],
    );
  }
}
