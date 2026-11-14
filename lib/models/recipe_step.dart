import 'package:uuid/uuid.dart';

class RecipeStep {
  final String id;
  final int order;
  final String instruction;
  final String? imagePath;

  const RecipeStep({
    required this.id,
    required this.order,
    required this.instruction,
    this.imagePath,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'order': order,
        'instruction': instruction,
        if (imagePath != null) 'imagePath': imagePath,
      };

  factory RecipeStep.fromJson(Map<String, dynamic> json) => RecipeStep(
        id: json['id'] as String? ?? const Uuid().v4(),
        order: json['order'] as int,
        instruction: json['instruction'] as String,
        imagePath: json['imagePath'] as String?,
      );

  RecipeStep copyWith({String? id, int? order, String? instruction, String? imagePath}) =>
      RecipeStep(
        id: id ?? this.id,
        order: order ?? this.order,
        instruction: instruction ?? this.instruction,
        imagePath: imagePath ?? this.imagePath,
      );
}
