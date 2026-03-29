class RecipeStep {
  final int order;
  final String instruction;

  const RecipeStep({required this.order, required this.instruction});

  Map<String, dynamic> toJson() => {'order': order, 'instruction': instruction};

  factory RecipeStep.fromJson(Map<String, dynamic> json) => RecipeStep(
        order: json['order'] as int,
        instruction: json['instruction'] as String,
      );

  RecipeStep copyWith({int? order, String? instruction}) => RecipeStep(
        order: order ?? this.order,
        instruction: instruction ?? this.instruction,
      );
}
