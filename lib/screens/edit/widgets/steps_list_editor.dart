import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/recipe_step.dart';
import '../../../theme/app_colors.dart';

class StepsListEditor extends StatefulWidget {
  final List<RecipeStep> steps;
  final void Function(List<RecipeStep>) onChanged;
  final ValueChanged<String>? onImageRemoved;

  const StepsListEditor({
    super.key,
    required this.steps,
    required this.onChanged,
    this.onImageRemoved,
  });

  @override
  State<StepsListEditor> createState() => _StepsListEditorState();
}

class _StepsListEditorState extends State<StepsListEditor> {
  late List<TextEditingController> _controllers;
  late List<String> _ids;
  late List<String?> _imagePaths;
  late List<bool> _imageExpanded;
  bool _allImagesVisible = true;

  @override
  void initState() {
    super.initState();
    _controllers = widget.steps
        .map((s) => TextEditingController(text: s.instruction))
        .toList();
    _ids = widget.steps.map((s) => s.id).toList();
    _imagePaths = widget.steps.map((s) => s.imagePath).toList();
    _imageExpanded = widget.steps.map((_) => true).toList();
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
    setState(() {
      _controllers.add(TextEditingController());
      _ids.add(const Uuid().v4());
      _imagePaths.add(null);
      _imageExpanded.add(true);
    });
  }

  void _removeStep(int index) {
    final removedImage = _imagePaths[index];
    setState(() {
      _controllers[index].dispose();
      _controllers.removeAt(index);
      _ids.removeAt(index);
      _imagePaths.removeAt(index);
      _imageExpanded.removeAt(index);
    });
    if (removedImage != null) widget.onImageRemoved?.call(removedImage);
    _notify();
  }

  void _notify() {
    final steps = <RecipeStep>[];
    for (int i = 0; i < _controllers.length; i++) {
      final text = _controllers[i].text.trim();
      if (text.isNotEmpty) {
        steps.add(RecipeStep(
          id: _ids[i],
          order: i,
          instruction: text,
          imagePath: _imagePaths[i],
        ));
      }
    }
    widget.onChanged(steps);
  }

  Future<void> _pickStepImage(int index, BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    final source = await _showImageSourceSheet(context, l, hasImage: _imagePaths[index] != null);
    if (source == null) return;
    if (source == _ImageAction.remove) {
      final old = _imagePaths[index];
      setState(() => _imagePaths[index] = null);
      if (old != null) widget.onImageRemoved?.call(old);
      _notify();
      return;
    }

    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: source == _ImageAction.gallery ? ImageSource.gallery : ImageSource.camera,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (xFile == null) return;

    final cropped = await ImageCropper().cropImage(
      sourcePath: xFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: l.imagePickCropTitle,
          toolbarColor: AppColors.primary,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: true,
          hideBottomControls: true,
        ),
        IOSUiSettings(
          title: l.imagePickCropTitle,
          aspectRatioLockEnabled: true,
        ),
      ],
    );
    if (cropped == null) return;

    setState(() => _imagePaths[index] = cropped.path);
    _notify();
  }

  Future<_ImageAction?> _showImageSourceSheet(
      BuildContext context, AppLocalizations l, {required bool hasImage}) {
    return showModalBottomSheet<_ImageAction>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l.imagePickFromLibrary),
              onTap: () => Navigator.pop(context, _ImageAction.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: Text(l.imagePickTakePhoto),
              onTap: () => Navigator.pop(context, _ImageAction.camera),
            ),
            if (hasImage)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.error),
                title: Text(l.imagePickRemove,
                    style: const TextStyle(color: AppColors.error)),
                onTap: () => Navigator.pop(context, _ImageAction.remove),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final hasAnyImage = _imagePaths.any((p) => p != null);
    return Column(
      children: [
        if (hasAnyImage)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(Icons.photo_outlined, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  l.editStepImagesLabel,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() => _allImagesVisible = !_allImagesVisible),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 32),
                  ),
                  child: Text(
                    _allImagesVisible ? l.editHideImages : l.editShowImages,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _controllers.length,
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (newIndex > oldIndex) newIndex--;
              final item = _controllers.removeAt(oldIndex);
              _controllers.insert(newIndex, item);
              final id = _ids.removeAt(oldIndex);
              _ids.insert(newIndex, id);
              final img = _imagePaths.removeAt(oldIndex);
              _imagePaths.insert(newIndex, img);
              final exp = _imageExpanded.removeAt(oldIndex);
              _imageExpanded.insert(newIndex, exp);
            });
            _notify();
          },
          itemBuilder: (context, i) {
            final imagePath = _imagePaths[i];
            return Row(
              key: ValueKey(_ids[i]),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step number badge
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
                // Instruction + image
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _controllers[i],
                        onChanged: (_) => _notify(),
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.editStepHint(i + 1),
                          isDense: true,
                        ),
                        textInputAction: TextInputAction.newline,
                      ),
                      const SizedBox(height: 6),
                      if (imagePath != null) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(
                                _allImagesVisible && _imageExpanded[i]
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 16,
                              ),
                              color: AppColors.textSecondary,
                              onPressed: () => setState(() => _imageExpanded[i] = !_imageExpanded[i]),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            ),
                            GestureDetector(
                              onTap: () => _pickStepImage(i, context),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                child: const Icon(Icons.edit_outlined, size: 16, color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                        if (_allImagesVisible && _imageExpanded[i]) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Image.file(
                                File(imagePath),
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => const SizedBox.shrink(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                      ] else
                        TextButton.icon(
                          onPressed: () => _pickStepImage(i, context),
                          icon: const Icon(Icons.add_photo_alternate_outlined, size: 16),
                          label: Text(AppLocalizations.of(context)!.editAddPhoto),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 28),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            textStyle: const TextStyle(fontSize: 13),
                          ),
                        ),
                    ],
                  ),
                ),
                // Remove step button
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
                // Drag handle
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
            label: Text(AppLocalizations.of(context)!.editAddStep),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          ),
        ),
      ],
    );
  }
}

enum _ImageAction { gallery, camera, remove }
