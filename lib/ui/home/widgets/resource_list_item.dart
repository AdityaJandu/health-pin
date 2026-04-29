import 'package:flutter/material.dart';
import 'package:healthpin/models/resource_model.dart';
import 'package:healthpin/theme/app_theme.dart';
import 'package:healthpin/components/health_card.dart';

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

  @override
  Widget build(BuildContext context) {
    final color = resource.type.color;
    final icon = resource.type.icon;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: HealthCard(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resource.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    resource.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.outline,
                        ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.near_me,
                        size: 12,
                        color: AppTheme.primaryDeepForest,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        distance,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.primaryDeepForest,
                            ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.thumb_up_outlined,
                        size: 12,
                        color: AppTheme.primaryDeepForest,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${resource.upvoteCount}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.primaryDeepForest,
                            ),
                      ),
                      if (resource.isVerified) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.verified,
                          size: 12,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Verified',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.green,
                              ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
