import 'package:flutter/material.dart';
import 'package:healthpin/models/resource_model.dart';
import 'package:healthpin/theme/app_theme.dart';
import 'package:healthpin/ui/home/widgets/resource_badges.dart';
import 'package:healthpin/ui/home/widgets/resource_ui_elements.dart';
import 'package:healthpin/utils/resource_utils.dart';

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
    final hasPhoto = resource.photoUrl != null && resource.photoUrl!.isNotEmpty;
    final openStatus = ResourceUtils.isCurrentlyOpen(resource.openingHours);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: color.withAlpha(20),
          highlightColor: color.withAlpha(10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border(
                left: BorderSide(color: color.withValues(alpha: 0.5), width: 3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasPhoto) ResourcePhotoBanner(photoUrl: resource.photoUrl!),
                _buildHeader(context, color, icon, openStatus),
                _buildDivider(),
                _buildMetaInfo(color),
                _buildFooter(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    Color color,
    IconData icon,
    bool? openStatus,
  ) {
    final hasPhoto = resource.photoUrl != null && resource.photoUrl!.isNotEmpty;
    return Padding(
      padding: EdgeInsets.fromLTRB(14, hasPhoto ? 12 : 14, 14, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withAlpha(20), width: 1),
            ),
            child: Center(child: Icon(icon, color: color, size: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resource.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textCharcoal,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 7),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    TypeBadge(
                      label: ResourceUtils.formatTypeName(resource.type.name),
                      color: color,
                    ),
                    if (resource.isVerified) const VerifiedBadge(),
                    if (openStatus != null) OpenStatusBadge(isOpen: openStatus),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      child: Divider(
        height: 1,
        thickness: 1,
        color: AppTheme.textCharcoal.withAlpha(10),
      ),
    );
  }

  Widget _buildMetaInfo(Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      child: Column(
        children: [
          ResourceIconTextRow(
            icon: Icons.location_on_rounded,
            text: resource.address,
            iconColor: color,
          ),
          if (resource.openingHours?.isNotEmpty ?? false) ...[
            const SizedBox(height: 5),
            ResourceIconTextRow(
              icon: Icons.access_time_filled_rounded,
              text: resource.openingHours!,
            ),
          ],
          if (resource.contactNumber?.isNotEmpty ?? false) ...[
            const SizedBox(height: 5),
            ResourceIconTextRow(
              icon: Icons.phone_rounded,
              text: resource.contactNumber!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Row(
        children: [
          UpvoteChip(count: resource.upvoteCount),
          const SizedBox(width: 8),
          DistancePill(
            icon: Icons.near_me_rounded,
            label: distance,
            color: AppTheme.primaryDeepForest,
            semanticLabel: 'Distance: $distance',
          ),
          const Spacer(),
          const ResourceViewButton(color: AppTheme.primaryDeepForest),
        ],
      ),
    );
  }
}
