import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../data/hive_boxes.dart';
import '../models/meal_plan.dart';
import '../models/shopping_item.dart';

class MealPlanRepository {
  Box<String> get _box => Hive.box<String>(HiveBoxes.mealPlan);

  static const _planKey = 'plan';
  static const _shoppingListKey = 'shopping_list';

  MealPlan loadPlan() {
    try {
      final json = _box.get(_planKey);
      if (json == null) return MealPlan.empty();
      return MealPlan.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      // Stored data is in an old incompatible format — start fresh.
      _box.delete(_planKey);
      return MealPlan.empty();
    }
  }

  void savePlan(MealPlan plan) =>
      _box.put(_planKey, jsonEncode(plan.toJson()));

  void clearPlan() => _box.delete(_planKey);

  ShoppingList loadShoppingList() {
    final json = _box.get(_shoppingListKey);
    if (json == null) return ShoppingList.empty();
    return ShoppingList.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  void saveShoppingList(ShoppingList list) =>
      _box.put(_shoppingListKey, jsonEncode(list.toJson()));
}
