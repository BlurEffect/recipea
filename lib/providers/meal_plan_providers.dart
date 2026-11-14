import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/seed_data.dart';
import '../l10n/app_localizations.dart';
import '../models/ingredient.dart';
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

  void setSlotRecipe(DateTime date, int index, String? recipeId, {String? recipeTitle}) =>
      _save(state.setSlotRecipe(date, index, recipeId, recipeTitle: recipeTitle));

  void setSlotServings(DateTime date, int index, int? servings) =>
      _save(state.setSlotServings(date, index, servings));

  /// Adds the recipe as a new slot at the end of the day's list.
  void addRecipeToDay(DateTime date, String recipeId, {String? recipeTitle}) =>
      _save(state.addRecipeToDay(date, recipeId, recipeTitle: recipeTitle));

  void toggleDayExcluded(DateTime date) =>
      _save(state.toggleExcludedDate(date));

  void clear() => _save(MealPlan.empty());

  /// Merges historical past-date slots from an imported backup.
  /// Only adds date keys not already present locally; never touches today/future.
  void mergeHistory(Map<String, List<MealSlot?>> importedSlots) {
    final today = DateTime.now();
    final todayKey = '${today.year}-'
        '${today.month.toString().padLeft(2, '0')}-'
        '${today.day.toString().padLeft(2, '0')}';
    final merged = Map<String, List<MealSlot?>>.from(state.daySlots);
    bool changed = false;
    for (final entry in importedSlots.entries) {
      if (entry.key.compareTo(todayKey) >= 0) continue;
      if (merged.containsKey(entry.key)) continue;
      merged[entry.key] = entry.value;
      changed = true;
    }
    if (changed) _save(state.copyWith(daySlots: merged));
  }
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
      .whereType<MealSlot>()
      .map((s) => s.recipeId)
      .toList();
  final recipeMap = {
    for (final r in ref.watch(recipeListProvider)) r.id: r,
  };
  return allIds.map((id) => recipeMap[id]).whereType<Recipe>().toList();
});

/// All (recipe, slotServings?) entries for included days in the 7-day window.
/// Used by shopping list generation to apply correct per-slot serving scale.
final mealPlanSlotEntriesProvider =
    Provider<List<({Recipe recipe, int? slotServings})>>((ref) {
  final plan = ref.watch(mealPlanProvider);
  final today = DateTime.now();
  final recipeMap = {
    for (final r in ref.watch(recipeListProvider)) r.id: r,
  };
  final entries = <({Recipe recipe, int? slotServings})>[];
  for (int i = 0; i < 7; i++) {
    final d = today.add(Duration(days: i));
    final day = DateTime(d.year, d.month, d.day);
    if (!plan.isDayIncluded(day)) continue;
    for (final slot in plan.getSlotsForDay(day)) {
      if (slot == null) continue;
      final recipe = recipeMap[slot.recipeId];
      if (recipe == null) continue;
      entries.add((recipe: recipe, slotServings: slot.servings));
    }
  }
  return entries;
});

// ---------------------------------------------------------------------------
// Shopping List
// ---------------------------------------------------------------------------

class ShoppingListNotifier extends StateNotifier<ShoppingList> {
  ShoppingListNotifier(this._repo) : super(_repo.loadShoppingList());

  final MealPlanRepository _repo;

  void generate(
    List<({Recipe recipe, int? slotServings})> slotEntries,
    List<Recipe> allRecipes,
    AppLocalizations l,
  ) {
    state = ShoppingList(
      items: _buildShoppingItems(slotEntries, allRecipes, l),
      generatedAt: DateTime.now(),
    );
    _repo.saveShoppingList(state);
  }

  void toggle(int index) {
    final items = [...state.items];
    final item = items.removeAt(index);
    final nowChecked = !item.checked;
    final updated = item.copyWith(checked: nowChecked);
    if (nowChecked) {
      items.add(updated);
    } else {
      final insertAt = items.indexWhere((i) => i.checked);
      items.insert(insertAt == -1 ? items.length : insertAt, updated);
    }
    state = state.copyWith(items: items);
    _repo.saveShoppingList(state);
  }

  void reorder(int oldIndex, int newIndex) {
    final items = [...state.items];
    if (newIndex > oldIndex) newIndex--;
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
    state = state.copyWith(items: items);
    _repo.saveShoppingList(state);
  }

  void removeChecked() {
    state = state.copyWith(
        items: state.items.where((i) => !i.checked).toList());
    _repo.saveShoppingList(state);
  }
}

final shoppingListProvider =
    StateNotifierProvider<ShoppingListNotifier, ShoppingList>(
  (ref) => ShoppingListNotifier(ref.read(mealPlanRepositoryProvider)),
);

// ---------------------------------------------------------------------------
// Last cooked map (recipeId → most recent past cook date)
// ---------------------------------------------------------------------------

