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

class TagFilterState {
  final Set<String> included;
  final Set<String> excluded;

  const TagFilterState({
    this.included = const {},
    this.excluded = const {},
  });

  bool get isEmpty => included.isEmpty && excluded.isEmpty;
  bool get isNotEmpty => !isEmpty;

  TagFilterState copyWith({
    Set<String>? included,
    Set<String>? excluded,
  }) =>
      TagFilterState(
        included: included ?? this.included,
        excluded: excluded ?? this.excluded,
      );

  @override
  bool operator ==(Object other) =>
      other is TagFilterState &&
      _setEquals(included, other.included) &&
      _setEquals(excluded, other.excluded);

  @override
  int get hashCode => Object.hash(
        Object.hashAllUnordered(included),
        Object.hashAllUnordered(excluded),
      );
}

bool _setEquals(Set<String> a, Set<String> b) =>
    a.length == b.length && a.containsAll(b);

class TagFilterNotifier extends StateNotifier<TagFilterState> {
  TagFilterNotifier() : super(const TagFilterState());

  void toggleIncluded(String tagId) {
    final nextIncluded = Set<String>.from(state.included);
    final nextExcluded = Set<String>.from(state.excluded);
    if (nextIncluded.contains(tagId)) {
      nextIncluded.remove(tagId);
    } else {
      nextIncluded.add(tagId);
      nextExcluded.remove(tagId);
    }
    state = TagFilterState(included: nextIncluded, excluded: nextExcluded);
  }

  void toggleExcluded(String tagId) {
    final nextIncluded = Set<String>.from(state.included);
    final nextExcluded = Set<String>.from(state.excluded);
    if (nextExcluded.contains(tagId)) {
      nextExcluded.remove(tagId);
    } else {
      nextExcluded.add(tagId);
      nextIncluded.remove(tagId);
    }
    state = TagFilterState(included: nextIncluded, excluded: nextExcluded);
  }

  void setBoth(TagFilterState filter) => state = filter;

  void clear() => state = const TagFilterState();
}

final tagFilterProvider =
    StateNotifierProvider<TagFilterNotifier, TagFilterState>(
  (_) => TagFilterNotifier(),
);

// ── Filtered recipes (derived) ────────────────────────────────────────────────

final filteredRecipesProvider = Provider<List<Recipe>>((ref) {
  final recipes = ref.watch(recipeListProvider);
  final filter = ref.watch(tagFilterProvider);
  if (filter.isEmpty) return recipes;
  return recipes.where((r) {
    if (filter.included.isNotEmpty &&
        !filter.included.every((t) => r.tagIds.contains(t))) {
      return false;
    }
    if (filter.excluded.isNotEmpty &&
        filter.excluded.any((t) => r.tagIds.contains(t))) {
      return false;
    }
    return true;
  }).toList();
});

// ── New recipe ID generator ───────────────────────────────────────────────────

const _uuid = Uuid();

String generateRecipeId() => _uuid.v4();
