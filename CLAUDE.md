# Recipea — Project Context

A personal Flutter recipe app for Android & iOS. Clean, minimalistic design with green branding.

## Tech Stack

| Layer | Package |
|---|---|
| Storage | `hive_flutter ^1.1.0` — `Box<String>` with JSON encoding, no codegen |
| State | `flutter_riverpod ^2.6.1` — StateNotifier providers |
| Navigation | `go_router ^14.6.2` — 7 named routes |
| Images | `image_picker`, `path_provider` — local filesystem, path stored in Hive |
| Export/Import | `share_plus`, `file_picker` — JSON with base64 images |
| IDs | `uuid ^4.5.1` — v4 UUIDs |

## Routes

```
/                   SplashScreen
/recipes            BrowseScreen  (home)
/recipes/:id        DetailScreen
/recipes/:id/edit   EditScreen  (id == "new" for create)
/meal-plan          MealPlanScreen
/shopping-list      ShoppingListScreen
```

## File Structure

```
lib/
  main.dart               Hive init, ProviderScope, seeds categories + tags
  app.dart                MaterialApp.router
  router.dart             GoRouter definition
  data/
    tag_definitions.dart  TagDefinition model (category is now a String ID)
    hive_boxes.dart       Box name constants
    seed_data.dart        Default categories, tags, componentColors palette
  models/
    recipe.dart           Recipe — toJson/fromJson/copyWith
    ingredient.dart       Ingredient
    recipe_step.dart      RecipeStep (has stable UUID id field)
    category_definition.dart  CategoryDefinition (id, name, color)
    meal_plan.dart        MealPlan, toggleExcludedDate
    shopping_item.dart    ShoppingItem, ShoppingList
  repositories/
    recipe_repository.dart      CRUD + export/import + image helpers
    meal_plan_repository.dart   MealPlan + ShoppingList persistence
    category_repository.dart    CategoryDefinition CRUD + seedIfEmpty
    custom_tag_repository.dart  TagDefinition CRUD + seedIfEmpty
  providers/
    recipe_providers.dart       recipeList, tagFilter, filteredRecipes
    meal_plan_providers.dart    mealPlan, mealPlanRecipes, shoppingList
    category_providers.dart     categoryProvider, categoryMapProvider
    custom_tag_providers.dart   customTagsProvider, allTagsProvider
  utils/
    recipe_graph.dart     wouldCreateCycle, allIngredients, allTagIds,
                          resolveStepOrder, validateStepOrder, allLinkedRecipeIds
  widgets/
    tag_chip.dart             Shared chip — color from categoryMapProvider
    empty_state.dart          Placeholder when list is empty
    tag_selector_sheet.dart   Bottom sheet for tag picking (shared browse+edit)
    category_manager_sheet.dart  CRUD sheet for categories and their tags
    app_bottom_nav_bar.dart   Persistent bottom nav (Recipes / Meal Plan / Shopping)
    add_to_meal_plan_sheet.dart  Bottom sheet to assign a recipe to a meal plan day
  screens/
    splash/ browse/ detail/ edit/ meal_plan/ shopping_list/
  theme/
    app_colors.dart         Color tokens
    app_theme.dart          ThemeData factory
```

## Navigation

Bottom navigation bar (3 tabs) is added directly to `BrowseScreen`, `MealPlanScreen`, and `ShoppingListScreen` via `AppBottomNavBar(currentIndex: N)`. Detail and Edit screens are full-screen with no nav bar. No ShellRoute used — plain `GoRoute` entries.

## Meal Plan

**Requirements:** 7-day rolling window (today → today+6). Each day has a flexible, user-defined number of unnamed meal slots. The user adds slots with "+ Add meal" and removes them with ×. There are no fixed Breakfast/Lunch/Dinner categories.

**Model** (`lib/models/meal_plan.dart`):
```dart
class MealPlan {
  final Map<String, List<String?>> daySlots;
  // key: "yyyy-MM-dd", value: ordered list of recipeIds (null = empty slot)
}
```
Key operations: `addSlot(date)`, `removeSlot(date, index)`, `setSlotRecipe(date, index, recipeId?)`, `addRecipeToDay(date, recipeId)`.

**Storage:** Single Hive box `HiveBoxes.mealPlan` (`'meal_plan'`). Two string keys inside:
- `'plan'` → JSON-encoded `MealPlan`
- `'shopping_list'` → JSON-encoded `ShoppingList`

