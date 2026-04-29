import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:healthpin/theme/app_theme.dart';

class ResourceImagePicker extends StatefulWidget {
  final Function(XFile) onImageSelected;
  final XFile? initialImage;

  const ResourceImagePicker({
    super.key,
    required this.onImageSelected,
    this.initialImage,
  });

  @override
  State<ResourceImagePicker> createState() => _ResourceImagePickerState();
}

class _ResourceImagePickerState extends State<ResourceImagePicker> {
  XFile? _imageFile;
  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _imageFile = widget.initialImage;
    _loadImageData();
  }

  Future<void> _loadImageData() async {
    if (_imageFile != null && kIsWeb) {
      final bytes = await _imageFile!.readAsBytes();
      setState(() => _imageBytes = bytes);
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageFile = pickedFile;
          _imageBytes = bytes;
        });
      } else {
        setState(() => _imageFile = pickedFile);
      }
      widget.onImageSelected(pickedFile);
    }
  }

  ImageProvider? _getImageProvider() {
    if (_imageFile == null) return null;
    if (kIsWeb) {
      return _imageBytes != null ? MemoryImage(_imageBytes!) : null;
    } else {
      return FileImage(File(_imageFile!.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = _getImageProvider();
    final hasImage = imageProvider != null;

    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 190,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
          image: hasImage
              ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
              : null,
          gradient: hasImage
              ? null
              : LinearGradient(
                  colors: [
                    AppTheme.primaryDeepForest.withAlpha(200),
                    AppTheme.primaryDeepForest.withAlpha(140),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
        ),
        child: hasImage
            ? Stack(
                children: [
                  // Dark scrim over image
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withAlpha(100),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Edit badge
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(140),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'CHANGE PHOTO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_a_photo_outlined,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'ADD RESOURCE PHOTO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to select from gallery',
                    style: TextStyle(
                      color: Colors.white.withAlpha(180),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
