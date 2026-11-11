import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../l10n/app_localizations.dart';
import '../../models/shopping_item.dart';
import '../../providers/meal_plan_providers.dart';
import '../../providers/recipe_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/settings_sheet.dart';

class ShoppingListScreen extends ConsumerWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final shoppingList = ref.watch(shoppingListProvider);
    final items = shoppingList.items;

    String? generatedLabel;
    if (shoppingList.generatedAt != null) {
      final dateStr = DateFormat.yMMMd(locale).format(shoppingList.generatedAt!);
      generatedLabel = l.shoppingGeneratedOn(dateStr);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l.shoppingListTitle,
              style: const TextStyle(fontWeight: FontWeight.bold),
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
            icon: const Icon(Icons.settings_outlined),
            tooltip: l.settingsTitle,
            onPressed: () => showSettingsSheet(context),
          ),
          if (items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.share_outlined),
              tooltip: l.shoppingShareTooltip,
              onPressed: () => _shareList(context, shoppingList),
            ),
          if (items.any((i) => i.checked))
            IconButton(
              icon: const Icon(Icons.remove_done_outlined),
              tooltip: l.shoppingClearCheckedTooltip,
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(l.shoppingClearCheckedTitle),
                    content: Text(l.shoppingClearCheckedBody),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(l.cancel),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(l.clear),
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
            tooltip: l.shoppingGenerateTooltip,
            onPressed: () async {
              final hasChecked = items.any((i) => i.checked);
              if (hasChecked) {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(l.shoppingRegenerateTitle),
                    content: Text(l.shoppingRegenerateBody),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(l.cancel),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(l.shoppingRegenerateAction),
                      ),
                    ],
                  ),
                );
                if (confirmed != true || !context.mounted) return;
              }
              ref.read(shoppingListProvider.notifier).generate(
                  ref.read(mealPlanSlotEntriesProvider),
                  ref.read(recipeListProvider),
                  AppLocalizations.of(context)!);
            },
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 2),
      body: items.isEmpty
          ? EmptyState(
              icon: Icons.shopping_cart_outlined,
              message: shoppingList.generatedAt == null
                  ? l.shoppingEmptyTitle
                  : l.shoppingEmptyGeneratedTitle,
              subMessage: shoppingList.generatedAt == null
                  ? l.shoppingEmptySubtitle
                  : l.shoppingEmptyGeneratedSubtitle,
              action: TextButton(
                onPressed: () => context.go('/meal-plan'),
                child: Text(l.shoppingGoToMealPlan),
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
                        dense: true,
                        visualDensity: const VisualDensity(vertical: -2),
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

void _shareList(BuildContext context, ShoppingList list) {
  final l = AppLocalizations.of(context)!;
  final pending = list.items.where((i) => !i.checked).toList();
  final String body;
  if (pending.isEmpty) {
    body = l.shoppingShareCheckedOff;
  } else {
    body = pending.map((i) {
      final amount = i.amount.isNotEmpty ? '${i.amount}  ' : '';
      return '• $amount${i.name}';
    }).join('\n');
  }
  Share.share('${l.shoppingShareHeader}\n${'─' * 20}\n$body');
}
