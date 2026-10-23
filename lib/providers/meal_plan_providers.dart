import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/meal_plan.dart';
import '../models/recipe.dart';
import '../models/shopping_item.dart';
import '../repositories/meal_plan_repository.dart';
import '../utils/recipe_graph.dart';
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

  void generate(List<Recipe> planRecipes, List<Recipe> allRecipes) {
    state = ShoppingList(
      items: _buildShoppingItems(planRecipes, allRecipes),
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

List<ShoppingItem> _buildShoppingItems(
    List<Recipe> recipes, List<Recipe> allRecipes) {
  // Key: (name, unit, note) — ingredients with different notes stay separate.
  final Map<(String, String, String), double> numeric = {};
  // Key: (name, note) — note-only ingredients, deduplicated.
  final Set<(String, String)> noteOnly = {};

  for (final recipe in recipes) {
    for (final ing in allIngredients(recipe, allRecipes)) {
      final name = ing.name.trim().toLowerCase();
      final note = (ing.note ?? '').trim();
      if (ing.quantity != null) {
        final unit = (ing.unit ?? '').toLowerCase();
        final key = (name, unit, note);
        numeric[key] = (numeric[key] ?? 0.0) + ing.quantity!;
      } else {
        noteOnly.add((name, note));
      }
    }
  }

  final items = <ShoppingItem>[];

  for (final entry in numeric.entries) {
    final (name, unit, note) = entry.key;
    final amountStr = _formatValue(entry.value, unit);
    items.add(ShoppingItem(
      name: _toTitleCase(name),
      amount: note.isNotEmpty ? '$amountStr ($note)' : amountStr,
    ));
  }

  for (final (name, note) in noteOnly) {
    items.add(ShoppingItem(
      name: _toTitleCase(name),
      amount: note,
    ));
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
