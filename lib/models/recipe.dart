import 'ingredient.dart';
import 'recipe_step.dart';

class Recipe {
  final String id;
  final String title;
  final String? imagePath;
  final List<String> tagIds;
  final List<Ingredient> ingredients;
  final List<RecipeStep> steps;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Recipe({
    required this.id,
    required this.title,
    this.imagePath,
    required this.tagIds,
    required this.ingredients,
    required this.steps,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'imagePath': imagePath,
        'tagIds': tagIds,
        'ingredients': ingredients.map((e) => e.toJson()).toList(),
        'steps': steps.map((e) => e.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
        id: json['id'] as String,
        title: json['title'] as String,
        imagePath: json['imagePath'] as String?,
        tagIds: List<String>.from(json['tagIds'] as List),
        ingredients: (json['ingredients'] as List)
            .map((e) => Ingredient.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        steps: (json['steps'] as List)
            .map((e) => RecipeStep.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Recipe copyWith({
    String? id,
    String? title,
    Object? imagePath = _sentinel,
    List<String>? tagIds,
    List<Ingredient>? ingredients,
    List<RecipeStep>? steps,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Recipe(
        id: id ?? this.id,
        title: title ?? this.title,
        imagePath: imagePath == _sentinel ? this.imagePath : imagePath as String?,
        tagIds: tagIds ?? this.tagIds,
        ingredients: ingredients ?? this.ingredients,
        steps: steps ?? this.steps,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}

const Object _sentinel = Object();
