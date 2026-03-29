import 'package:flutter/material.dart';
import '../../../models/ingredient.dart';
import '../../../theme/app_colors.dart';

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
    _rows = widget.ingredients
        .map((ing) => _IngredientRow(
              nameController: TextEditingController(text: ing.name),
              amountController: TextEditingController(text: ing.amount),
            ))
        .toList();
    if (_rows.isEmpty) _addRow();
  }

  @override
  void dispose() {
    for (final row in _rows) {
      row.nameController.dispose();
      row.amountController.dispose();
    }
    super.dispose();
  }

  void _addRow() {
    setState(() {
      _rows.add(_IngredientRow(
        nameController: TextEditingController(),
        amountController: TextEditingController(),
      ));
    });
  }

  void _removeRow(int index) {
    setState(() {
      _rows[index].nameController.dispose();
      _rows[index].amountController.dispose();
      _rows.removeAt(index);
    });
    _notify();
  }

  void _notify() {
    widget.onChanged(_rows
        .map((r) => Ingredient(
              name: r.nameController.text.trim(),
              amount: r.amountController.text.trim(),
            ))
        .where((ing) => ing.name.isNotEmpty)
        .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < _rows.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                // Amount field (narrower)
                SizedBox(
                  width: 90,
                  child: TextField(
                    controller: _rows[i].amountController,
                    onChanged: (_) => _notify(),
                    decoration: const InputDecoration(
                      hintText: 'Amount',
                      isDense: true,
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(width: 10),
                // Name field (fills remaining space)
                Expanded(
                  child: TextField(
                    controller: _rows[i].nameController,
                    onChanged: (_) => _notify(),
                    decoration: const InputDecoration(
                      hintText: 'Ingredient name',
                      isDense: true,
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                ),
                // Remove button
                if (_rows.length > 1)
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, size: 20),
                    color: AppColors.textSecondary,
                    onPressed: () => _removeRow(i),
                    padding: const EdgeInsets.only(left: 8),
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _addRow,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add ingredient'),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          ),
        ),
      ],
    );
  }
}

class _IngredientRow {
  final TextEditingController nameController;
  final TextEditingController amountController;

  _IngredientRow({
    required this.nameController,
    required this.amountController,
  });
}
