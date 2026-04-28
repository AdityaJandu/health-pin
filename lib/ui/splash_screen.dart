import 'package:flutter/material.dart';
import 'package:healthpin/ui/auth_gate.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthGate()),
      );
    });
  }

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
