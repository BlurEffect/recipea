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
      category: TagCategory.values.byName(json['category'] as String),
      isCustom: true,
    );
  }

  static Map<String, dynamic> _toJson(TagDefinition tag) => {
        'id': tag.id,
        'label': tag.label,
        'category': tag.category.name,
      };
}
