import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/meal_plan.dart';
import '../models/recipe.dart';
import '../models/shopping_item.dart';
import '../repositories/meal_plan_repository.dart';
import 'recipe_providers.dart';

final mealPlanRepositoryProvider = Provider<MealPlanRepository>(
  (_) => MealPlanRepository(),
);

// ---------------------------------------------------------------------------
// Meal Plan
// ---------------------------------------------------------------------------

class MealPlanNotifier extends StateNotifier<MealPlan> {
  MealPlanNotifier(this._repo) : super(_repo.loadPlan());

  final MealPlanRepository _repo;

  void _save(MealPlan updated) {
    state = updated;
    _repo.savePlan(updated);
  }

  void addSlot(DateTime date) => _save(state.addSlot(date));

  void removeSlot(DateTime date, int index) =>
      _save(state.removeSlot(date, index));

  void setSlotRecipe(DateTime date, int index, String? recipeId) =>
      _save(state.setSlotRecipe(date, index, recipeId));

  /// Adds the recipe as a new slot at the end of the day's list.
  void addRecipeToDay(DateTime date, String recipeId) =>
      _save(state.addRecipeToDay(date, recipeId));

  void toggleDayExcluded(DateTime date) =>
      _save(state.toggleExcludedDate(date));

  void clear() => _save(MealPlan.empty());
}

final mealPlanProvider = StateNotifierProvider<MealPlanNotifier, MealPlan>(
  (ref) => MealPlanNotifier(ref.read(mealPlanRepositoryProvider)),
);

/// All recipe slot assignments within the current 7-day rolling window,
/// including duplicates (same recipe on multiple days counts multiple times).
final mealPlanRecipesProvider = Provider<List<Recipe>>((ref) {
  final plan = ref.watch(mealPlanProvider);
  final today = DateTime.now();
  final allIds = List.generate(7, (i) => today.add(Duration(days: i)))
      .where((d) => plan.isDayIncluded(d))
      .expand((d) => plan.getSlotsForDay(d))
      .whereType<String>()
      .toList();
  final recipeMap = {
    for (final r in ref.watch(recipeListProvider)) r.id: r,
  };
  return allIds.map((id) => recipeMap[id]).whereType<Recipe>().toList();
});

// ---------------------------------------------------------------------------
// Shopping List
// ---------------------------------------------------------------------------

class ShoppingListNotifier extends StateNotifier<ShoppingList> {
  ShoppingListNotifier(this._repo) : super(_repo.loadShoppingList());

  final MealPlanRepository _repo;

  void generate(List<Recipe> recipes) {
    state = ShoppingList(
      items: _buildShoppingItems(recipes),
      generatedAt: DateTime.now(),
    );
    _repo.saveShoppingList(state);
  }

  void toggle(int index) {
    final items = [...state.items];
    items[index] = items[index].copyWith(checked: !items[index].checked);
    state = state.copyWith(items: items);
    _repo.saveShoppingList(state);
  }
}

final shoppingListProvider =
    StateNotifierProvider<ShoppingListNotifier, ShoppingList>(
  (ref) => ShoppingListNotifier(ref.read(mealPlanRepositoryProvider)),
);

// ---------------------------------------------------------------------------
// Ingredient accumulation
// ---------------------------------------------------------------------------

List<ShoppingItem> _buildShoppingItems(List<Recipe> recipes) {
  final Map<String, Map<String, double>> numeric = {};
  final Map<String, List<String>> raw = {};

  for (final recipe in recipes) {
    for (final ing in recipe.ingredients) {
      final name = ing.name.trim().toLowerCase();
      final amount = ing.amount.trim();
      final parsed = _parseAmount(amount);
      if (parsed != null) {
        final unitMap = numeric.putIfAbsent(name, () => <String, double>{});
        unitMap[parsed.$2] = (unitMap[parsed.$2] ?? 0.0) + parsed.$1;
      } else {
        raw.putIfAbsent(name, () => <String>[]).add(amount);
      }
    }
  }

  final items = <ShoppingItem>[];
  for (final numEntry in numeric.entries) {
    for (final unitEntry in numEntry.value.entries) {
      items.add(ShoppingItem(
        name: _toTitleCase(numEntry.key),
        amount: _formatValue(unitEntry.value, unitEntry.key),
      ));
    }
  }
  for (final rawEntry in raw.entries) {
    for (final amt in rawEntry.value) {
      items.add(ShoppingItem(name: _toTitleCase(rawEntry.key), amount: amt));
    }
  }

  items.sort((a, b) => a.name.compareTo(b.name));
  return items;
}

String _toTitleCase(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

String _formatValue(double value, String unit) {
  final s = value == value.truncateToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
  return unit.isEmpty ? s : '$s $unit';
}

/// Parses "2 cups" → (2.0, "cups"), "1/2" → (0.5, ""), "100g" → (100.0, "g").
/// Returns null if the string doesn't start with a recognisable number.
(double, String)? _parseAmount(String amount) {
  final match =
      RegExp(r'^(\d+(?:\.\d+)?(?:/\d+)?)\s*(.*)$').firstMatch(amount.trim());
  if (match == null) return null;

  final numStr = match.group(1)!;
  final unit = match.group(2)!.trim().toLowerCase();

  double? value;
  if (numStr.contains('/')) {
    final parts = numStr.split('/');
    final n = double.tryParse(parts[0]);
    final d = double.tryParse(parts[1]);
    if (n != null && d != null && d != 0) value = n / d;
  } else {
    value = double.tryParse(numStr);
  }

  if (value == null) return null;
  return (value, unit);
}
