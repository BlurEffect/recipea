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

// ── Accordion list with month-chip navigation ─────────────────────────────────

class _HistoryList extends StatefulWidget {
  final List<(DateTime, List<MealSlot>)> history;
  final Map<String, Recipe> recipeMap;
  final String locale;

  const _HistoryList({
    required this.history,
    required this.recipeMap,
    required this.locale,
  });

  @override
  State<_HistoryList> createState() => _HistoryListState();
}

class _HistoryListState extends State<_HistoryList> {
  String? _expandedMonthKey;
  final _scrollController = ScrollController();
  final _chipScrollController = ScrollController();

  // Estimated heights for scroll offset calculation.
  // Month header is an InkWell with 14px vert padding + ~20px text = ~48px.
  static const double _kMonthHeaderHeight = 48.0;
  // Year divider row: 32px top padding + ~16px text + 8px bottom = ~56px.
  static const double _kYearDividerHeight = 48.0;

  @override
  void dispose() {
    _scrollController.dispose();
    _chipScrollController.dispose();
    super.dispose();
  }

  // ── Data grouping ───────────────────────────────────────────────────────────

  Map<String, List<(DateTime, List<MealSlot>)>> _buildByMonth() {
    final map = <String, List<(DateTime, List<MealSlot>)>>{};
    for (final entry in widget.history) {
      final d = entry.$1;
      final key = '${d.year}-${d.month.toString().padLeft(2, '0')}';
      map.putIfAbsent(key, () => []).add(entry);
    }
    return map; // preserves insertion order = newest first
  }

  // ── Accordion interaction ───────────────────────────────────────────────────

  void _expandMonth(String key, List<String> monthKeys) {
    setState(() => _expandedMonthKey = key);

    // Compute target scroll offset: all months above key are collapsed
    // (just headers + year dividers), so we can sum exact fixed heights.
    double offset = 0;
    int? lastYear;
    for (final mk in monthKeys) {
      final year = int.parse(mk.split('-')[0]);
      if (lastYear != null && year != lastYear) {
        offset += _kYearDividerHeight;
      }
      lastYear = year;
      if (mk == key) break;
      offset += _kMonthHeaderHeight;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          offset.clamp(0.0, _scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  // ── Flat item list ──────────────────────────────────────────────────────────

  List<_Item> _buildItems(
    Map<String, List<(DateTime, List<MealSlot>)>> byMonth,
    List<String> monthKeys,
  ) {
    final items = <_Item>[];
    int? lastYear;
    for (final key in monthKeys) {
      final year = int.parse(key.split('-')[0]);
      if (lastYear != null && year != lastYear) {
        items.add(_YearItem(year));
      }
      lastYear = year;
      final isExpanded = key == _expandedMonthKey;
      items.add(_MonthHeaderItem(key, isExpanded));
      if (isExpanded) {
        for (final entry in byMonth[key]!) {
          items.add(_DayItem(entry.$1, entry.$2));
        }
      }
    }
    return items;
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final byMonth = _buildByMonth();
    final monthKeys = byMonth.keys.toList();

    // Initialise / repair expanded key.
    if (_expandedMonthKey == null && monthKeys.isNotEmpty) {
      _expandedMonthKey = monthKeys.first;
    } else if (_expandedMonthKey != null &&
        !byMonth.containsKey(_expandedMonthKey)) {
      _expandedMonthKey = monthKeys.isNotEmpty ? monthKeys.first : null;
    }

    final items = _buildItems(byMonth, monthKeys);

    return Column(
      children: [
        _buildChipStrip(monthKeys),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: items.length,
            itemBuilder: (context, index) =>
                _buildItem(context, items[index], byMonth, monthKeys),
          ),
        ),
      ],
    );
  }

  Widget _buildItem(
    BuildContext context,
    _Item item,
    Map<String, List<(DateTime, List<MealSlot>)>> byMonth,
    List<String> monthKeys,
  ) {
    if (item is _YearItem) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
        child: Row(children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '${item.year}',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Expanded(child: Divider()),
        ]),
      );
    }

    if (item is _MonthHeaderItem) {
      final parts = item.key.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final label = DateFormat.MMMM(widget.locale).format(DateTime(year, month));
      final dayCount = byMonth[item.key]!.length;

      return InkWell(
        onTap: () => _expandMonth(item.key, monthKeys),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Text(
              '$dayCount',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              item.expanded ? Icons.expand_less : Icons.expand_more,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ]),
        ),
      );
    }

    final entry = item as _DayItem;
    final dayLabel =
        DateFormat.MMMEd(widget.locale).format(entry.date);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
          child: Text(
            dayLabel,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        ...entry.slots.map(
          (slot) => _HistoryTile(
            slot: slot,
            slotDate: entry.date,
            recipeMap: widget.recipeMap,
          ),
        ),
        const Divider(height: 1, indent: 16),
      ],
    );
  }

  // ── Month chip strip ────────────────────────────────────────────────────────

  Widget _buildChipStrip(List<String> monthKeys) {
    final chips = <Widget>[];
    int? lastYear;

    for (int i = 0; i < monthKeys.length; i++) {
      final key = monthKeys[i];
      final parts = key.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);

      // Year label before the first month of each year.
      if (year != lastYear) {
        if (chips.isNotEmpty) chips.add(const SizedBox(width: 6));
        chips.add(Center(
          child: Text(
            '$year',
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ));
        chips.add(const SizedBox(width: 6));
        lastYear = year;
      }

      final isSelected = key == _expandedMonthKey;
      final label =
          DateFormat.MMM(widget.locale).format(DateTime(year, month));

      chips.add(
        GestureDetector(
          onTap: () => _expandMonth(key, monthKeys),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.divider,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 44,
      child: ListView(
        controller: _chipScrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        children: chips,
      ),
    );
  }
}

// ── Item types ────────────────────────────────────────────────────────────────

abstract class _Item {}

class _YearItem extends _Item {
  final int year;
  _YearItem(this.year);
}

class _MonthHeaderItem extends _Item {
  final String key;
  final bool expanded;
  _MonthHeaderItem(this.key, this.expanded);
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
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Row(children: [
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
      ]),
    );

    if (!tappable) return content;
    return InkWell(
      onTap: () => context.push('/recipes/${recipe!.id}'),
      child: content,
    );
  }
}
