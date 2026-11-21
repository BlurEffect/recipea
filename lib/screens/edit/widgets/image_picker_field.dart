import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_colors.dart';

class ImagePickerField extends StatelessWidget {
  final String? imagePath;
  final void Function(String path) onImagePicked;
  final VoidCallback? onRemove;

  const ImagePickerField({
    super.key,
    required this.imagePath,
    required this.onImagePicked,
    this.onRemove,
  });

  Future<void> _pick(BuildContext context, ImageSource source) async {
    final l = AppLocalizations.of(context)!;
    final primary = AppColors.of(context).primary;
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: source,
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
          toolbarColor: primary,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: true,
          hideBottomControls: true,
        ),
        IOSUiSettings(
          title: l.imagePickCropTitle,
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
        ),
      ],
    );
    if (cropped != null) {
      onImagePicked(cropped.path);
    }
  }

  void _showOptions(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
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
              onTap: () {
                Navigator.pop(context);
                _pick(context, ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: Text(l.imagePickTakePhoto),
              onTap: () {
                Navigator.pop(context);
                _pick(context, ImageSource.camera);
              },
            ),
            if (imagePath != null)
              ListTile(
                leading: Icon(Icons.delete_outline, color: AppColors.of(context).error),
                title: Text(l.imagePickRemove, style: TextStyle(color: AppColors.of(context).error)),
                onTap: () {
                  Navigator.pop(context);
                  onRemove?.call();
                },
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
    final colors = AppColors.of(context);
    return GestureDetector(
      onTap: () => _showOptions(context),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = (constraints.maxWidth * 0.5).clamp(120.0, 280.0);
          return Center(
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: colors.divider.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.divider),
              ),
              clipBehavior: Clip.antiAlias,
              child: imagePath != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(
                          File(imagePath!),
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _emptyState(l, colors),
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              l.editChangePhoto,
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    )
                  : _emptyState(l, colors),
            ),
          );
        },
      ),
    );
  }

  Widget _emptyState(AppLocalizations l, AppColors colors) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate_outlined,
              size: 40, color: colors.textSecondary),
          const SizedBox(height: 8),
          Text(
            l.editAddPhoto,
            style: TextStyle(color: colors.textSecondary, fontSize: 14),
          ),
        ],
      );
}
