class TagDefinition {
  final String id;
  final String label;
  final String category; // category ID — matches CategoryDefinition.id
  final bool isCustom;

  const TagDefinition({
    required this.id,
    required this.label,
    required this.category,
    this.isCustom = false,
  });
}

TagDefinition? tagById(String id, List<TagDefinition> allTags) {
  try {
    return allTags.firstWhere((t) => t.id == id);
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
