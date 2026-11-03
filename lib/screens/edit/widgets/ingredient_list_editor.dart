import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../data/seed_data.dart';
import '../../../models/ingredient.dart';
import '../../../theme/app_colors.dart';

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
          final qty = double.tryParse(qtyText);
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
          label: const Text('Add ingredient'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
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
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    hintText: 'Qty',
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(width: 6),
              // Unit field
              _UnitField(
                controller: row.unitController,
                focusNode: row.unitFocusNode,
                onChanged: _notify,
              ),
              const SizedBox(width: 6),
              // Name
              Expanded(
                child: TextField(
                  controller: row.nameController,
                  onChanged: (_) => _notify(),
                  decoration: const InputDecoration(
                    hintText: 'Ingredient name',
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 14),
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
              // Delete
              if (_rows.length > 1)
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, size: 20),
                  color: AppColors.textSecondary,
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
                  child: const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Icon(Icons.drag_handle, color: AppColors.divider),
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
              onChanged: (_) => _notify(),
              decoration: const InputDecoration(
                hintText: 'Note (e.g. "to taste", "finely chopped")',
                hintStyle: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
                isDense: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: UnderlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
  final VoidCallback onChanged;

  const _UnitField({
    required this.controller,
    required this.focusNode,
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
          if (value.text.isEmpty) return const Iterable.empty();
          return ingredientUnits.where(
            (u) => u.startsWith(value.text.toLowerCase()),
          );
        },
        onSelected: (_) => onChanged(),
        fieldViewBuilder: (context, textController, fn, _) {
          return TextField(
            controller: textController,
            focusNode: fn,
            onChanged: (_) => onChanged(),
            style: const TextStyle(fontSize: 14),
            decoration: const InputDecoration(
              hintText: 'Unit',
              hintStyle: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              isDense: true,
            ),
          );
        },
        optionsViewBuilder: (context, onSelected, options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(4),
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

  _IngredientRow({
    String? id,
    required this.nameController,
    required this.quantityController,
    required this.noteController,
    required this.unitController,
    FocusNode? unitFocusNode,
  })  : id = id ?? _rowUuid.v4(),
        unitFocusNode = unitFocusNode ?? FocusNode();

  factory _IngredientRow.fromIngredient(Ingredient ing) => _IngredientRow(
        nameController: TextEditingController(text: ing.name),
        quantityController: TextEditingController(
          text: ing.quantity != null ? _fmtQty(ing.quantity!) : '',
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
  }
}

String _fmtQty(double v) {
  if (v == v.truncateToDouble()) return v.toInt().toString();
  return v.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
}
