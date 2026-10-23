class Ingredient {
  final String name;
  final double? quantity;
  final String? unit;
  final String? note;

  const Ingredient({required this.name, this.quantity, this.unit, this.note});

  Map<String, dynamic> toJson() => {
        'name': name,
        if (quantity != null) 'quantity': quantity,
        if (unit != null) 'unit': unit,
        if (note != null && note!.isNotEmpty) 'note': note,
      };

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('quantity') || json.containsKey('unit')) {
      return Ingredient(
        name: json['name'] as String,
        quantity: (json['quantity'] as num?)?.toDouble(),
        unit: json['unit'] as String?,
        note: json['note'] as String?,
      );
    }
    // Legacy: migrate old free-text 'amount' field
    final amount = (json['amount'] as String? ?? '').trim();
    final parsed = _tryParseAmount(amount);
    return Ingredient(
      name: json['name'] as String,
      quantity: parsed?.$1,
      unit: parsed?.$2,
      note: parsed == null && amount.isNotEmpty ? amount : null,
    );
  }

  Ingredient copyWith({String? name, double? quantity, String? unit, String? note}) =>
      Ingredient(
        name: name ?? this.name,
        quantity: quantity ?? this.quantity,
        unit: unit ?? this.unit,
        note: note ?? this.note,
      );
}

/// Parses a legacy free-text amount string into (quantity, unit).
/// Returns null if the string doesn't start with a recognisable number.
(double, String)? _tryParseAmount(String s) {
  final m = RegExp(r'^(\d+(?:\.\d+)?(?:/\d+)?)\s*(.*)$').firstMatch(s);
  if (m == null) return null;
  final raw = m.group(1)!;
  final unit = m.group(2)!.trim();
  double? v;
  if (raw.contains('/')) {
    final p = raw.split('/');
    final n = double.tryParse(p[0]);
    final d = double.tryParse(p[1]);
    if (n != null && d != null && d != 0) v = n / d;
  } else {
    v = double.tryParse(raw);
  }
  return v == null ? null : (v, unit);
}
