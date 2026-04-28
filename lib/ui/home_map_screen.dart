import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../components/health_card.dart';

class HomeMapScreen extends StatelessWidget {
  const HomeMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Simulated Map Background
          Container(
            color: AppTheme.backgroundWarmOffWhite,
            child: const Center(
              child: Text('Map View Placeholder'),
            ),
          ),
          
          // Custom Top App Bar overlay
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: HealthCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: AppTheme.textCharcoal),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search for health resources...',
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          filled: false,
                        ),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const Icon(Icons.filter_list, color: AppTheme.textCharcoal),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Action Area
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Nearby Resources',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  HealthCard(
                    onTap: () {},
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryDeepForest.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.local_hospital, color: AppTheme.primaryDeepForest),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('City General Hospital', style: Theme.of(context).textTheme.titleMedium),
                              Text('1.2 miles away • Open 24/7', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.outline)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppTheme.accentClayOrange,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
