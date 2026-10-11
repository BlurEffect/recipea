import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../data/hive_boxes.dart';
import '../data/tag_definitions.dart';

class CustomTagRepository {
  Box<String> get _box => Hive.box<String>(HiveBoxes.customTags);

  List<TagDefinition> getAll() {
    return _box.values
        .map((json) => _fromJson(jsonDecode(json) as Map<String, dynamic>))
        .toList();
  }

  Future<void> save(TagDefinition tag) async {
    await _box.put(tag.id, jsonEncode(_toJson(tag)));
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  /// Seeds tags only when the box is empty (first launch).
  Future<void> seedIfEmpty(List<TagDefinition> defaults) async {
    if (_box.isEmpty) {
      for (final t in defaults) {
        await _box.put(t.id, jsonEncode(_toJson(t)));
      }
    }
  }

  /// Merges imported tags: silently skips any ID that already exists locally.
  void mergeAll(List<Map<String, dynamic>> tagJsonList) {
    for (final map in tagJsonList) {
      final id = map['id'] as String;
      if (!_box.containsKey(id)) {
        _box.put(id, jsonEncode(map));
      }
    }
  }

  static TagDefinition _fromJson(Map<String, dynamic> json) {
    return TagDefinition(
      id: json['id'] as String,
      label: json['label'] as String,
      category: json['category'] as String,
      isCustom: json['isCustom'] as bool? ?? true,
    );
  }

  static Map<String, dynamic> _toJson(TagDefinition tag) => {
        'id': tag.id,
        'label': tag.label,
        'category': tag.category,
        'isCustom': tag.isCustom,
      };
}
