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
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: isFetchingLocation ? null : onFetchLocation,
            icon: isFetchingLocation
                ? SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.primaryDeepForest,
                    ),
                  )
                : const Icon(Icons.my_location_rounded, size: 17),
            label: Text(
              isFetchingLocation
                  ? 'FETCHING LOCATION...'
                  : 'USE CURRENT LOCATION',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryDeepForest,
              side: BorderSide(color: AppTheme.primaryDeepForest.withAlpha(80)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
