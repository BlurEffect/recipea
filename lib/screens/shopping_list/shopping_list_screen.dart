import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/meal_plan_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../../widgets/empty_state.dart';

class ShoppingListScreen extends ConsumerWidget {
  const ShoppingListScreen({super.key});

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shoppingList = ref.watch(shoppingListProvider);
    final planRecipes = ref.watch(mealPlanRecipesProvider);
    final items = shoppingList.items;

    String? generatedLabel;
    if (shoppingList.generatedAt != null) {
      final d = shoppingList.generatedAt!;
      generatedLabel =
          'Generated ${_months[d.month - 1]} ${d.day}, ${d.year}';
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Shopping List',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            if (generatedLabel != null)
              Text(
                generatedLabel,
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
            icon: const Icon(Icons.refresh),
            tooltip: 'Regenerate from meal plan',
            onPressed: () {
              ref.read(shoppingListProvider.notifier).generate(planRecipes);
            },
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 2),
      body: items.isEmpty
          ? EmptyState(
              icon: Icons.shopping_cart_outlined,
              message: shoppingList.generatedAt == null
                  ? 'No shopping list yet'
                  : 'Shopping list is empty',
              subMessage: shoppingList.generatedAt == null
                  ? 'Assign recipes in your Meal Plan, then tap refresh to generate'
                  : 'Your meal plan has no ingredients to list',
              action: TextButton(
                onPressed: () => context.go('/meal-plan'),
                child: const Text('Go to Meal Plan'),
              ),
            )
          : ListView.builder(
              // Key forces a full rebuild when the list is regenerated,
              // so stale checkbox states don't linger.
              key: ValueKey(shoppingList.generatedAt?.millisecondsSinceEpoch),
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return CheckboxListTile(
                  value: item.checked,
                  onChanged: (_) =>
                      ref.read(shoppingListProvider.notifier).toggle(index),
                  activeColor: AppColors.primary,
                  title: Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 15,
                      color: item.checked
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                      decoration:
                          item.checked ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: item.amount.isNotEmpty
                      ? Text(
                          item.amount,
                          style: TextStyle(
                            fontSize: 13,
                            color: item.checked
                                ? AppColors.textSecondary
                                    .withValues(alpha: 0.6)
                                : AppColors.primary,
                            fontWeight: FontWeight.w500,
                            decoration: item.checked
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        )
                      : null,
                );
              },
            ),
    );
  }
}
