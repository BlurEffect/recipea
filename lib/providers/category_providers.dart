import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category_definition.dart';
import '../repositories/category_repository.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>(
  (_) => CategoryRepository(),
);

class CategoryNotifier extends StateNotifier<List<CategoryDefinition>> {
  final CategoryRepository _repo;

  CategoryNotifier(this._repo) : super(_repo.getAll());

  void refresh() => state = _repo.getAll();

  Future<void> save(CategoryDefinition category) async {
    await _repo.save(category);
    refresh();
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    refresh();
  }
}

final categoryProvider =
    StateNotifierProvider<CategoryNotifier, List<CategoryDefinition>>(
  (ref) => CategoryNotifier(ref.watch(categoryRepositoryProvider)),
);

/// O(1) lookup map: category id → CategoryDefinition.
final categoryMapProvider = Provider<Map<String, CategoryDefinition>>((ref) {
  return {for (final c in ref.watch(categoryProvider)) c.id: c};
});
