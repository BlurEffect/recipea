import 'dart:convert';
import 'dart:io';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../data/hive_boxes.dart';
import '../data/tag_definitions.dart';
import '../models/category_definition.dart';
import '../models/recipe.dart';
import '../utils/recipe_graph.dart';

class RecipeRepository {
  static const _uuid = Uuid();

  Box<String> get _box => Hive.box<String>(HiveBoxes.recipes);

  // ── Read ──────────────────────────────────────────────────────────────────

  List<Recipe> getAll() {
    return _box.values
        .map((json) => Recipe.fromJson(jsonDecode(json) as Map<String, dynamic>))
        .toList();
  }

  Recipe? getById(String id) {
    final json = _box.get(id);
    if (json == null) return null;
    return Recipe.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  // ── Write ─────────────────────────────────────────────────────────────────

  Future<void> save(Recipe recipe) async {
    await _box.put(recipe.id, jsonEncode(recipe.toJson()));
  }

  Future<void> delete(String id) async {
    final recipe = getById(id);
    if (recipe?.imagePath != null) {
      _deleteImageFile(recipe!.imagePath!);
    }
    await _box.delete(id);
  }

  // ── Image helpers ─────────────────────────────────────────────────────────

  Future<String> saveImage(String sourcePath) async {
    final docDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${docDir.path}/recipea_images');
    await imagesDir.create(recursive: true);
    final newPath = '${imagesDir.path}/${_uuid.v4()}.jpg';
    await File(sourcePath).copy(newPath);
    return newPath;
  }

  void deleteImageFile(String path) => _deleteImageFile(path);

  void _deleteImageFile(String path) {
    try {
      final file = File(path);
      if (file.existsSync()) file.deleteSync();
    } catch (_) {}
  }

  // ── Export / Import ───────────────────────────────────────────────────────

  Future<String> exportToJson(
    List<String> ids,
    List<TagDefinition> allTags,
    List<CategoryDefinition> allCategories,
  ) async {
    final allStored = getAll();
    final baseRecipes = ids.isEmpty
        ? allStored
        : ids.map((id) => getById(id)).whereType<Recipe>().toList();

    // Expand composite recipes to include all transitively linked components.
    final expandedIds = <String>{};
    for (final r in baseRecipes) {
      expandedIds.addAll(allLinkedRecipeIds(r, allStored));
    }
    final recipes = allStored.where((r) => expandedIds.contains(r.id)).toList();

    final List<Map<String, dynamic>> jsonList = [];
    for (final recipe in recipes) {
      final map = recipe.toJson();
      if (recipe.imagePath != null) {
        try {
          final bytes = await File(recipe.imagePath!).readAsBytes();
          final decoded = img.decodeImage(bytes);
          if (decoded != null) {
            final resized = decoded.width > 1200
                ? img.copyResize(decoded, width: 1200)
                : decoded;
            map['imageData'] = base64Encode(img.encodeJpg(resized, quality: 85));
          } else {
            map['imageData'] = base64Encode(bytes);
          }
        } catch (_) {}
      }
      jsonList.add(map);
    }

    return jsonEncode({
      'version': 2,
      'categories': allCategories.map((c) => c.toJson()).toList(),
      'customTags': allTags
          .map((t) => {'id': t.id, 'label': t.label, 'category': t.category, 'isCustom': t.isCustom})
          .toList(),
      'recipes': jsonList,
    });
  }

  Future<ImportResult> importFromJson(String jsonString) async {
    final parsed = _parseImportJson(jsonString);
    int imported = 0;
    final List<String> conflicts = [];
    final List<String> conflictIds = [];

    for (final item in parsed.recipes) {
      final map = Map<String, dynamic>.from(item as Map);
      final id = map['id'] as String;
      final title = map['title'] as String;

      if (_box.containsKey(id)) {
        conflicts.add(title);
        conflictIds.add(id);
        continue;
      }

      final imageData = map.remove('imageData') as String?;
      String? imagePath;
      if (imageData != null) {
        try {
          final bytes = base64Decode(imageData);
          final docDir = await getApplicationDocumentsDirectory();
          final imagesDir = Directory('${docDir.path}/recipea_images');
          await imagesDir.create(recursive: true);
          imagePath = '${imagesDir.path}/${_uuid.v4()}.jpg';
          await File(imagePath).writeAsBytes(bytes);
        } catch (_) {}
      }

      map['imagePath'] = imagePath;
      final recipe = Recipe.fromJson(map);
      await save(recipe);
      imported++;
    }

    return ImportResult(
      imported: imported,
      conflicts: conflicts,
      conflictIds: conflictIds,
      customTags: parsed.customTags,
      categories: parsed.categories,
    );
  }

  Future<void> forceImport(String jsonString, List<String> ids) async {
    final parsed = _parseImportJson(jsonString);
    for (final item in parsed.recipes) {
      final map = Map<String, dynamic>.from(item as Map);
      if (!ids.contains(map['id'])) continue;

      final imageData = map.remove('imageData') as String?;
      String? imagePath;
      if (imageData != null) {
        try {
          final bytes = base64Decode(imageData);
          final docDir = await getApplicationDocumentsDirectory();
          final imagesDir = Directory('${docDir.path}/recipea_images');
          await imagesDir.create(recursive: true);
          imagePath = '${imagesDir.path}/${_uuid.v4()}.jpg';
          await File(imagePath).writeAsBytes(bytes);
        } catch (_) {}
      }
      map['imagePath'] = imagePath;
      await save(Recipe.fromJson(map));
    }
  }

  // ── Parse helper ──────────────────────────────────────────────────────────

  static ({
    List<dynamic> recipes,
    List<Map<String, dynamic>> customTags,
    List<Map<String, dynamic>> categories,
  }) _parseImportJson(String jsonString) {
    final dynamic decoded;
    try {
      decoded = jsonDecode(jsonString);
    } on FormatException {
      throw const FormatException('This file is not valid JSON.');
    }
    if (decoded is List) {
      // Legacy bare-array format — no custom tags or categories
      return (recipes: decoded, customTags: [], categories: []);
    }
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Unrecognised file structure.');
    }
    final recipes = decoded['recipes'];
    if (recipes is! List) {
      throw const FormatException(
          'No recipe data found. Make sure this file was exported from Recipea.');
    }
    final customTagsRaw = decoded['customTags'] as List<dynamic>? ?? [];
    final categoriesRaw = decoded['categories'] as List<dynamic>? ?? [];
    return (
      recipes: recipes,
      customTags: customTagsRaw
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      categories: categoriesRaw
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
    );
  }
}

class ImportResult {
  final int imported;
  final List<String> conflicts;
  final List<String> conflictIds;
  final List<Map<String, dynamic>> customTags;
  final List<Map<String, dynamic>> categories;

  const ImportResult({
    required this.imported,
    required this.conflicts,
    required this.conflictIds,
    this.customTags = const [],
    this.categories = const [],
  });
}
