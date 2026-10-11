import 'package:flutter/material.dart';

class CategoryDefinition {
  final String id;
  final String name;
  final Color color;

  const CategoryDefinition({
    required this.id,
    required this.name,
    required this.color,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'color': color.toARGB32(),
      };

  factory CategoryDefinition.fromJson(Map<String, dynamic> json) =>
      CategoryDefinition(
        id: json['id'] as String,
        name: json['name'] as String,
        color: Color(json['color'] as int),
      );

  CategoryDefinition copyWith({String? name, Color? color}) =>
      CategoryDefinition(
        id: id,
        name: name ?? this.name,
        color: color ?? this.color,
      );
}
