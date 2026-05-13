import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';

class PickedImage {
  final Uint8List bytes;
  final String name;
  const PickedImage({required this.bytes, required this.name});
}

class ImagePickerGrid extends StatelessWidget {
  final List<PickedImage> images;
  final ValueChanged<List<PickedImage>> onChanged;
  final int maxImages;

  const ImagePickerGrid({
    super.key,
    required this.images,
    required this.onChanged,
    this.maxImages = 10,
  });

  Future<void> _pick(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final remaining = maxImages - images.length;
    if (remaining <= 0) return;

    if (source == ImageSource.gallery) {
      final picked = await picker.pickMultiImage(imageQuality: 85, limit: remaining);
      if (picked.isEmpty) return;
      final newImages = await Future.wait(
        picked.map((xf) async => PickedImage(bytes: await xf.readAsBytes(), name: xf.name)),
      );
      onChanged([...images, ...newImages]);
    } else {
      final picked = await picker.pickImage(source: source, imageQuality: 85);
      if (picked == null) return;
      onChanged([...images, PickedImage(bytes: await picked.readAsBytes(), name: picked.name)]);
    }
  }

  void _remove(int index) {
    final updated = [...images];
    updated.removeAt(index);
    onChanged(updated);
  }

  void _showSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pick(context, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pick(context, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canAdd = images.length < maxImages;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              if (canAdd)
                GestureDetector(
                  onTap: () => _showSourceSheet(context),
                  child: Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined,
                            size: 28, color: AppColors.primary),
                        SizedBox(height: 4),
                        Text('Add Photo',
                            style: TextStyle(
                                fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
              ...images.asMap().entries.map((entry) {
                final i = entry.key;
                final img = entry.value;
                return Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: i == 0 ? AppColors.primary : AppColors.border,
                          width: i == 0 ? 2 : 1,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.memory(img.bytes, fit: BoxFit.cover),
                    ),
                    if (i == 0)
                      Positioned(
                        bottom: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('Cover',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),
                    Positioned(
                      top: 2,
                      right: 12,
                      child: GestureDetector(
                        onTap: () => _remove(i),
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close,
                              size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${images.length}/$maxImages photos · First photo is the cover',
          style: const TextStyle(
              fontSize: 11, color: AppColors.textTertiary),
        ),
      ],
    );
  }
}
