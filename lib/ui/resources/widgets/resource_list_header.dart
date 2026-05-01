import 'package:flutter/material.dart';
import 'package:healthpin/components/enhanced_search_bar.dart';
import 'package:healthpin/theme/app_theme.dart';

class ResourceListHeader extends StatelessWidget {
  final int count;
  final bool isSearching;
  final bool hasPosition;
  final ValueChanged<String> onSearchChanged;

  const ResourceListHeader({
    super.key,
    required this.count,
    required this.isSearching,
    required this.hasPosition,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;
    return Container(
      color: AppTheme.primaryDeepForest,
      padding: EdgeInsets.fromLTRB(20, safeTop + 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NEARBY RESOURCES',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasPosition
                          ? 'Sorted by distance from you'
                          : 'Active locations in your area',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withAlpha(180),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
              // Resource count badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$count pins',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Reusable Search Bar
          EnhancedSearchBar(onChanged: onSearchChanged, resultCount: count),
        ],
      ),
    );
  }
}
