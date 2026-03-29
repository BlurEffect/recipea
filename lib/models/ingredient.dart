class Ingredient {
  final String name;
  final String amount;

  const Ingredient({required this.name, required this.amount});

  Map<String, dynamic> toJson() => {'name': name, 'amount': amount};

  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
        name: json['name'] as String,
        amount: json['amount'] as String,
      );

  Ingredient copyWith({String? name, String? amount}) => Ingredient(
        name: name ?? this.name,
        amount: amount ?? this.amount,
      );
}
