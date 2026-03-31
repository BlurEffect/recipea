import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum TagCategory { diet, protein, mealType, style, attribute }

extension TagCategoryX on TagCategory {
  String get displayName {
    switch (this) {
      case TagCategory.diet:
        return 'Diet';
      case TagCategory.protein:
        return 'Protein';
      case TagCategory.mealType:
        return 'Meal Type';
      case TagCategory.style:
        return 'Style';
      case TagCategory.attribute:
        return 'Attributes';
    }
  }

  // Placeholder color per category — will be replaced by custom icons later
  Color get color {
    switch (this) {
      case TagCategory.diet:
        return AppColors.tagDiet;
      case TagCategory.protein:
        return AppColors.tagProtein;
      case TagCategory.mealType:
        return AppColors.tagMealType;
      case TagCategory.style:
        return AppColors.tagStyle;
      case TagCategory.attribute:
        return AppColors.tagAttribute;
    }
  }
}

class TagDefinition {
  final String id;
  final String label;
  final TagCategory category;
  final bool isCustom;

  const TagDefinition({
    required this.id,
    required this.label,
    required this.category,
    this.isCustom = false,
  });
}

const List<TagDefinition> tagDefinitions = [
  // Diet
  TagDefinition(id: 'vegan', label: 'Vegan', category: TagCategory.diet),
  TagDefinition(id: 'vegetarian', label: 'Vegetarian', category: TagCategory.diet),
  TagDefinition(id: 'gluten-free', label: 'Gluten-Free', category: TagCategory.diet),
  TagDefinition(id: 'dairy-free', label: 'Dairy-Free', category: TagCategory.diet),
  TagDefinition(id: 'keto', label: 'Keto', category: TagCategory.diet),
  TagDefinition(id: 'paleo', label: 'Paleo', category: TagCategory.diet),
  TagDefinition(id: 'low-carb', label: 'Low-Carb', category: TagCategory.diet),

  // Protein
  TagDefinition(id: 'beef', label: 'Beef', category: TagCategory.protein),
  TagDefinition(id: 'chicken', label: 'Chicken', category: TagCategory.protein),
  TagDefinition(id: 'pork', label: 'Pork', category: TagCategory.protein),
  TagDefinition(id: 'fish', label: 'Fish', category: TagCategory.protein),
  TagDefinition(id: 'seafood', label: 'Seafood', category: TagCategory.protein),
  TagDefinition(id: 'lamb', label: 'Lamb', category: TagCategory.protein),
  TagDefinition(id: 'tofu', label: 'Tofu', category: TagCategory.protein),
  TagDefinition(id: 'eggs', label: 'Eggs', category: TagCategory.protein),

  // Meal Type
  TagDefinition(id: 'breakfast', label: 'Breakfast', category: TagCategory.mealType),
  TagDefinition(id: 'lunch', label: 'Lunch', category: TagCategory.mealType),
  TagDefinition(id: 'dinner', label: 'Dinner', category: TagCategory.mealType),
  TagDefinition(id: 'snack', label: 'Snack', category: TagCategory.mealType),
  TagDefinition(id: 'dessert', label: 'Dessert', category: TagCategory.mealType),
  TagDefinition(id: 'appetizer', label: 'Appetizer', category: TagCategory.mealType),
  TagDefinition(id: 'side-dish', label: 'Side Dish', category: TagCategory.mealType),

  // Style
  TagDefinition(id: 'soup', label: 'Soup', category: TagCategory.style),
  TagDefinition(id: 'salad', label: 'Salad', category: TagCategory.style),
  TagDefinition(id: 'pasta', label: 'Pasta', category: TagCategory.style),
  TagDefinition(id: 'rice', label: 'Rice', category: TagCategory.style),
  TagDefinition(id: 'stir-fry', label: 'Stir-Fry', category: TagCategory.style),
  TagDefinition(id: 'baked', label: 'Baked', category: TagCategory.style),
  TagDefinition(id: 'grilled', label: 'Grilled', category: TagCategory.style),
  TagDefinition(id: 'raw', label: 'Raw', category: TagCategory.style),

  // Attributes
  TagDefinition(id: 'quick', label: 'Quick', category: TagCategory.attribute),
  TagDefinition(id: 'spicy', label: 'Spicy', category: TagCategory.attribute),
  TagDefinition(id: 'kid-friendly', label: 'Kid-Friendly', category: TagCategory.attribute),
  TagDefinition(id: 'meal-prep', label: 'Meal Prep', category: TagCategory.attribute),
  TagDefinition(id: 'one-pot', label: 'One-Pot', category: TagCategory.attribute),
  TagDefinition(id: 'freezer-friendly', label: 'Freezer-Friendly', category: TagCategory.attribute),
];

TagDefinition? tagById(String id) {
  try {
    return tagDefinitions.firstWhere((t) => t.id == id);
  } catch (_) {
    return null;
  }
}

TagDefinition? tagByIdAll(String id, List<TagDefinition> allTags) {
  try {
    return allTags.firstWhere((t) => t.id == id);
  } catch (_) {
    return null;
  }
}
