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
import '../../widgets/empty_state.dart';

class MealPlanHistoryScreen extends ConsumerWidget {
  const MealPlanHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final history = ref.watch(mealPlanHistoryProvider);
    final allRecipes = ref.watch(recipeListProvider);
    final recipeMap = {for (final r in allRecipes) r.id: r};

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(l.mealPlanHistoryTitle)),
      body: history.isEmpty
          ? EmptyState(
              icon: Icons.history_outlined,
              message: l.mealPlanHistoryEmpty,
            )
          : _HistoryList(history: history, recipeMap: recipeMap, locale: locale),
    );
  }
}

// ── List with month group headers ─────────────────────────────────────────────

class _HistoryList extends StatelessWidget {
  final List<(DateTime, List<MealSlot>)> history;
  final Map<String, Recipe> recipeMap;
  final String locale;

  const _HistoryList({
    required this.history,
    required this.recipeMap,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    // Build a flat list interleaving month headers and day entries.
    final items = <_Item>[];
    String? lastMonth;
    for (final (date, slots) in history) {
      final month = DateFormat.yMMMM(locale).format(date);
      if (month != lastMonth) {
        items.add(_MonthItem(month));
        lastMonth = month;
      }
      items.add(_DayItem(date, slots));
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 24),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        if (item is _MonthItem) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
            child: Text(
              item.month,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                letterSpacing: 0.6,
              ),
            ),
          );
        }
        final entry = item as _DayItem;
        final dayLabel = DateFormat.MMMEd(locale).format(entry.date);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
              child: Text(
                dayLabel,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            ...entry.slots.map(
              (slot) => _HistoryTile(
                slot: slot,
                slotDate: entry.date,
                recipeMap: recipeMap,
              ),
            ),
            const Divider(height: 1, indent: 16),
          ],
        );
      },
    );
  }
}

// ── Sealed-like list item types ───────────────────────────────────────────────

abstract class _Item {}

class _MonthItem extends _Item {
  final String month;
  _MonthItem(this.month);
}

class _DayItem extends _Item {
  final DateTime date;
  final List<MealSlot> slots;
  _DayItem(this.date, this.slots);
}

// ── Single history tile ───────────────────────────────────────────────────────

class _HistoryTile extends StatelessWidget {
  final MealSlot slot;
  final DateTime slotDate;
  final Map<String, Recipe> recipeMap;

  const _HistoryTile({
    required this.slot,
    required this.slotDate,
    required this.recipeMap,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final recipe = recipeMap[slot.recipeId];

    final String title;
    final String? badge;
    final bool tappable;

    if (recipe == null) {
      title = slot.recipeTitle ?? '?';
      badge = l.mealPlanHistoryDeleted;
      tappable = false;
    } else {
      title = recipe.title;
      tappable = true;
      if (slot.recipeTitle != null && slot.recipeTitle != recipe.title) {
        badge = l.mealPlanHistoryRenamed;
      } else if (recipe.updatedAt.isAfter(slotDate)) {
        badge = l.mealPlanHistoryUpdated;
      } else {
        badge = null;
      }
    }

    final content = Padding(
      padding: const EdgeInsets.fromLTRB(16, 7, 16, 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: recipe == null
                    ? AppColors.textSecondary
                    : AppColors.textPrimary,
              ),
            ),
          ),
          if (badge != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    if (!tappable) return content;
    return InkWell(
      onTap: () => context.push('/recipes/${recipe!.id}'),
      child: content,
    );
  }
}
