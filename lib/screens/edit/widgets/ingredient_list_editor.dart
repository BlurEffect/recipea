import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../../../data/seed_data.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/ingredient.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radius.dart';
import '../../../utils/quantity_format.dart';

const _rowUuid = Uuid();

class IngredientListEditor extends StatefulWidget {
  final List<Ingredient> ingredients;
  final void Function(List<Ingredient>) onChanged;

  const IngredientListEditor({
    super.key,
    required this.ingredients,
    required this.onChanged,
  });

  @override
  State<IngredientListEditor> createState() => _IngredientListEditorState();
}

class _IngredientListEditorState extends State<IngredientListEditor> {
  late List<_IngredientRow> _rows;

  @override
  void initState() {
    super.initState();
    _rows = widget.ingredients.map(_IngredientRow.fromIngredient).toList();
    if (_rows.isEmpty) _addRow();
    // Localize any existing stored unit values after first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l = AppLocalizations.of(context)!;
      final sep = decimalSepForLocale(
          Localizations.localeOf(context).languageCode);
      for (final row in _rows) {
        final rawUnit = row.unitController.text;
        if (rawUnit.isNotEmpty) {
          final localized = localizeUnit(rawUnit, l);
          if (localized != rawUnit) row.unitController.text = localized;
        }
        if (sep != '.') {
          final rawQty = row.quantityController.text;
          if (rawQty.contains('.')) {
            row.quantityController.text = rawQty.replaceAll('.', sep);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  void _addRow() {
    setState(() => _rows.add(_IngredientRow.empty()));
  }

  void _removeRow(int index) {
    _rows[index].dispose();
    setState(() => _rows.removeAt(index));
    _notify();
  }

  void _notify() {
    final ingredients = _rows
        .map((r) {
          final name = r.nameController.text.trim();
          if (name.isEmpty) return null;
          final qtyText = r.quantityController.text.trim();
          final qty = _parseQty(qtyText);
          final note = r.noteController.text.trim();
          final rawUnit = r.unitController.text.trim();
          return Ingredient(
            name: name,
            quantity: qty,
            unit: rawUnit.isEmpty ? null : rawUnit.toLowerCase(),
            note: note.isEmpty ? null : note,
          );
        })
        .whereType<Ingredient>()
        .toList();
    widget.onChanged(ingredients);
  }

  void _reorderRow(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final row = _rows.removeAt(oldIndex);
      _rows.insert(newIndex, row);
    });
    _notify();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _rows.length,
          onReorder: _reorderRow,
          itemBuilder: (_, i) => _buildRow(i),
        ),
        TextButton.icon(
          onPressed: _addRow,
          icon: const Icon(Icons.add, size: 16),
          label: Text(AppLocalizations.of(context)!.editAddIngredient),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  Widget _buildRow(int i) {
    final row = _rows[i];
    return Padding(
      key: ValueKey(row.id),
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Quantity
              SizedBox(
                width: 68,
                child: TextField(
                  controller: row.quantityController,
                  onChanged: (_) => _notify(),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: false,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                  ],
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.editQtyHint,
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 14),
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => row.unitFocusNode.requestFocus(),
                ),
              ),
              const SizedBox(width: 6),
              // Unit field
              _UnitField(
                controller: row.unitController,
                focusNode: row.unitFocusNode,
                nextFocusNode: row.nameFocusNode,
                onChanged: _notify,
              ),
              const SizedBox(width: 6),
              // Name
              Expanded(
                child: TextField(
                  controller: row.nameController,
                  focusNode: row.nameFocusNode,
                  onChanged: (_) => _notify(),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.editIngredientNameHint,
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 14),
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => row.noteFocusNode.requestFocus(),
                ),
              ),
              // Delete
              if (_rows.length > 1)
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, size: 20),
                  color: AppColors.of(context).textSecondary,
                  onPressed: () => _removeRow(i),
                  padding: const EdgeInsets.only(left: 4),
                  constraints: const BoxConstraints(),
                ),
              // Drag handle
              Listener(
                onPointerDown: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                child: ReorderableDragStartListener(
                  index: i,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Icon(Icons.drag_handle, color: AppColors.of(context).divider),
                  ),
                ),
              ),
            ],
          ),
          // Note field (always shown so users know it exists)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 4),
            child: TextField(
              controller: row.noteController,
              focusNode: row.noteFocusNode,
              onChanged: (_) => _notify(),
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.editNoteHint,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode? nextFocusNode;
  final VoidCallback onChanged;

  const _UnitField({
    required this.controller,
    required this.focusNode,
    this.nextFocusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      child: RawAutocomplete<String>(
        textEditingController: controller,
        focusNode: focusNode,
        optionsBuilder: (TextEditingValue value) {
          final l = AppLocalizations.of(context)!;
          final langCode = Localizations.localeOf(context).languageCode;
          final units = ingredientUnits(l, langCode);
          if (value.text.isEmpty) return units;
          return units.where(
            (u) => u.toLowerCase().contains(value.text.toLowerCase()),
          );
        },
        onSelected: (_) => onChanged(),
        fieldViewBuilder: (context, textController, fn, _) {
          return TextField(
            controller: textController,
            focusNode: fn,
            onChanged: (_) => onChanged(),
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.editUnitHint,
              hintStyle: TextStyle(fontSize: 14, color: AppColors.of(context).textSecondary),
              isDense: true,
            ),
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => nextFocusNode?.requestFocus(),
          );
        },
        optionsViewBuilder: (context, onSelected, options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(AppRadius.strip),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200, maxWidth: 120),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (_, index) {
                    final option = options.elementAt(index);
                    return InkWell(
                      onTap: () => onSelected(option),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Text(option,
                            style: const TextStyle(fontSize: 14)),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _IngredientRow {
  final String id;
  final TextEditingController nameController;
  final TextEditingController quantityController;
  final TextEditingController noteController;
  final TextEditingController unitController;
  final FocusNode unitFocusNode;
  final FocusNode nameFocusNode;
  final FocusNode noteFocusNode;

  _IngredientRow({
    String? id,
    required this.nameController,
    required this.quantityController,
    required this.noteController,
    required this.unitController,
    FocusNode? unitFocusNode,
    FocusNode? nameFocusNode,
    FocusNode? noteFocusNode,
  })  : id = id ?? _rowUuid.v4(),
        unitFocusNode = unitFocusNode ?? FocusNode(),
        nameFocusNode = nameFocusNode ?? FocusNode(),
        noteFocusNode = noteFocusNode ?? FocusNode();

  factory _IngredientRow.fromIngredient(Ingredient ing) => _IngredientRow(
        nameController: TextEditingController(text: ing.name),
        quantityController: TextEditingController(
          text: ing.quantity != null ? fmtQty(ing.quantity!) : '',
        ),
        noteController: TextEditingController(text: ing.note ?? ''),
        unitController: TextEditingController(text: ing.unit ?? ''),
      );

  factory _IngredientRow.empty() => _IngredientRow(
        nameController: TextEditingController(),
        quantityController: TextEditingController(),
        noteController: TextEditingController(),
        unitController: TextEditingController(),
      );

  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    noteController.dispose();
    unitController.dispose();
    unitFocusNode.dispose();
    nameFocusNode.dispose();
    noteFocusNode.dispose();
  }
}

// Accepts decimals (dot or comma), simple fractions ("1/2"), and mixed numbers ("1 1/2").
double? _parseQty(String text) {
  if (text.isEmpty) return null;
  final s = text.trim().replaceAll(',', '.');
  final decimal = double.tryParse(s);
  if (decimal != null) return decimal;
  final mixed = RegExp(r'^(\d+)\s+(\d+)/(\d+)$').firstMatch(s);
  if (mixed != null) {
    final den = int.parse(mixed.group(3)!);
    if (den == 0) return null;
    return int.parse(mixed.group(1)!) + int.parse(mixed.group(2)!) / den;
  }
  final frac = RegExp(r'^(\d+)/(\d+)$').firstMatch(s);
  if (frac != null) {
    final den = int.parse(frac.group(2)!);
    if (den == 0) return null;
    return int.parse(frac.group(1)!) / den;
  }
  return null;
}
