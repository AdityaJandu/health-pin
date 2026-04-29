import 'package:flutter/material.dart';
import 'package:healthpin/components/custom_text_field.dart';
import 'package:healthpin/theme/app_theme.dart';

class LocationInputSection extends StatelessWidget {
  final TextEditingController latController;
  final TextEditingController lngController;
  final bool isFetchingLocation;
  final VoidCallback onFetchLocation;

  const LocationInputSection({
    super.key,
    required this.latController,
    required this.lngController,
    required this.isFetchingLocation,
    required this.onFetchLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'LATITUDE',
                hintText: '0.000000',
                controller: latController,
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
                controller: lngController,
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
          onPressed: isFetchingLocation ? null : onFetchLocation,
          icon: isFetchingLocation
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.my_location, size: 18),
          label: Text(
            isFetchingLocation
                ? 'FETCHING LOCATION...'
                : 'USE CURRENT LOCATION',
          ),
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.primaryDeepForest,
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}
