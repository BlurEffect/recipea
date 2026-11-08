import 'package:flutter/material.dart';

class CharacterDefinition {
  final String id;
  final String name;
  final String unlockCondition;
  final Color color;

  const CharacterDefinition({
    required this.id,
    required this.name,
    required this.unlockCondition,
    required this.color,
  });
}

const List<CharacterDefinition> characters = [
  CharacterDefinition(
    id: 'recipea',
    name: 'Recipea',
    color: Color(0xFF2E7D32),
    unlockCondition: 'Your guide from the start',
  ),
  CharacterDefinition(
    id: 'carl',
    name: 'Carl',
    color: Color(0xFF8D6E63),
    unlockCondition: 'Create your first recipe',
  ),
  CharacterDefinition(
    id: 'poppy',
    name: 'Poppy',
    color: Color(0xFF7B1FA2),
    unlockCondition: 'Add a photo to a recipe',
  ),
  CharacterDefinition(
    id: 'fry',
    name: 'Fry',
    color: Color(0xFF388E3C),
    unlockCondition: 'Use the meal plan for the first time',
  ),
  CharacterDefinition(
    id: 'tony',
    name: 'Tony',
    color: Color(0xFFE91E63),
    unlockCondition: 'Create a custom tag or category',
  ),
  CharacterDefinition(
    id: 'stirring',
    name: 'Stirring',
    color: Color(0xFF5C6BC0),
    unlockCondition: 'Link a recipe as a component',
  ),
  CharacterDefinition(
    id: 'mr_cutter',
    name: 'Mr. Cutter',
    color: Color(0xFFBF360C),
    unlockCondition: 'Export a recipe for the first time',
  ),
  CharacterDefinition(
    id: 'ms_bakewell',
    name: 'Ms. Bakewell',
    color: Color(0xFFF57C00),
    unlockCondition: 'Generate a shopping list',
  ),
  CharacterDefinition(
    id: 'soupster',
    name: 'Soupster',
    color: Color(0xFF0097A7),
    unlockCondition: 'Export the full database',
  ),
];

CharacterDefinition? characterById(String id) {
  try {
    return characters.firstWhere((c) => c.id == id);
  } catch (_) {
    return null;
  }
}
