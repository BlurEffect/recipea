# Recipea — Project Context

A personal Flutter recipe app for Android & iOS. Clean, minimalistic design with green branding.

## Tech Stack

| Layer | Package |
|---|---|
| Storage | `hive_flutter ^1.1.0` — `Box<String>` with JSON encoding, no codegen |
| State | `flutter_riverpod ^2.6.1` — StateNotifier providers |
| Navigation | `go_router ^14.6.2` — 5 named routes |
| Images | `image_picker`, `path_provider` — local filesystem, path stored in Hive |
| Export/Import | `share_plus`, `file_picker` — JSON with base64 images |
| IDs | `uuid ^4.5.1` — v4 UUIDs |

## Routes

```
/                   SplashScreen
/menu               MainMenuScreen
/recipes            BrowseScreen
/recipes/:id        DetailScreen
/recipes/:id/edit   EditScreen  (id == "new" for create)
```

## File Structure

```
lib/
  main.dart               Hive init, ProviderScope
  app.dart                MaterialApp.router
  router.dart             GoRouter definition
  data/
    tag_definitions.dart  Static tag pool (TagDefinition, TagCategory)
    hive_boxes.dart       Box name constants
  models/
    recipe.dart           Recipe — toJson/fromJson/copyWith
    ingredient.dart       Ingredient
    recipe_step.dart      RecipeStep
  repositories/
    recipe_repository.dart  CRUD + export/import + image helpers
  providers/
    recipe_providers.dart   recipeList, tagFilter, filteredRecipes
  widgets/
    tag_chip.dart           Shared chip (colored dot placeholder icon)
    empty_state.dart        Placeholder when list is empty
    tag_selector_sheet.dart Bottom sheet for tag picking (shared browse+edit)
  screens/
    splash/ menu/ browse/ detail/ edit/
  theme/
    app_colors.dart         Color tokens
    app_theme.dart          ThemeData factory
```

## Storage Pattern

Recipes are stored as JSON strings in a Hive `Box<String>`:
```dart
box.put(recipe.id, jsonEncode(recipe.toJson()));
Recipe.fromJson(jsonDecode(box.get(id)!));
```
No TypeAdapters or build_runner needed.

## Tag System

Tags are a **static predefined pool** — users assign them, not create them.
Defined in `lib/data/tag_definitions.dart` as `const List<TagDefinition>`.

Categories: `diet` | `protein` | `mealType` | `style` | `attribute`

Each category has a placeholder color (small colored dot in the chip).
**Real icons are planned — replace the dot in `TagChip` when ready.**

### Full Tag Pool

| Category | Tags |
|---|---|
| Diet | vegan, vegetarian, gluten-free, dairy-free, keto, paleo, low-carb |
| Protein | beef, chicken, pork, fish, seafood, lamb, tofu, eggs |
| Meal Type | breakfast, lunch, dinner, snack, dessert, appetizer, side-dish |
| Style | soup, salad, pasta, rice, stir-fry, baked, grilled, raw |
| Attributes | quick, spicy, kid-friendly, meal-prep, one-pot, freezer-friendly |

## Export/Import JSON Schema

```json
{
  "id": "uuid-v4",
  "title": "Recipe Title",
  "tagIds": ["pasta", "dinner"],
  "ingredients": [{ "name": "flour", "amount": "2 cups" }],
  "steps": [{ "order": 0, "instruction": "Mix ingredients." }],
  "createdAt": "ISO-8601",
  "updatedAt": "ISO-8601",
  "imageData": "<base64-jpeg-optional>"
}
```

Import deduplication: if UUID already exists → prompt user to replace.

## Design Tokens

- Primary green: `Color(0xFF2E7D32)`
- Background: `Color(0xFFF7F6F2)` (warm off-white)
- Surface (cards): `Colors.white`
- Tag category colors: diet=green, protein=red, mealType=amber, style=blue, attribute=purple

## Pending (future sessions)

- [ ] Export/Import UI (Phase 4) — `share_plus` + `file_picker` + conflict dialog
- [ ] Real icons for tags (replace colored-dot placeholder in `TagChip`)
- [ ] Splash screen animation polish
- [ ] Hero transitions (browse tile image → detail image)
- [ ] Image resize before base64 export (use `image ^4.2.0` package, already in pubspec)
