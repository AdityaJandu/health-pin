import 'package:flutter/material.dart';
import 'package:healthpin/theme/app_theme.dart';

class SectionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<Widget> children;

  const SectionCard({
    super.key,
    required this.label,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryDeepForest.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 16,
                    color: AppTheme.primaryDeepForest,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppTheme.primaryDeepForest,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
          // Divider
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Divider(
              height: 1,
              thickness: 1,
              color: AppTheme.textCharcoal.withAlpha(15),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}