Repository: `lib/repositories/meal_plan_repository.dart`. `loadPlan()` has a try/catch that discards incompatible stored data and starts fresh.

**Providers** (`lib/providers/meal_plan_providers.dart`):
- `mealPlanProvider` — `StateNotifier<MealPlan>`, persists every mutation
- `mealPlanRecipesProvider` — derived; unique recipes currently assigned in the plan
- `shoppingListProvider` — `StateNotifier<ShoppingList>`, `generate(recipes)` + `toggle(index)`

**Assigning from detail screen:** Three-dot menu → "Add to Meal Plan" → `AddToMealPlanSheet` (pick a day → appends a new slot with the recipe).

## Shopping List

**Model** (`lib/models/shopping_item.dart`): `ShoppingItem` (name, amount, checked) + `ShoppingList` (items, generatedAt).

**Generation:** Triggered by the refresh button on `ShoppingListScreen`. Collects all ingredients from `mealPlanRecipesProvider`, groups by normalised ingredient name, and accumulates amounts:
- Same numeric unit → sum (e.g. "2 cups + 1 cup = 3 cups")
- Fractions supported ("1/2")
- Unit mismatch or non-numeric → joined with ` + `

**Persistence:** Ticked items survive navigation. Regenerating resets all ticks (new `ShoppingList` with `generatedAt` timestamp; `ValueKey(generatedAt)` on the `ListView` forces a full rebuild).

## Storage Pattern

Recipes are stored as JSON strings in a Hive `Box<String>`:
```dart
box.put(recipe.id, jsonEncode(recipe.toJson()));
Recipe.fromJson(jsonDecode(box.get(id)!));
```
No TypeAdapters or build_runner needed.

## Tag & Category System

Tags and categories are **fully user-editable** and stored in Hive.

- `HiveBoxes.categories` (`'categories'`) — `Box<String>` of `CategoryDefinition` JSON
- `HiveBoxes.customTags` (`'custom_tags'`) — `Box<String>` of `TagDefinition` JSON

Both boxes are seeded on first launch from `lib/data/seed_data.dart` via `seedIfEmpty()`. Seed data defines 5 default categories (diet, protein, mealType, style, attribute) and 34 default tags — edit that file to change the shipped defaults.

`TagDefinition.category` is a plain `String` (category ID), not an enum.

**UI:**
- `tag_selector_sheet.dart` — pick tags to assign; "Manage categories" button opens the manager
- `category_manager_sheet.dart` — create/rename/recolor/delete categories; delete tags per category with recipe-count confirmation

**`TagChip`** reads its color from `categoryMapProvider` (O(1) map lookup by category ID).

**Real icons are planned — replace the colored-dot `Container` in `TagChip` with SVG/icon assets when ready.**

### Default Tag Pool (from `seed_data.dart`)

| Category | Tags |
|---|---|
| Diet | vegan, vegetarian, gluten-free, dairy-free, keto, paleo, low-carb |
| Protein | beef, chicken, pork, fish, seafood, lamb, tofu, eggs |
| Meal Type | breakfast, lunch, dinner, snack, dessert, appetizer, side-dish |
| Style | soup, salad, pasta, rice, stir-fry, baked, grilled, raw |
| Attributes | quick, spicy, kid-friendly, meal-prep, one-pot, freezer-friendly |

## Export/Import JSON Schema

**Version 2 envelope** (current):
```json
{
  "version": 2,
  "categories": [{ "id": "diet", "name": "Diet", "color": 4283276354 }],
  "customTags": [{ "id": "pasta", "label": "Pasta", "category": "style", "isCustom": false }],
  "recipes": [ ...recipe objects... ]
}
```

**Per-recipe object:**
```json
{
  "id": "uuid-v4",
  "title": "Recipe Title",
  "tagIds": ["pasta", "dinner"],
  "ingredients": [{ "name": "flour", "amount": "2 cups" }],
  "steps": [{ "id": "uuid-v4", "order": 0, "instruction": "Mix ingredients." }],
  "createdAt": "ISO-8601",
  "updatedAt": "ISO-8601",
  "componentOrder": ["self", "linked-recipe-uuid"],
  "compositeStepOrder": ["step-uuid-1", "step-uuid-2"],
  "imageData": "<base64-jpeg-optional>"
}
```

Legacy bare-array format (version 1) is still accepted on import.

Composite recipes auto-bundle all transitively linked component recipes at export time.

