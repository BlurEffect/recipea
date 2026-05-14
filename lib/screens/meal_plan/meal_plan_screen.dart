import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/meal_plan.dart';
import '../../models/recipe.dart';
import '../../providers/meal_plan_providers.dart';
import '../../providers/recipe_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../../widgets/empty_state.dart';

class MealPlanScreen extends ConsumerWidget {
  const MealPlanScreen({super.key});

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(mealPlanProvider);
    final allRecipes = ref.watch(recipeListProvider);

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
          children: const [
            Text(
              'Meal Plan',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Check days to include in shopping list',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'clear') {
                showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Clear meal plan?'),
                    content: const Text(
                        'All recipe assignments will be removed.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Clear',
                          style: TextStyle(color: AppColors.error),
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
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'clear',
                child: Text(
                  'Clear plan',
                  style: TextStyle(color: AppColors.error),
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
              message: 'No recipes yet',
              subMessage:
                  'Add some recipes first, then plan your meals here',
              action: TextButton(
                onPressed: () => context.go('/recipes'),
                child: const Text('Go to Recipes'),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: days.length,
              itemBuilder: (context, index) {
                final day = days[index];
                final isToday = index == 0;
                final dayLabel =
                    '${_weekdays[day.weekday - 1]}, ${_months[day.month - 1]} ${day.day}';
                final header = isToday ? 'Today — $dayLabel' : dayLabel;
                final slots = plan.getSlotsForDay(day);

                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Day header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
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
                        final recipeId = slots[slotIndex];
                        final recipe = recipeId == null
                            ? null
                            : allRecipes.cast<Recipe?>().firstWhere(
                                  (r) => r?.id == recipeId,
                                  orElse: () => null,
                                );
                        return _SlotRow(
                          recipe: recipe,
                          onTap: () => _showRecipePicker(
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
                        );
                      }),
                      // Add slot button
                      const Divider(height: 1),
                      InkWell(
                        onTap: () =>
                            ref.read(mealPlanProvider.notifier).addSlot(day),
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
                                'Add meal',
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
    final currentRecipeId = plan.getSlotsForDay(day)[slotIndex];

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _RecipePickerSheet(
        currentRecipeId: currentRecipeId,
        allRecipes: allRecipes,
        onPick: (recipeId) => ref
            .read(mealPlanProvider.notifier)
            .setSlotRecipe(day, slotIndex, recipeId),
      ),
    );
  }
}

class _SlotRow extends StatelessWidget {
  final Recipe? recipe;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _SlotRow({
    required this.recipe,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: recipe != null
                  ? Text(
                      recipe!.title,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  : Text(
                      'Tap to choose a recipe...',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary.withValues(alpha: 0.7),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
            ),
            GestureDetector(
              onTap: onRemove,
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipePickerSheet extends StatefulWidget {
  final String? currentRecipeId;
  final List<Recipe> allRecipes;
  final void Function(String? recipeId) onPick;

  const _RecipePickerSheet({
    required this.currentRecipeId,
    required this.allRecipes,
    required this.onPick,
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
        return Column(
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
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Choose a recipe',
                  style: TextStyle(
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
                decoration: const InputDecoration(
                  hintText: 'Search recipes...',
                  prefixIcon: Icon(Icons.search, size: 20),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(
                      child: Text(
                        'No recipes found',
                        style:
                            TextStyle(color: AppColors.textSecondary),
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
                            widget.onPick(recipe.id);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
