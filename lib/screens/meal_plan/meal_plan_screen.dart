import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../models/meal_plan.dart';
import '../../models/recipe.dart';
import '../../providers/meal_plan_providers.dart';
import '../../providers/recipe_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../../widgets/empty_state.dart';

class MealPlanScreen extends ConsumerWidget {
  const MealPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final plan = ref.watch(mealPlanProvider);
    final allRecipes = ref.watch(recipeListProvider);
    final locale = Localizations.localeOf(context).languageCode;

    final today = DateTime.now();
    final days = List.generate(7, (i) {
      final d = today.add(Duration(days: i));
      return DateTime(d.year, d.month, d.day);
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l.navMealPlan,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              l.mealPlanSubtitle,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_outlined),
            tooltip: AppLocalizations.of(context)!.mealPlanHistoryTooltip,
            onPressed: () => context.push('/meal-plan/history'),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear') {
                showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(l.mealPlanClearTitle),
                    content: Text(l.mealPlanClearBody),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(l.cancel),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(
                          l.clear,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ).then((confirmed) {
                  if (confirmed == true) {
                    ref.read(mealPlanProvider.notifier).clear();
                  }
                });
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    const Icon(Icons.delete_sweep_outlined, size: 20, color: AppColors.error),
                    const SizedBox(width: 12),
                    Text(
                      l.mealPlanClearPlan,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 1),
      body: allRecipes.isEmpty
          ? EmptyState(
              icon: Icons.menu_book_outlined,
              message: l.mealPlanNoRecipes,
              subMessage: l.mealPlanNoRecipesSubtitle,
              action: TextButton(
                onPressed: () => context.go('/recipes'),
                child: Text(l.goToRecipes),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: days.length,
              itemBuilder: (context, index) {
                final day = days[index];
                final isToday = index == 0;
                final dayLabel = DateFormat.MMMEd(locale).format(day);
                final header = isToday ? l.mealPlanToday(dayLabel) : dayLabel;
                final slots = plan.getSlotsForDay(day);

                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Day header
                      Container(
                        decoration: isToday
                            ? BoxDecoration(
                                color: AppColors.primary
                                    .withValues(alpha: 0.06),
                                border: const Border(
                                  left: BorderSide(
                                      color: AppColors.primary, width: 4),
                                ),
                              )
                            : null,
                        padding: EdgeInsets.fromLTRB(
                            isToday ? 12 : 16, 4, 8, 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                header,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isToday
                                      ? AppColors.primary
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Checkbox(
                              value: plan.isDayIncluded(day),
                              onChanged: (_) => ref
                                  .read(mealPlanProvider.notifier)
                                  .toggleDayExcluded(day),
                              activeColor: AppColors.primary,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                      ),
                      if (slots.isNotEmpty) const Divider(height: 1),
                      // Slot rows
                      ...List.generate(slots.length, (slotIndex) {
                        final slot = slots[slotIndex];
                        if (slot == null) return const SizedBox.shrink();
                        final recipe = allRecipes.cast<Recipe?>().firstWhere(
                              (r) => r?.id == slot.recipeId,
                              orElse: () => null,
                            );
                        if (recipe == null) return const SizedBox.shrink();
                        return _SlotRow(
                          key: ValueKey('${day}_$slotIndex'),
                          recipe: recipe,
                          slotServings: slot.servings,
                          onEdit: () => _showRecipePicker(
                            context,
                            ref,
                            day,
                            slotIndex,
                            plan,
                            allRecipes,
                          ),
                          onRemove: () => ref
                              .read(mealPlanProvider.notifier)
                              .removeSlot(day, slotIndex),
                          onNavigate: () =>
                              context.push('/recipes/${recipe.id}'),
                          onServingsChanged: (servings) => ref
                              .read(mealPlanProvider.notifier)
                              .setSlotServings(day, slotIndex, servings),
                        );
                      }),
                      // Add slot button
                      const Divider(height: 1),
                      InkWell(
                        onTap: () => _addMeal(context, ref, day, allRecipes),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: Row(
                            children: [
                              Icon(
                                Icons.add,
                                size: 16,
                                color: AppColors.primary.withValues(alpha: 0.8),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l.mealPlanAddMeal,
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      AppColors.primary.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Future<void> _showRecipePicker(
    BuildContext context,
    WidgetRef ref,
    DateTime day,
    int slotIndex,
    MealPlan plan,
    List<Recipe> allRecipes,
  ) {
    final currentSlot = plan.getSlotsForDay(day)[slotIndex];

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _RecipePickerSheet(
        currentRecipeId: currentSlot?.recipeId,
        allRecipes: allRecipes,
        onPick: (recipe) => ref
            .read(mealPlanProvider.notifier)
            .setSlotRecipe(day, slotIndex, recipe?.id, recipeTitle: recipe?.title),
        onRemoveSlot: () => ref
            .read(mealPlanProvider.notifier)
            .removeSlot(day, slotIndex),
      ),
    );
  }

  Future<void> _addMeal(
    BuildContext context,
    WidgetRef ref,
    DateTime day,
    List<Recipe> allRecipes,
  ) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _RecipePickerSheet(
        currentRecipeId: null,
        allRecipes: allRecipes,
        onPick: (recipe) {
          if (recipe != null) {
            ref.read(mealPlanProvider.notifier).addRecipeToDay(day, recipe.id, recipeTitle: recipe.title);
          }
        },
      ),
    );
  }
}

class _SlotRow extends StatelessWidget {
  final Recipe recipe;
  final int? slotServings;
  final VoidCallback onEdit;
  final VoidCallback onRemove;
  final VoidCallback onNavigate;
  final ValueChanged<int?> onServingsChanged;

  const _SlotRow({
    super.key,
    required this.recipe,
    required this.slotServings,
    required this.onEdit,
    required this.onRemove,
    required this.onNavigate,
    required this.onServingsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final hasImage = recipe.imagePath != null;
    final effectiveServings = slotServings ?? recipe.servings;
    final hasOverride = slotServings != null && slotServings != recipe.servings;

    return InkWell(
      onTap: onNavigate,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, hasImage ? 8 : 10, 8, hasImage ? 8 : 10),
        child: Row(
          children: [
            if (hasImage) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.file(
                  File(recipe.imagePath!),
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      const SizedBox(width: 40, height: 40),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    recipe.title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  GestureDetector(
                    onTap: () =>
                        _showServingsDialog(context, l, effectiveServings),
                    child: Text(
                      l.detailServings(effectiveServings),
                      style: TextStyle(
                        fontSize: 12,
                        color: hasOverride
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 16),
              color: AppColors.textSecondary,
              onPressed: onEdit,
              tooltip: l.mealPlanChangeRecipe,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 16),
              color: AppColors.textSecondary,
              onPressed: onRemove,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showServingsDialog(
      BuildContext context, AppLocalizations l, int current) async {
    int value = current;

    final result = await showDialog<int?>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(l.mealPlanSetServings),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    iconSize: 28,
                    color: value > 1 ? AppColors.primary : AppColors.divider,
                    onPressed: value > 1
                        ? () => setState(() => value--)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '$value',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    iconSize: 28,
                    color: value < 99 ? AppColors.primary : AppColors.divider,
                    onPressed: value < 99
                        ? () => setState(() => value++)
                        : null,
                  ),
                ],
              ),
              if (recipe.servings != value) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, recipe.servings),
                  child: Text(
                    l.mealPlanResetServings,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, value),
              child: Text(l.save),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      // null override means "use recipe default"
      onServingsChanged(result == recipe.servings ? null : result);
    }
  }
}

class _RecipePickerSheet extends StatefulWidget {
  final String? currentRecipeId;
  final List<Recipe> allRecipes;
  final void Function(Recipe? recipe) onPick;
  final VoidCallback? onRemoveSlot;

  const _RecipePickerSheet({
    required this.currentRecipeId,
    required this.allRecipes,
    required this.onPick,
    this.onRemoveSlot,
  });

  @override
  State<_RecipePickerSheet> createState() => _RecipePickerSheetState();
}

class _RecipePickerSheetState extends State<_RecipePickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final filtered = widget.allRecipes
        .where((r) =>
            _query.isEmpty ||
            r.title.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l.mealPlanChooseRecipe,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: l.mealPlanSearchRecipes,
                  prefixIcon: const Icon(Icons.search, size: 20),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            const Divider(height: 1),
            if (widget.onRemoveSlot != null) ...[
              ListTile(
                leading: const Icon(Icons.delete_outline,
                    size: 20, color: AppColors.error),
                title: Text(
                  l.mealPlanRemoveMeal,
                  style: const TextStyle(color: AppColors.error),
                ),
                onTap: () {
                  Navigator.pop(context);
                  widget.onRemoveSlot!();
                },
              ),
              const Divider(height: 1),
            ],
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        l.mealPlanNoResults,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final recipe = filtered[index];
                        final isCurrent =
                            recipe.id == widget.currentRecipeId;
                        return ListTile(
                          title: Text(
                            recipe.title,
                            style: TextStyle(
                              fontSize: 15,
                              color: isCurrent
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                              fontWeight: isCurrent
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                          trailing: isCurrent
                              ? const Icon(Icons.check,
                                  color: AppColors.primary)
                              : null,
                          onTap: () {
                            widget.onPick(recipe);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
            ),
          ],
          ),
        );
      },
    );
  }
}
