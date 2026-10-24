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

  /// Ordered list of component entries for composite recipes.
  /// Each entry is either a linked recipe ID or the sentinel 'self'
  /// ('self' = this recipe's own content block).
  /// Empty list = standalone recipe.
  /// Example: ['self', 'potato-salad-uuid', 'steak-uuid']
  final List<String> componentOrder;

  /// Explicit cross-component step ordering for composite recipes.
  /// Each entry is a RecipeStep.id from any component (including 'self' steps).
  /// Empty = use block order derived from componentOrder.
  final List<String> compositeStepOrder;

  /// Number of servings this recipe is written for.
  final int servings;

  /// Optional cook's notes shown prominently before ingredients.
  final String? description;

  const Recipe({
    required this.id,
    required this.title,
    this.imagePath,
    required this.tagIds,
    required this.ingredients,
    required this.steps,
    required this.createdAt,
    required this.updatedAt,
    this.componentOrder = const [],
    this.compositeStepOrder = const [],
    this.servings = 1,
    this.description,
  });

  bool get isComposite => componentOrder.isNotEmpty;

  List<String> get linkedRecipeIds =>
      componentOrder.where((id) => id != 'self').toList();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'imagePath': imagePath,
        'tagIds': tagIds,
        'ingredients': ingredients.map((e) => e.toJson()).toList(),
        'steps': steps.map((e) => e.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'componentOrder': componentOrder,
        'compositeStepOrder': compositeStepOrder,
        'servings': servings,
        if (description != null && description!.isNotEmpty)
          'description': description,
      };

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
        id: json['id'] as String,
        title: json['title'] as String,
        imagePath: json['imagePath'] as String?,
        tagIds: List<String>.from(json['tagIds'] as List),
        ingredients: (json['ingredients'] as List)
            .map((e) =>
                Ingredient.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        steps: (json['steps'] as List)
            .map((e) =>
                RecipeStep.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        componentOrder:
            List<String>.from(json['componentOrder'] as List? ?? []),
        compositeStepOrder:
            List<String>.from(json['compositeStepOrder'] as List? ?? []),
        servings: (json['servings'] as int?) ?? 1,
        description: json['description'] as String?,
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
    List<String>? componentOrder,
    List<String>? compositeStepOrder,
    int? servings,
    Object? description = _sentinel,
  }) =>
      Recipe(
        id: id ?? this.id,
        title: title ?? this.title,
        imagePath:
            imagePath == _sentinel ? this.imagePath : imagePath as String?,
        tagIds: tagIds ?? this.tagIds,
        ingredients: ingredients ?? this.ingredients,
        steps: steps ?? this.steps,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        componentOrder: componentOrder ?? this.componentOrder,
        compositeStepOrder: compositeStepOrder ?? this.compositeStepOrder,
        servings: servings ?? this.servings,
        description:
            description == _sentinel ? this.description : description as String?,
      );
}

const Object _sentinel = Object();
