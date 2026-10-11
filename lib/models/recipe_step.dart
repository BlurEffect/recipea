import 'package:uuid/uuid.dart';

class RecipeStep {
  final String id;
  final int order;
  final String instruction;

  const RecipeStep({
    required this.id,
    required this.order,
    required this.instruction,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'order': order,
        'instruction': instruction,
      };

  factory RecipeStep.fromJson(Map<String, dynamic> json) => RecipeStep(
        id: json['id'] as String? ?? const Uuid().v4(),
        order: json['order'] as int,
        instruction: json['instruction'] as String,
      );

  RecipeStep copyWith({String? id, int? order, String? instruction}) =>
      RecipeStep(
        id: id ?? this.id,
        order: order ?? this.order,
        instruction: instruction ?? this.instruction,
      );
}
