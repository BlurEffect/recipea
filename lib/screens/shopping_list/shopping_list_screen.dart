import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/shopping_item.dart';
import '../../providers/meal_plan_providers.dart';
import '../../providers/recipe_providers.dart';
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
          if (items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.share_outlined),
              tooltip: 'Share list',
              onPressed: () => _shareList(shoppingList),
            ),
          if (items.any((i) => i.checked))
            IconButton(
              icon: const Icon(Icons.remove_done_outlined),
              tooltip: 'Clear checked',
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Clear checked items?'),
                    content: const Text(
                        'Checked-off items will be permanently removed from the list.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  ref.read(shoppingListProvider.notifier).removeChecked();
                }
              },
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Regenerate from meal plan',
            onPressed: () async {
              final hasChecked = items.any((i) => i.checked);
              if (hasChecked) {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Regenerate list?'),
                    content: const Text(
                        'Your checked-off items will be lost.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Regenerate'),
                      ),
                    ],
                  ),
                );
                if (confirmed != true || !context.mounted) return;
              }
              ref.read(shoppingListProvider.notifier).generate(
                  ref.read(mealPlanRecipesProvider),
                  ref.read(recipeListProvider));
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
          : ReorderableListView.builder(
              key: ValueKey(shoppingList.generatedAt?.millisecondsSinceEpoch ?? 0),
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              onReorder: (oldIndex, newIndex) => ref
                  .read(shoppingListProvider.notifier)
                  .reorder(oldIndex, newIndex),
              itemBuilder: (context, index) {
                final item = items[index];
                return Row(
                  key: ValueKey('${item.name}_${item.amount}_$index'),
                  children: [
                    Expanded(
                      child: CheckboxListTile(
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
                      ),
                    ),
                    ReorderableDragStartListener(
                      index: index,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Icon(Icons.drag_handle, color: AppColors.divider),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

void _shareList(ShoppingList list) {
  final pending = list.items.where((i) => !i.checked).toList();
  final String body;
  if (pending.isEmpty) {
    body = 'Everything has been checked off!';
  } else {
    body = pending.map((i) {
      final amount = i.amount.isNotEmpty ? '${i.amount}  ' : '';
      return '• $amount${i.name}';
    }).join('\n');
  }
  Share.share('Shopping List\n${'─' * 20}\n$body');
}
