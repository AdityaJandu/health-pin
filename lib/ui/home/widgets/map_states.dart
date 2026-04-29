import 'package:flutter/material.dart';
import 'package:healthpin/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Loading State
// ─────────────────────────────────────────────────────────────────────────────
class MapLoadingState extends StatelessWidget {
  const MapLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.backgroundWarmOffWhite,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.primaryDeepForest.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryDeepForest,
                  strokeWidth: 2.5,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Finding your location…',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.textCharcoal.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Make sure location services are on',
              style: TextStyle(fontSize: 13, color: AppTheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error State
// ─────────────────────────────────────────────────────────────────────────────
class MapErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const MapErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.backgroundWarmOffWhite,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_off_rounded,
                  size: 32,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Location Unavailable',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.outline,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryDeepForest,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text(
                    'Try Again',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