/// Derives a map of recipeId → most recent date (before today) that the recipe
/// (or any composite that contains it) appeared in a meal plan slot.
final lastCookedMapProvider = Provider<Map<String, DateTime>>((ref) {
  final plan = ref.watch(mealPlanProvider);
  final allRecipes = ref.watch(recipeListProvider);
  final recipeMap = {for (final r in allRecipes) r.id: r};
  final today = DateTime.now();
  final todayMidnight = DateTime(today.year, today.month, today.day);
  final result = <String, DateTime>{};

  for (final entry in plan.daySlots.entries) {
    final date = DateTime.tryParse(entry.key);
    if (date == null || !date.isBefore(todayMidnight)) continue;
    for (final slot in entry.value.whereType<MealSlot>()) {
      final recipeId = slot.recipeId;
      final recipe = recipeMap[recipeId];
      final ids = <String>{recipeId};
      if (recipe != null) ids.addAll(allLinkedRecipeIds(recipe, allRecipes));
      for (final id in ids) {
        final current = result[id];
        if (current == null || date.isAfter(current)) result[id] = date;
      }
    }
  }
  return result;
});

// ---------------------------------------------------------------------------
// Meal plan history (past-date slots, newest first)
// ---------------------------------------------------------------------------

/// Returns past day entries (before today midnight) sorted newest-first.
/// Each entry is a `(date, List<MealSlot>)` record — empty-slot days are omitted.
final mealPlanHistoryProvider = Provider<List<(DateTime, List<MealSlot>)>>((ref) {
  final plan = ref.watch(mealPlanProvider);
  final today = DateTime.now();
  final todayMidnight = DateTime(today.year, today.month, today.day);

  final entries = <(DateTime, List<MealSlot>)>[];
  for (final entry in plan.daySlots.entries) {
    final date = DateTime.tryParse(entry.key);
    if (date == null || !date.isBefore(todayMidnight)) continue;
    final slots = entry.value.whereType<MealSlot>().toList();
    if (slots.isEmpty) continue;
    entries.add((date, slots));
  }
  entries.sort((a, b) => b.$1.compareTo(a.$1));
  return entries;
});

// ---------------------------------------------------------------------------
// Ingredient accumulation with correct composite/serving scaling
// ---------------------------------------------------------------------------

List<ShoppingItem> _buildShoppingItems(
    List<({Recipe recipe, int? slotServings})> slotEntries,
    List<Recipe> allRecipes,
    AppLocalizations l) {
  // Key: (name, normalizedUnit, note) — normalized so "can"/"dose" group together.
  final Map<(String, String, String), double> numeric = {};
  // Key: (name, note) — no-quantity ingredients, deduplicated.
  final Set<(String, String)> noteOnly = {};

  for (final entry in slotEntries) {
    final recipe = entry.recipe;
    final effectiveServings = entry.slotServings ?? recipe.servings;
    final topScale =
        recipe.servings > 0 ? effectiveServings / recipe.servings : 1.0;
    _accumulateIngredients(recipe, allRecipes, topScale, numeric, noteOnly, l, {});
  }

  final items = <ShoppingItem>[];

  for (final entry in numeric.entries) {
    final (name, unit, note) = entry.key;
    // Store structured data so the screen can re-localize on locale change.
    items.add(ShoppingItem(
      name: _toTitleCase(name),
      quantity: entry.value,
      unitKey: unit,
      note: note.isNotEmpty ? note : null,
    ));
  }

  for (final (name, note) in noteOnly) {
    items.add(ShoppingItem(
      name: _toTitleCase(name),
      unitKey: '',
      note: note.isNotEmpty ? note : null,
    ));
  }

  items.sort((a, b) => a.name.compareTo(b.name));
  return items;
}

/// Recursively accumulates scaled ingredients from [recipe] and its linked
/// components. [scale] is the multiplier relative to the recipe's own serving
/// count (1.0 = cook exactly as written).
void _accumulateIngredients(
    Recipe recipe,
    List<Recipe> allRecipes,
    double scale,
    Map<(String, String, String), double> numeric,
    Set<(String, String)> noteOnly,
    AppLocalizations l,
    Set<String> visited) {
  if (visited.contains(recipe.id)) return;
  visited.add(recipe.id);

  for (final ing in recipe.ingredients) {
    _addIngredient(ing, scale, numeric, noteOnly, l);
  }

  for (final linkedId in recipe.linkedRecipeIds) {
    final linked = allRecipes.cast<Recipe?>().firstWhere(
          (r) => r?.id == linkedId,
          orElse: () => null,
        );
    if (linked == null) continue;
    // Per-component scale mirrors the detail-screen formula:
    // composite uses (composite.servings / component.servings) fraction of each component.
    final componentScale =
        linked.servings > 0 ? scale * recipe.servings / linked.servings : scale;
    _accumulateIngredients(
        linked, allRecipes, componentScale, numeric, noteOnly, l, visited);
  }
}

void _addIngredient(
    Ingredient ing,
    double scale,
    Map<(String, String, String), double> numeric,
    Set<(String, String)> noteOnly,
    AppLocalizations l) {
  final name = ing.name.trim().toLowerCase();
  final note = (ing.note ?? '').trim();
  if (ing.quantity != null) {
    // Normalize unit so old "can" and new "dose" (DE) group together.
    final unit = localizeUnit((ing.unit ?? '').toLowerCase(), l).toLowerCase();
    final key = (name, unit, note);
    numeric[key] = (numeric[key] ?? 0.0) + ing.quantity! * scale;
  } else {
    noteOnly.add((name, note));
  }
}

String _toTitleCase(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
