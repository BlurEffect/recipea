import 'package:flutter/material.dart';

import '../models/category_definition.dart';
import '../data/tag_definitions.dart';

// ── Default categories ────────────────────────────────────────────────────────
// Edit this list to change the built-in categories shipped with the app.
// Colors are plain Flutter Color values; pick any you like.

final List<CategoryDefinition> seedCategories = [
  CategoryDefinition(id: 'diet',     name: 'Diet',       color: const Color(0xFF43A047)),
  CategoryDefinition(id: 'protein',  name: 'Protein',    color: const Color(0xFFE53935)),
  CategoryDefinition(id: 'mealType', name: 'Meal Type',  color: const Color(0xFFFB8C00)),
  CategoryDefinition(id: 'style',    name: 'Style',      color: const Color(0xFF1E88E5)),
  CategoryDefinition(id: 'attribute',name: 'Attributes', color: const Color(0xFF8E24AA)),
];

// ── Default tags ──────────────────────────────────────────────────────────────
// Edit this list to change the built-in tags shipped with the app.
// 'category' must match an id in seedCategories above.

final List<TagDefinition> seedTags = [
  // Diet
  TagDefinition(id: 'vegan',        label: 'Vegan',            category: 'diet'),
  TagDefinition(id: 'vegetarian',   label: 'Vegetarian',       category: 'diet'),
  TagDefinition(id: 'gluten-free',  label: 'Gluten-Free',      category: 'diet'),
  TagDefinition(id: 'dairy-free',   label: 'Dairy-Free',       category: 'diet'),
  TagDefinition(id: 'keto',         label: 'Keto',             category: 'diet'),
  TagDefinition(id: 'paleo',        label: 'Paleo',            category: 'diet'),
  TagDefinition(id: 'low-carb',     label: 'Low-Carb',         category: 'diet'),

  // Protein
  TagDefinition(id: 'beef',         label: 'Beef',             category: 'protein'),
  TagDefinition(id: 'chicken',      label: 'Chicken',          category: 'protein'),
  TagDefinition(id: 'pork',         label: 'Pork',             category: 'protein'),
  TagDefinition(id: 'fish',         label: 'Fish',             category: 'protein'),
  TagDefinition(id: 'seafood',      label: 'Seafood',          category: 'protein'),
  TagDefinition(id: 'lamb',         label: 'Lamb',             category: 'protein'),
  TagDefinition(id: 'tofu',         label: 'Tofu',             category: 'protein'),
  TagDefinition(id: 'eggs',         label: 'Eggs',             category: 'protein'),

  // Meal Type
  TagDefinition(id: 'breakfast',    label: 'Breakfast',        category: 'mealType'),
  TagDefinition(id: 'lunch',        label: 'Lunch',            category: 'mealType'),
  TagDefinition(id: 'dinner',       label: 'Dinner',           category: 'mealType'),
  TagDefinition(id: 'snack',        label: 'Snack',            category: 'mealType'),
  TagDefinition(id: 'dessert',      label: 'Dessert',          category: 'mealType'),
  TagDefinition(id: 'appetizer',    label: 'Appetizer',        category: 'mealType'),
  TagDefinition(id: 'side-dish',    label: 'Side Dish',        category: 'mealType'),

  // Style
  TagDefinition(id: 'soup',         label: 'Soup',             category: 'style'),
  TagDefinition(id: 'salad',        label: 'Salad',            category: 'style'),
  TagDefinition(id: 'pasta',        label: 'Pasta',            category: 'style'),
  TagDefinition(id: 'rice',         label: 'Rice',             category: 'style'),
  TagDefinition(id: 'stir-fry',     label: 'Stir-Fry',        category: 'style'),
  TagDefinition(id: 'baked',        label: 'Baked',            category: 'style'),
  TagDefinition(id: 'grilled',      label: 'Grilled',          category: 'style'),
  TagDefinition(id: 'raw',          label: 'Raw',              category: 'style'),

  // Attributes
  TagDefinition(id: 'quick',            label: 'Quick',            category: 'attribute'),
  TagDefinition(id: 'spicy',            label: 'Spicy',            category: 'attribute'),
  TagDefinition(id: 'kid-friendly',     label: 'Kid-Friendly',     category: 'attribute'),
  TagDefinition(id: 'meal-prep',        label: 'Meal Prep',        category: 'attribute'),
  TagDefinition(id: 'one-pot',          label: 'One-Pot',          category: 'attribute'),
  TagDefinition(id: 'freezer-friendly', label: 'Freezer-Friendly', category: 'attribute'),
];

// ── Color palette for the category editor ────────────────────────────────────
// Shown as a grid when creating or editing a category.

const List<Color> categoryColorPalette = [
  Color(0xFF43A047), // green  (Diet default)
  Color(0xFFE53935), // red    (Protein default)
  Color(0xFFFB8C00), // orange (Meal Type default)
  Color(0xFF1E88E5), // blue   (Style default)
  Color(0xFF8E24AA), // purple (Attributes default)
  Color(0xFF00ACC1), // cyan
  Color(0xFF039BE5), // light blue
  Color(0xFF7CB342), // light green
  Color(0xFFF4511E), // deep orange
  Color(0xFFE91E63), // pink
  Color(0xFF5E35B1), // deep purple
  Color(0xFF00897B), // teal
  Color(0xFFFFB300), // amber
  Color(0xFF6D4C41), // brown
  Color(0xFF757575), // grey
  Color(0xFF546E7A), // blue grey
];
