import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../data/hive_boxes.dart';
import '../models/category_definition.dart';

class CategoryRepository {
  Box<String> get _box => Hive.box<String>(HiveBoxes.categories);

  List<CategoryDefinition> getAll() {
    return _box.values
        .map((json) => CategoryDefinition.fromJson(
            jsonDecode(json) as Map<String, dynamic>))
        .toList();
  }

  Future<void> save(CategoryDefinition category) async {
    await _box.put(category.id, jsonEncode(category.toJson()));
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  /// Seeds categories only when the box is empty (first launch).
  Future<void> seedIfEmpty(List<CategoryDefinition> defaults) async {
    if (_box.isEmpty) {
      for (final c in defaults) {
        await _box.put(c.id, jsonEncode(c.toJson()));
      }
    }
  }

  /// Merges imported categories: skips any ID that already exists locally.
  Future<void> mergeAll(List<Map<String, dynamic>> jsonList) async {
    for (final map in jsonList) {
      final id = map['id'] as String;
      if (!_box.containsKey(id)) {
        await _box.put(id, jsonEncode(map));
      }
    }
  }
}
