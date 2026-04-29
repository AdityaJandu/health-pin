import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:healthpin/components/custom_text_field.dart';
import 'package:healthpin/models/resource_model.dart';
import 'package:healthpin/models/resource_type.dart';
import 'package:healthpin/services/auth_service.dart';
import 'package:healthpin/services/image_service.dart';
import 'package:healthpin/services/location_permission_service.dart';
import 'package:healthpin/services/resource_service.dart';
import 'package:healthpin/theme/app_theme.dart';
import 'package:healthpin/ui/resources/widgets/location_input_section.dart';
import 'package:healthpin/ui/resources/widgets/resource_image_picker.dart';
import 'package:healthpin/ui/resources/widgets/resource_type_dropdown.dart';
import 'package:healthpin/ui/resources/widgets/section_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ADD RESOURCE SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class AddResourceScreen extends StatefulWidget {
  final VoidCallback? onSuccess;
  const AddResourceScreen({super.key, this.onSuccess});

  @override
  State<AddResourceScreen> createState() => _AddResourceScreenState();
}

class _AddResourceScreenState extends State<AddResourceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactController = TextEditingController();
  final _hoursController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();

  final _resourceService = ResourceService();
  final _locationService = LocationPermissionService();
  final _authService = AuthService();
  final _imageService = ImageService();

  ResourceType _selectedType = ResourceType.clinic;
  File? _imageFile;
  Uint8List? _webImage;
  bool _isSubmitting = false;
  bool _isFetchingLocation = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _hoursController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _fetchCurrentLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
      final position = await _locationService.determinePosition();
      setState(() {
        _latController.text = position.latitude.toStringAsFixed(6);
        _lngController.text = position.longitude.toStringAsFixed(6);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not fetch location: $e')));
      }
    } finally {
      setState(() => _isFetchingLocation = false);
    }
  }

  Future<void> _submitResource() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = _authService.getUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to add a resource'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      String? photoUrl;

      final hasImage = kIsWeb ? _webImage != null : _imageFile != null;
      if (hasImage) {
        final bytes = kIsWeb ? _webImage! : await _imageFile!.readAsBytes();
        final ext = kIsWeb ? 'png' : _imageFile!.path.split('.').last;
        final fileName = "${DateTime.now().millisecondsSinceEpoch}.$ext";
        final path = 'health-care/$fileName';
        photoUrl = await _imageService.uploadImage(bytes, path);
      }

      final resource = ResourceModel(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _selectedType,
        latitude: double.parse(_latController.text.trim()),
        longitude: double.parse(_lngController.text.trim()),
        address: _addressController.text.trim(),
        contactNumber: _contactController.text.trim().isEmpty
            ? null
            : _contactController.text.trim(),
        openingHours: _hoursController.text.trim().isEmpty
            ? null
            : _hoursController.text.trim(),
        photoUrl: photoUrl,
        isVerified: false,
        upvoteCount: 0,
        submittedBy: userId,
        createdAt: DateTime.now(),
      );

      await _resourceService.createResource(resource);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resource added successfully!'),
            backgroundColor: AppTheme.primaryDeepForest,
          ),
        );

        _nameController.clear();
        _descriptionController.clear();
        _addressController.clear();
        _contactController.clear();
        _hoursController.clear();
        _latController.clear();
        _lngController.clear();
        _formKey.currentState!.reset();

        if (widget.onSuccess != null) {
          widget.onSuccess!();
        } else if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to add resource: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWarmOffWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryDeepForest,
        title: Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ADD NEW PIN',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Pin a health resource for your community',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withAlpha(180),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // ── Scrollable Form ──────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Photo ──────────────────────────────────────────────
                    ResourceImagePicker(
                      onImageSelected: (xfile) async {
                        final bytes = await xfile.readAsBytes();
                        setState(() {
                          if (kIsWeb) {
                            _webImage = bytes;
                          } else {
                            _imageFile = File(xfile.path);
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 28),

                    // ── Basic Info Card ────────────────────────────────────
                    SectionCard(
                      label: 'BASIC INFO',
                      icon: Icons.info_outline_rounded,
                      children: [
                        CustomTextField(
                          label: 'RESOURCE NAME',
                          hintText: 'e.g., Central Community Hospital',
                          controller: _nameController,
                        ),
                        const SizedBox(height: 20),
                        ResourceTypeDropdown(
                          value: _selectedType,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedType = value);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Location Card ──────────────────────────────────────
                    SectionCard(
                      label: 'LOCATION',
                      icon: Icons.location_on_outlined,
                      children: [
                        CustomTextField(
                          label: 'ADDRESS',
                          hintText: 'e.g., 12 Main Street, Nairobi',
                          controller: _addressController,
                        ),
                        const SizedBox(height: 20),
                        LocationInputSection(
                          latController: _latController,
                          lngController: _lngController,
                          isFetchingLocation: _isFetchingLocation,
                          onFetchLocation: _fetchCurrentLocation,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Contact Card ───────────────────────────────────────
                    SectionCard(
                      label: 'CONTACT & HOURS',
                      icon: Icons.phone_outlined,
                      children: [
                        CustomTextField(
                          label: 'CONTACT NUMBER (OPTIONAL)',
                          hintText: 'e.g., +254 700 000 000',
                          controller: _contactController,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          label: 'OPENING HOURS (OPTIONAL)',
                          hintText: 'e.g., Mon–Fri 8am–6pm, Emergency 24/7',
                          controller: _hoursController,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Details Card ───────────────────────────────────────
                    SectionCard(
                      label: 'ADDITIONAL DETAILS',
                      icon: Icons.notes_rounded,
                      children: [
                        CustomTextField(
                          label: 'DETAILS (OPTIONAL)',
                          hintText: 'Special services, languages spoken, etc.',
                          controller: _descriptionController,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // ── Submit Button ──────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitResource,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentClayOrange,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppTheme.accentClayOrange
                              .withAlpha(100),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.push_pin_rounded, size: 20),
                                  SizedBox(width: 10),
                                  Text(
                                    'SUBMIT RESOURCE',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.1,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
