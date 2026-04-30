import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:healthpin/theme/app_theme.dart';
import 'package:healthpin/ui/auth/auth_gate.dart';
import 'package:healthpin/main.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FlutterSplashScreen.fadeIn(
      backgroundColor: AppTheme.primaryDeepForest,
      childWidget: const SplashView(),
      asyncNavigationCallback: () async {
        await Future.wait([
          initializationFuture,
          Future.delayed(const Duration(seconds: 2)),
        ]);

        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AuthGate()),
          );
        }
      },
    );
  }
}

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
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
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Community Health Map',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.onPrimaryContainer,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
