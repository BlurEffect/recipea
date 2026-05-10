class ShoppingItem {
  final String name;
  final String amount;
  final bool checked;

  const ShoppingItem({
    required this.name,
    required this.amount,
    this.checked = false,
  });

  ShoppingItem copyWith({String? name, String? amount, bool? checked}) =>
      ShoppingItem(
        name: name ?? this.name,
        amount: amount ?? this.amount,
        checked: checked ?? this.checked,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'amount': amount,
        'checked': checked,
      };

  factory ShoppingItem.fromJson(Map<String, dynamic> json) => ShoppingItem(
        name: json['name'] as String,
        amount: json['amount'] as String,
        checked: json['checked'] as bool? ?? false,
      );
}

class ShoppingList {
  final List<ShoppingItem> items;
  final DateTime? generatedAt;

  const ShoppingList({required this.items, this.generatedAt});

  factory ShoppingList.empty() => const ShoppingList(items: []);

  ShoppingList copyWith({List<ShoppingItem>? items, DateTime? generatedAt}) =>
      ShoppingList(
        items: items ?? this.items,
        generatedAt: generatedAt ?? this.generatedAt,
      );

  Map<String, dynamic> toJson() => {
        'items': items.map((e) => e.toJson()).toList(),
        'generatedAt': generatedAt?.toIso8601String(),
      };

  factory ShoppingList.fromJson(Map<String, dynamic> json) => ShoppingList(
        items: (json['items'] as List)
            .map((e) =>
                ShoppingItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        generatedAt: json['generatedAt'] != null
            ? DateTime.parse(json['generatedAt'] as String)
            : null,
      );
}
