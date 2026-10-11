import '../models/ingredient.dart';
import '../models/recipe.dart';
import '../models/recipe_step.dart';

/// Returns true if adding [targetId] as a component of [sourceId] would
/// create a circular dependency (including direct self-links).
bool wouldCreateCycle(
    String sourceId, String targetId, List<Recipe> allRecipes) {
  if (sourceId == targetId) return true;
  final visited = <String>{};
  final queue = [targetId];
  while (queue.isNotEmpty) {
    final current = queue.removeAt(0);
    if (visited.contains(current)) continue;
    visited.add(current);
    final recipe = allRecipes.cast<Recipe?>().firstWhere(
          (r) => r?.id == current,
          orElse: () => null,
        );
    if (recipe == null) continue;
    for (final linkedId in recipe.linkedRecipeIds) {
      if (linkedId == sourceId) return true;
      queue.add(linkedId);
    }
  }
  return false;
}

/// Recursively collects all ingredients from [recipe] and its linked
/// components (depth-first). [visited] prevents infinite loops.
List<Ingredient> allIngredients(
  Recipe recipe,
  List<Recipe> allRecipes, [
  Set<String>? visited,
]) {
  final seen = visited ?? {};
  if (seen.contains(recipe.id)) return [];
  seen.add(recipe.id);

  final result = <Ingredient>[...recipe.ingredients];
  for (final linkedId in recipe.linkedRecipeIds) {
    final linked = allRecipes.cast<Recipe?>().firstWhere(
          (r) => r?.id == linkedId,
          orElse: () => null,
        );
    if (linked != null) {
      result.addAll(allIngredients(linked, allRecipes, seen));
    }
  }
  return result;
}

/// Recursively collects all tag IDs from [recipe] and its components,
/// deduplicating while preserving first-seen order.
List<String> allTagIds(
  Recipe recipe,
  List<Recipe> allRecipes, [
  Set<String>? visitedRecipes,
]) {
  final seen = visitedRecipes ?? {};
  if (seen.contains(recipe.id)) return [];
  seen.add(recipe.id);

  final tagsSeen = <String>{};
  final result = <String>[];
  for (final id in recipe.tagIds) {
    if (tagsSeen.add(id)) result.add(id);
  }
  for (final linkedId in recipe.linkedRecipeIds) {
    final linked = allRecipes.cast<Recipe?>().firstWhere(
          (r) => r?.id == linkedId,
          orElse: () => null,
        );
    if (linked != null) {
      for (final id in allTagIds(linked, allRecipes, seen)) {
        if (tagsSeen.add(id)) result.add(id);
      }
    }
  }
  return result;
}

