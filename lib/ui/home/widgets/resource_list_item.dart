import 'package:flutter/material.dart';
import 'package:healthpin/models/resource_model.dart';
import 'package:healthpin/theme/app_theme.dart';
import 'package:healthpin/ui/home/widgets/resource_card.dart';

class ResourceListItem extends StatelessWidget {
  final ResourceModel resource;
  final String distance;
  final VoidCallback? onTap;

  const ResourceListItem({
    super.key,
    required this.resource,
    required this.distance,
    this.onTap,
  });

  /// Safely formats camelCase enum names into Title Case (e.g., "mentalHealth" -> "Mental health")
  String _formatTypeName(String name) {
    if (name.isEmpty) return name;
    final spaced = name
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}')
        .trim();
    return '${spaced[0].toUpperCase()}${spaced.substring(1).toLowerCase()}';
  }

  @override
  Widget build(BuildContext context) {
    final color = resource.type.color;
    final icon = resource.type.icon;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ResourceCard(
        onTap: onTap,
        padding: EdgeInsets.zero,
        child: MergeSemantics(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Left Side: Icon + Votes
                Column(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(child: Icon(icon, color: color, size: 24)),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.thumb_up_alt_rounded,
                          size: 16,
                          color: AppTheme.outline.withValues(alpha: 0.8),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${resource.upvoteCount}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.outline.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(width: 16),

                // 🔹 Right Side: Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Name + Type Tag
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  resource.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                if (resource.isVerified) ...[
                                  const SizedBox(height: 4),
                                  const _VerifiedBadge(),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Type Tag (Pill on Right)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _formatTypeName(resource.type.name),
                              style: TextStyle(
                                fontSize: 10,
                                color: color,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Details
                      _IconTextRow(
                        icon: Icons.location_on_rounded,
                        text: resource.address,
                      ),

                      if (resource.openingHours?.isNotEmpty ?? false) ...[
                        const SizedBox(height: 4),
                        _IconTextRow(
                          icon: Icons.access_time_filled_rounded,
                          text: resource.openingHours!,
                        ),
                      ],

                      const SizedBox(height: 12),

                      // Bottom Row: Distance + Chevron
                      Row(
                        children: [
                          _Pill(
                            icon: Icons.near_me_rounded,
                            label: distance,
                            color: AppTheme.primaryDeepForest,
                            semanticLabel: 'Distance: $distance',
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: AppTheme.outline.withValues(alpha: 0.3),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// REUSABLE SUB-WIDGETS
// -----------------------------------------------------------------------------

class _IconTextRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _IconTextRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: AppTheme.outline),
        const SizedBox(width: 3),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.outline,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Verified',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.green.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified, size: 11, color: Colors.green),
            SizedBox(width: 3),
            Text(
              'Verified',
              style: TextStyle(
                fontSize: 10,
                color: Colors.green,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String semanticLabel;

  const _Pill({
    required this.icon,
    required this.label,
    required this.color,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