Import deduplication: if UUID already exists → prompt user to replace.

## Design Tokens

- Primary green: `Color(0xFF2E7D32)`
- Background: `Color(0xFFF7F6F2)` (warm off-white)
- Surface (cards): `Colors.white`
- Tag category colors: user-configurable, stored in Hive, seeded from `seed_data.dart`
- Component colors (composite recipe step blocks): `componentColors` list in `seed_data.dart` — 6 pastel colors cycling by component index

## Composite Recipes

A recipe can link other recipes as ordered **components**. The composite recipe shows combined ingredients (with a Separate / Combined toggle), color-coded interleaved steps from all components, and aggregated unique tags.

**Data model additions to `Recipe`:**
- `componentOrder: List<String>` — ordered list of component IDs + `'self'` sentinel. Empty = standalone.
- `compositeStepOrder: List<String>` — explicit cross-component step IDs. Empty = block order fallback.
- `isComposite` getter, `linkedRecipeIds` getter

**`RecipeStep` now has a stable `id: String` (UUID)** — auto-generated from old data on first load.

**Utilities in `lib/utils/recipe_graph.dart`:**
- `wouldCreateCycle` — BFS cycle detection for component picker
- `allIngredients` / `allTagIds` — recursive collection across linked components
- `resolveStepOrder` — resolves explicit or block-fallback step ordering
- `validateStepOrder` — enforces within-linked-component step order constraint (own steps are free)
- `allLinkedRecipeIds` — transitive ID set for export bundling

**Edit screen:** Components section (reorderable linked recipe list + 'self' block positioning). Composite step editor shows all steps in a single draggable list — own steps are editable, linked steps are read-only; invalid reorders show a SnackBar.

**Detail screen:** Component chips header, Separate/Combined ingredient toggle, color-coded step tiles with "from [Recipe]" labels.

## Status

Core app + meal plan + composite recipes complete. `flutter analyze` is clean.

## Known Issues / Fragile Code to Revisit

- **Image path check in `edit_screen.dart`** (`_imagePath!.contains('recipea_images')`) is a string-based heuristic to detect whether a picked image has already been copied to the docs directory. Should be replaced with a proper `path_provider` comparison once tested.
- **`detail_screen.dart` recipe lookup** uses `.cast<Recipe?>().firstWhere(...)` on the full list every rebuild. Fine for small collections; consider a `recipeByIdProvider(id)` family provider if the list grows large.

## Todo — Polish

- [ ] Hero transitions on recipe image (browse tile → detail): wrap `Image.file` in both with `Hero(tag: 'recipe-image-${recipe.id}')`
- [ ] Splash screen animation polish (currently a simple fade-in)
- [ ] Custom tag icons — replace the colored-dot `Container` in `lib/widgets/tag_chip.dart` with real SVG/icon assets when ready. `TagDefinition` is the right place to add icon data.
- [ ] `intl` date formatting on detail screen (show `updatedAt` as "Updated Mar 29, 2026")

## Version 2.0 — Google Drive Sync

Replace manual file-based export/import with automatic background sync via Google Drive.

**Architecture:**
- New `DriveService` class wrapping the `googleapis` Drive API client
- `google_sign_in` for OAuth2 — separate client IDs for Android (SHA-1 keystore fingerprint) and iOS (bundle ID)
- `drive.file` scope only — app can only see files it created, no full Drive access needed
- Single `recipea_backup.json` stored in Drive app folder; same JSON schema as the existing export format so no migration needed

**Sync strategy:** Per-recipe last-`updatedAt`-wins merge on app launch. Recipes present on one device but absent on the other are copied across. No three-way merge — if the same recipe was edited on both devices between syncs, the newer `updatedAt` wins silently.

**New packages needed:**
```yaml
google_sign_in: ^6.x
googleapis: ^13.x
extension_google_sign_in_as_googleapis_auth: ^2.x
```

**Google Cloud Console setup (one-time, no code):**
1. Create project, enable Drive API
2. Create OAuth 2.0 client ID for Android (requires release keystore SHA-1) and iOS (bundle ID)
3. Drop `google-services.json` into `android/app/`
4. Add `GoogleService-Info.plist` to Xcode project; register reverse client ID as URL scheme in `Info.plist`

**Estimated scope:** ~150 lines for `DriveService`, ~30 lines UI wiring (sign-in button in settings / 3-dot menu), ~60 lines merge logic. No changes to Hive storage or JSON schema.