/// Resolves the step display order for a composite recipe into an ordered list
/// of (step, sourceRecipeId) pairs. sourceRecipeId = 'self' for own steps.
///
/// If [recipe.compositeStepOrder] is empty, falls back to block order
/// (blocks in componentOrder sequence).
/// Steps not listed in compositeStepOrder (e.g. added later to a component)
/// are appended at the end of their component's natural block.
List<({RecipeStep step, String sourceRecipeId})> resolveStepOrder(
  Recipe recipe,
  List<Recipe> allRecipes,
) {
  // Build a lookup: stepId → (RecipeStep, sourceRecipeId)
  final stepLookup = <String, ({RecipeStep step, String sourceRecipeId})>{};

  void index(List<RecipeStep> steps, String sourceId) {
    for (final s in steps) {
      stepLookup[s.id] = (step: s, sourceRecipeId: sourceId);
    }
  }

  index(recipe.steps, 'self');
  for (final linkedId in recipe.linkedRecipeIds) {
    final linked = allRecipes.cast<Recipe?>().firstWhere(
          (r) => r?.id == linkedId,
          orElse: () => null,
        );
    if (linked != null) index(linked.steps, linkedId);
  }

  if (recipe.compositeStepOrder.isEmpty) {
    // Block order fallback
    final result = <({RecipeStep step, String sourceRecipeId})>[];
    for (final entry in recipe.componentOrder) {
      if (entry == 'self') {
        final sorted = [...recipe.steps]..sort((a, b) => a.order.compareTo(b.order));
        result.addAll(sorted.map((s) => (step: s, sourceRecipeId: 'self')));
      } else {
        final linked = allRecipes.cast<Recipe?>().firstWhere(
              (r) => r?.id == entry,
              orElse: () => null,
            );
        if (linked != null) {
          final sorted = [...linked.steps]..sort((a, b) => a.order.compareTo(b.order));
          result.addAll(sorted.map((s) => (step: s, sourceRecipeId: entry)));
        }
      }
    }
    return result;
  }

  // Explicit ordering — follow compositeStepOrder, appending unlisted steps
  final result = <({RecipeStep step, String sourceRecipeId})>[];
  final listed = <String>{};

  for (final stepId in recipe.compositeStepOrder) {
    final entry = stepLookup[stepId];
    if (entry != null) {
      result.add(entry);
      listed.add(stepId);
    }
  }

  // Append steps not in compositeStepOrder (added to a component after ordering)
  for (final entry in recipe.componentOrder) {
    List<RecipeStep> steps;
    String sourceId;
    if (entry == 'self') {
      steps = [...recipe.steps]..sort((a, b) => a.order.compareTo(b.order));
      sourceId = 'self';
    } else {
      final linked = allRecipes.cast<Recipe?>().firstWhere(
            (r) => r?.id == entry,
            orElse: () => null,
          );
      if (linked == null) continue;
      steps = [...linked.steps]..sort((a, b) => a.order.compareTo(b.order));
      sourceId = entry;
    }
    for (final s in steps) {
      if (!listed.contains(s.id)) {
        result.add((step: s, sourceRecipeId: sourceId));
      }
    }
  }
  return result;
}

/// Validates that [proposedOrder] (list of step IDs) preserves the relative
/// order of each **linked** component's steps as defined in the source recipes.
/// Own ('self') steps are excluded — they can be freely reordered.
/// Returns true if the ordering is valid.
bool validateStepOrder(
  List<String> proposedOrder,
  Recipe recipe,
  List<Recipe> allRecipes,
) {
  // Build map: linkedRecipeId → ordered list of step IDs (in source order).
  // 'self' is intentionally excluded — own steps have no ordering constraint.
  final sourceOrder = <String, List<String>>{};

  for (final linkedId in recipe.linkedRecipeIds) {
    final linked = allRecipes.cast<Recipe?>().firstWhere(
          (r) => r?.id == linkedId,
          orElse: () => null,
        );
    if (linked != null) {
      final sorted = [...linked.steps]
        ..sort((a, b) => a.order.compareTo(b.order));
      sourceOrder[linkedId] = sorted.map((s) => s.id).toList();
    }
  }

  // For each linked source, check that its steps appear in the same relative
  // order within proposedOrder as they do in the source recipe.
  for (final entry in sourceOrder.entries) {
    final sourceStepIds = entry.value;
    final inProposed = proposedOrder
        .where((id) => sourceStepIds.contains(id))
        .toList();
    int sourceIdx = 0;
    for (final id in inProposed) {
      final nextIdx = sourceStepIds.indexOf(id, sourceIdx);
      if (nextIdx < sourceIdx) return false;
      sourceIdx = nextIdx + 1;
    }
  }
  return true;
}

/// Collects all recipe IDs that are transitively linked from [recipe]
/// (for use in export bundling). Includes [recipe.id] itself.
Set<String> allLinkedRecipeIds(Recipe recipe, List<Recipe> allRecipes) {
  final result = <String>{recipe.id};
  final queue = [...recipe.linkedRecipeIds];
  while (queue.isNotEmpty) {
    final id = queue.removeAt(0);
    if (result.contains(id)) continue;
    result.add(id);
    final linked = allRecipes.cast<Recipe?>().firstWhere(
          (r) => r?.id == id,
          orElse: () => null,
        );
    if (linked != null) queue.addAll(linked.linkedRecipeIds);
  }
  return result;
}
