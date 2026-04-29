import 'package:flutter/material.dart';
import 'package:healthpin/components/custom_text_field.dart';
import 'package:healthpin/models/resource_model.dart';
import 'package:healthpin/models/resource_type.dart';
import 'package:healthpin/services/auth_service.dart';
import 'package:healthpin/services/location_permission_service.dart';
import 'package:healthpin/services/resource_service.dart';
import 'package:healthpin/theme/app_theme.dart';

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

  ResourceType _selectedType = ResourceType.clinic;
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

        // Clear all controllers
        _nameController.clear();
        _descriptionController.clear();
        _addressController.clear();
        _contactController.clear();
        _hoursController.clear();
        _latController.clear();
        _lngController.clear();

        // Reset form state
        _formKey.currentState!.reset();

        // Navigate back or call success callback
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

  String _formatTypeName(ResourceType type) {
    return type.name
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}')
        .trim()
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWarmOffWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'ADD NEW PIN',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            letterSpacing: 1.2,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pin a health resource so your community can find it.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textCharcoal.withAlpha(160),
                ),
              ),
              const SizedBox(height: 32),

              // ── Resource Name ──────────────────────────────────────
              CustomTextField(
                label: 'RESOURCE NAME',
                hintText: 'e.g., Central Community Hospital',
                controller: _nameController,
              ),
              const SizedBox(height: 24),

              // ── Resource Type ──────────────────────────────────────
              Text(
                'RESOURCE TYPE',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundWarmOffWhite,
                  borderRadius: BorderRadius.circular(AppTheme.defaultRadius),
                  border: Border.all(
                    color: AppTheme.textCharcoal.withAlpha(40),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<ResourceType>(
                    value: _selectedType,
                    isExpanded: true,
                    items: ResourceType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(_formatTypeName(type)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _selectedType = value);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Address ────────────────────────────────────────────
              CustomTextField(
                label: 'ADDRESS',
                hintText: 'e.g., 12 Main Street, Nairobi',
                controller: _addressController,
              ),
              const SizedBox(height: 24),

              // ── Coordinates ────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'LATITUDE',
                      hintText: '0.000000',
                      controller: _latController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      label: 'LONGITUDE',
                      hintText: '0.000000',
                      controller: _lngController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: _isFetchingLocation ? null : _fetchCurrentLocation,
                icon: _isFetchingLocation
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location, size: 18),
                label: Text(
                  _isFetchingLocation
                      ? 'FETCHING LOCATION...'
                      : 'USE CURRENT LOCATION',
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primaryDeepForest,
                  padding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: 24),

              // ── Contact ────────────────────────────────────────────
              CustomTextField(
                label: 'CONTACT NUMBER (OPTIONAL)',
                hintText: 'e.g., +254 700 000 000',
                controller: _contactController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),

              // ── Opening Hours ──────────────────────────────────────
              CustomTextField(
                label: 'OPENING HOURS (OPTIONAL)',
                hintText: 'e.g., Mon–Fri 8am–6pm, Emergency 24/7',
                controller: _hoursController,
              ),
              const SizedBox(height: 24),

              // ── Description ────────────────────────────────────────
              CustomTextField(
                label: 'ADDITIONAL DETAILS (OPTIONAL)',
                hintText: 'Special services, languages spoken, etc.',
                controller: _descriptionController,
              ),
              const SizedBox(height: 40),

              // ── Submit ─────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitResource,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('SUBMIT RESOURCE'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
