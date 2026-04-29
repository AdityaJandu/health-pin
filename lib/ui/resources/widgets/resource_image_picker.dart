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
        setState(() {
          _imageFile = pickedFile;
        });
      }
      widget.onImageSelected(pickedFile);
    }
  }

  ImageProvider? _getImageProvider() {
    if (_imageFile == null) return null;
    if (kIsWeb) {
      if (_imageBytes != null) {
        return MemoryImage(_imageBytes!);
      }
      return null;
    } else {
      return FileImage(File(_imageFile!.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RESOURCE PHOTO',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.backgroundWarmOffWhite,
              borderRadius: BorderRadius.circular(AppTheme.defaultRadius),
              border: Border.all(
                color: AppTheme.textCharcoal.withAlpha(40),
              ),
              image: _getImageProvider() != null
                  ? DecorationImage(
                      image: _getImageProvider()!,
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: _getImageProvider() == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo_outlined,
                        size: 40,
                        color: AppTheme.primaryDeepForest.withAlpha(180),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'TAP TO SELECT FROM GALLERY',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppTheme.primaryDeepForest,
                            ),
                      ),
                    ],
                  )
                : Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      margin: const EdgeInsets.all(12),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(120),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
