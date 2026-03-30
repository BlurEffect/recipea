import 'package:flutter/material.dart';
import '../../../models/recipe_step.dart';
import '../../../theme/app_colors.dart';

class StepsListEditor extends StatefulWidget {
  final List<RecipeStep> steps;
  final void Function(List<RecipeStep>) onChanged;

  const StepsListEditor({
    super.key,
    required this.steps,
    required this.onChanged,
  });

  @override
  State<StepsListEditor> createState() => _StepsListEditorState();
}

class _StepsListEditorState extends State<StepsListEditor> {
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = widget.steps
        .map((s) => TextEditingController(text: s.instruction))
        .toList();
    if (_controllers.isEmpty) _addStep();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addStep() {
    setState(() => _controllers.add(TextEditingController()));
  }

  void _removeStep(int index) {
    setState(() {
      _controllers[index].dispose();
      _controllers.removeAt(index);
    });
    _notify();
  }

  void _notify() {
    final steps = <RecipeStep>[];
    for (int i = 0; i < _controllers.length; i++) {
      final text = _controllers[i].text.trim();
      if (text.isNotEmpty) {
        steps.add(RecipeStep(order: i, instruction: text));
      }
    }
    widget.onChanged(steps);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _controllers.length,
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (newIndex > oldIndex) newIndex--;
              final item = _controllers.removeAt(oldIndex);
              _controllers.insert(newIndex, item);
            });
            _notify();
          },
          itemBuilder: (context, i) {
            return Row(
              key: ValueKey(i),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step number
                Padding(
                  padding: const EdgeInsets.only(top: 12, right: 12),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                // Instruction field
                Expanded(
                  child: TextField(
                    controller: _controllers[i],
                    onChanged: (_) => _notify(),
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Step ${i + 1}...',
                      isDense: true,
                    ),
                    textInputAction: TextInputAction.newline,
                  ),
                ),
                // Remove button
                if (_controllers.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: IconButton(
                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                      color: AppColors.textSecondary,
                      onPressed: () => _removeStep(i),
                      padding: const EdgeInsets.only(left: 8),
                      constraints: const BoxConstraints(),
                    ),
                  ),
                // Drag handle — unfocus first to avoid LeaderLayer/FollowerLayer
                // paint-order exception when a TextField is active during drag.
                Listener(
                  onPointerDown: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  child: ReorderableDragStartListener(
                    index: i,
                    child: const Padding(
                      padding: EdgeInsets.only(top: 8, left: 4),
                      child: Icon(Icons.drag_handle, color: AppColors.divider),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _addStep,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add step'),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          ),
        ),
      ],
    );
  }
}
