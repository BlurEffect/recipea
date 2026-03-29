import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/recipe.dart';
import '../repositories/recipe_repository.dart';

// ── Repository ────────────────────────────────────────────────────────────────

final recipeRepositoryProvider = Provider<RecipeRepository>(
  (_) => RecipeRepository(),
);

// ── Recipe list ───────────────────────────────────────────────────────────────

class RecipeListNotifier extends StateNotifier<List<Recipe>> {
  final RecipeRepository _repo;

  RecipeListNotifier(this._repo) : super(_repo.getAll());

  void refresh() => state = _repo.getAll();

  Future<void> save(Recipe recipe) async {
    await _repo.save(recipe);
    refresh();
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    refresh();
  }
}

final recipeListProvider =
    StateNotifierProvider<RecipeListNotifier, List<Recipe>>(
  (ref) => RecipeListNotifier(ref.watch(recipeRepositoryProvider)),
);

// ── Tag filter ────────────────────────────────────────────────────────────────

class TagFilterNotifier extends StateNotifier<Set<String>> {
  TagFilterNotifier() : super({});

  void toggle(String tagId) {
    final next = Set<String>.from(state);
    if (next.contains(tagId)) {
      next.remove(tagId);
    } else {
      next.add(tagId);
    }
    state = next;
  }

  void clear() => state = {};
}

final tagFilterProvider = StateNotifierProvider<TagFilterNotifier, Set<String>>(
  (_) => TagFilterNotifier(),
);

// ── Filtered recipes (derived) ────────────────────────────────────────────────

final filteredRecipesProvider = Provider<List<Recipe>>((ref) {
  final recipes = ref.watch(recipeListProvider);
  final activeTags = ref.watch(tagFilterProvider);
  if (activeTags.isEmpty) return recipes;
  return recipes
      .where((r) => activeTags.every((t) => r.tagIds.contains(t)))
      .toList();
});

// ── New recipe ID generator ───────────────────────────────────────────────────

const _uuid = Uuid();

String generateRecipeId() => _uuid.v4();
