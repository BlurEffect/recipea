class ShoppingItem {
  final String name;
  /// Legacy pre-formatted amount string. Unused when [unitKey] is non-null.
  /// Kept for backward compatibility with items stored before structured data.
  final String amount;
  final bool checked;
  /// Canonical normalized unit key (e.g. "can", "tl", "cup").
  /// Empty string means no unit. Null means this is a legacy item — use [amount].
  final String? unitKey;
  /// Scaled numeric quantity. Null for no-quantity items.
  final double? quantity;
  /// Parenthetical note (e.g. "packed") or standalone text for no-quantity items.
  final String? note;

  const ShoppingItem({
    required this.name,
    this.amount = '',
    this.checked = false,
    this.unitKey,
    this.quantity,
    this.note,
  });

  ShoppingItem copyWith({
    String? name,
    String? amount,
    bool? checked,
    String? unitKey,
    double? quantity,
    String? note,
  }) =>
      ShoppingItem(
        name: name ?? this.name,
        amount: amount ?? this.amount,
        checked: checked ?? this.checked,
        unitKey: unitKey ?? this.unitKey,
        quantity: quantity ?? this.quantity,
        note: note ?? this.note,
      );

  /// Returns the display amount, localizing the unit via [unitLocalizer].
  /// Falls back to [amount] for legacy items (where [unitKey] is null).
  String localizedAmount(String Function(String) unitLocalizer) {
    if (unitKey == null) return amount;

    if (quantity == null) {
      return note ?? '';
    }

    final s = quantity! == quantity!.truncateToDouble()
        ? quantity!.toInt().toString()
        : quantity!.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');

    final unitStr = unitKey!.isEmpty ? '' : unitLocalizer(unitKey!);
    final amountStr = unitStr.isEmpty ? s : '$s $unitStr';

    return note != null && note!.isNotEmpty ? '$amountStr ($note)' : amountStr;
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'amount': amount,
        'checked': checked,
        if (unitKey != null) 'unitKey': unitKey,
        if (quantity != null) 'quantity': quantity,
        if (note != null) 'note': note,
      };

  factory ShoppingItem.fromJson(Map<String, dynamic> json) => ShoppingItem(
        name: json['name'] as String,
        amount: json['amount'] as String? ?? '',
        checked: json['checked'] as bool? ?? false,
        unitKey: json['unitKey'] as String?,
        quantity: (json['quantity'] as num?)?.toDouble(),
        note: json['note'] as String?,
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
