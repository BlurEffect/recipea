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

  void clear() => _save(MealPlan.empty());
}

final mealPlanProvider = StateNotifierProvider<MealPlanNotifier, MealPlan>(
  (ref) => MealPlanNotifier(ref.read(mealPlanRepositoryProvider)),
);

/// All unique recipes currently assigned anywhere in the active meal plan.
final mealPlanRecipesProvider = Provider<List<Recipe>>((ref) {
  final ids = ref.watch(mealPlanProvider).assignedRecipeIds;
  return ref.watch(recipeListProvider).where((r) => ids.contains(r.id)).toList();
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
  final Map<String, List<String>> grouped = {};
  for (final recipe in recipes) {
    for (final ing in recipe.ingredients) {
      final key = ing.name.trim().toLowerCase();
      grouped.putIfAbsent(key, () => []).add(ing.amount.trim());
    }
  }

  final items = grouped.entries.map((entry) {
    return ShoppingItem(
      name: _toTitleCase(entry.key),
      amount: _accumulateAmounts(entry.value),
    );
  }).toList();

  items.sort((a, b) => a.name.compareTo(b.name));
  return items;
}

String _toTitleCase(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

/// Sums amounts that share the same unit and are numeric (including fractions).
/// Falls back to joining with ' + ' when units differ or parsing fails.
String _accumulateAmounts(List<String> amounts) {
  if (amounts.length == 1) return amounts.first;

  final parsed = amounts.map(_parseAmount).toList();
  if (parsed.every((p) => p != null)) {
    final units = parsed.map((p) => p!.$2).toSet();
    if (units.length == 1) {
      final total = parsed.fold<double>(0, (sum, p) => sum + p!.$1);
      final unit = units.first;
      final totalStr = total == total.truncateToDouble()
          ? total.toInt().toString()
          : total.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
      return unit.isEmpty ? totalStr : '$totalStr $unit';
    }
  }
  return amounts.join(' + ');
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
