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
          return Ingredient(
            name: name,
            quantity: qty,
            unit: r.selectedUnit,
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
              // Unit picker
              _UnitDropdown(
                value: row.selectedUnit,
                onChanged: (u) {
                  setState(() => row.selectedUnit = u);
                  _notify();
                },
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

class _UnitDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const _UnitDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButton<String?>(
        value: value,
        isDense: true,
        underline: const SizedBox(),
        hint: const Text('–', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        items: [
          const DropdownMenuItem<String?>(
            value: null,
            child: Text('–', style: TextStyle(fontSize: 14)),
          ),
          // If the stored unit isn't in the standard list (e.g. migrated from
          // free-text "cups" → not matching canonical "cup"), include it so the
          // dropdown can display it without asserting.
          if (value != null && !ingredientUnits.contains(value))
            DropdownMenuItem<String?>(
              value: value,
              child: Text(value!, style: const TextStyle(fontSize: 14)),
            ),
          ...ingredientUnits.map(
            (u) => DropdownMenuItem<String?>(
              value: u,
              child: Text(u, style: const TextStyle(fontSize: 14)),
            ),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _IngredientRow {
  final String id;
  final TextEditingController nameController;
  final TextEditingController quantityController;
  final TextEditingController noteController;
  String? selectedUnit;

  _IngredientRow({
    String? id,
    required this.nameController,
    required this.quantityController,
    required this.noteController,
    this.selectedUnit,
  }) : id = id ?? _rowUuid.v4();

  factory _IngredientRow.fromIngredient(Ingredient ing) => _IngredientRow(
        nameController: TextEditingController(text: ing.name),
        quantityController: TextEditingController(
          text: ing.quantity != null ? _fmtQty(ing.quantity!) : '',
        ),
        noteController: TextEditingController(text: ing.note ?? ''),
        selectedUnit: ing.unit,
      );

  factory _IngredientRow.empty() => _IngredientRow(
        nameController: TextEditingController(),
        quantityController: TextEditingController(),
        noteController: TextEditingController(),
      );

  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    noteController.dispose();
  }
}

String _fmtQty(double v) {
  if (v == v.truncateToDouble()) return v.toInt().toString();
  return v.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
}
