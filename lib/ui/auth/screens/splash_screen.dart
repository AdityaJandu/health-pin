import 'package:flutter/material.dart';
import 'package:healthpin/theme/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDeepForest,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.health_and_safety,
              size: 100,
              color: AppTheme.backgroundWarmOffWhite,
            ),
            const SizedBox(height: 24),
            Text(
              'HealthPin',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: AppTheme.backgroundWarmOffWhite,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Community Health Map',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
