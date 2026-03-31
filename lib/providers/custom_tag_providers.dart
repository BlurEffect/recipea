import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/tag_definitions.dart';
import '../repositories/custom_tag_repository.dart';

final customTagRepositoryProvider = Provider<CustomTagRepository>(
  (_) => CustomTagRepository(),
);

class CustomTagNotifier extends StateNotifier<List<TagDefinition>> {
  final CustomTagRepository _repo;

  CustomTagNotifier(this._repo) : super(_repo.getAll());

  void refresh() => state = _repo.getAll();

  Future<void> save(TagDefinition tag) async {
    await _repo.save(tag);
    refresh();
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    refresh();
  }
}

final customTagsProvider =
    StateNotifierProvider<CustomTagNotifier, List<TagDefinition>>(
  (ref) => CustomTagNotifier(ref.watch(customTagRepositoryProvider)),
);

/// Merged tag list: predefined first, then custom.
/// All screens should watch this instead of using tagDefinitions directly.
final allTagsProvider = Provider<List<TagDefinition>>((ref) {
  final custom = ref.watch(customTagsProvider);
  return [...tagDefinitions, ...custom];
});
