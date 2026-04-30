import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:healthpin/models/resource_model.dart';
import 'package:healthpin/theme/app_theme.dart';
import 'package:healthpin/utils/resource_formatter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// NAME CARD
// ─────────────────────────────────────────────────────────────────────────────

class ResourceNameCard extends StatelessWidget {
  final ResourceModel resource;
  final String typeName;
  final bool? openStatus;
  final int upvoteCount;
  final bool upvoted;

  const ResourceNameCard({
    super.key,
    required this.resource,
    required this.typeName,
    required this.openStatus,
    required this.upvoteCount,
    required this.upvoted,
  });

  @override
  Widget build(BuildContext context) {
    final color = resource.type.color;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(20),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  resource.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textCharcoal,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: upvoted
                      ? AppTheme.primaryDeepForest.withAlpha(20)
                      : AppTheme.outline.withAlpha(12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      upvoted
                          ? Icons.thumb_up_alt_rounded
                          : Icons.thumb_up_alt_outlined,
                      size: 13,
                      color: upvoted
                          ? AppTheme.primaryDeepForest
                          : AppTheme.outline.withAlpha(160),
                    ),
                    const SizedBox(width: 4),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, anim) =>
                          ScaleTransition(scale: anim, child: child),
                      child: Text(
                        '$upvoteCount',
                        key: ValueKey(upvoteCount),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: upvoted
                              ? AppTheme.primaryDeepForest
                              : AppTheme.outline.withAlpha(160),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              SmallBadge(
                label: typeName,
                color: color,
                bg: color.withAlpha(22),
                border: color.withAlpha(55),
              ),
              if (resource.isVerified)
                const SmallBadge(
                  label: 'Verified',
                  icon: Icons.verified_rounded,
                  color: Color(0xFF2E7D32),
                  bg: Color(0x122E7D32),
                  border: Color(0x402E7D32),
                ),
              if (openStatus != null)
                SmallBadge(
                  label: openStatus! ? 'Open now' : 'Closed',
                  dotColor: openStatus!
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFC62828),
                  color: openStatus!
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFC62828),
                  bg: openStatus!
                      ? const Color(0xFF2E7D32).withAlpha(18)
                      : const Color(0xFFC62828).withAlpha(18),
                  border: openStatus!
                      ? const Color(0xFF2E7D32).withAlpha(55)
                      : const Color(0xFFC62828).withAlpha(55),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DETAILS SECTION
// ─────────────────────────────────────────────────────────────────────────────

class ResourceDetailsSection extends StatelessWidget {
  final ResourceModel resource;
  final bool? openStatus;

  const ResourceDetailsSection({
    super.key,
    required this.resource,
    this.openStatus,
  });

  @override
  Widget build(BuildContext context) {
    final color = resource.type.color;

    return SectionCard(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        children: [
          if (resource.address.isNotEmpty)
            DetailRow(
              icon: Icons.location_on_rounded,
              label: 'Address',
              value: resource.address,
              color: color,
            ),
          if (resource.openingHours?.isNotEmpty ?? false) ...[
            const RowDivider(),
            DetailRow(
              icon: Icons.access_time_filled_rounded,
              label: 'Hours',
              value: resource.openingHours!,
              color: color,
              trailingWidget: openStatus == null
                  ? null
                  : InlineStatusDot(isOpen: openStatus!),
            ),
          ],
          if (resource.contactNumber?.isNotEmpty ?? false) ...[
            const RowDivider(),
            DetailRow(
              icon: Icons.phone_rounded,
              label: 'Contact',
              value: resource.contactNumber!,
              color: color,
              onTap: () {
                Clipboard.setData(
                  ClipboardData(text: resource.contactNumber!),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Number copied to clipboard'),
                    duration: const Duration(seconds: 2),
                    backgroundColor: color,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            ),
          ],
          const RowDivider(),
          DetailRow(
            icon: Icons.my_location_rounded,
            label: 'Coordinates',
            value:
                '${resource.latitude.toStringAsFixed(5)}, ${resource.longitude.toStringAsFixed(5)}',
            color: color,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DESCRIPTION SECTION
// ─────────────────────────────────────────────────────────────────────────────

class ResourceDescriptionSection extends StatelessWidget {
  final ResourceModel resource;

  const ResourceDescriptionSection({super.key, required this.resource});

  @override
  Widget build(BuildContext context) {
    if (resource.description.isEmpty) return const SizedBox.shrink();
    final color = resource.type.color;

    return SectionCard(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(
            icon: Icons.notes_rounded,
            label: 'ABOUT',
            color: color,
          ),
          const SizedBox(height: 10),
          Text(
            resource.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textCharcoal.withAlpha(200),
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// META SECTION
// ─────────────────────────────────────────────────────────────────────────────

class ResourceMetaSection extends StatelessWidget {
  final ResourceModel resource;

  const ResourceMetaSection({super.key, required this.resource});

  @override
  Widget build(BuildContext context) {
    final color = resource.type.color;

    return SectionCard(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(
            icon: Icons.info_outline_rounded,
            label: 'INFO',
            color: color,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              MetaChip(
                label: 'Added ${ResourceFormatter.formatDate(resource.createdAt)}',
                icon: Icons.calendar_today_rounded,
              ),
              MetaChip(
                label: resource.isVerified ? 'Verified' : 'Unverified',
                icon: resource.isVerified
                    ? Icons.verified_rounded
                    : Icons.help_outline_rounded,
                color: resource.isVerified
                    ? const Color(0xFF2E7D32)
                    : AppTheme.outline,
              ),
            ],
          ),
          if (resource.submittedBy.isNotEmpty) ...[
            const SizedBox(height: 10),
            const RowDivider(),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppTheme.outline.withAlpha(18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    size: 15,
                    color: AppTheme.outline,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Submitted by ',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.outline,
                  ),
                ),
                Expanded(
                  child: Text(
                    resource.submittedBy,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textCharcoal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────

class SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets margin;
  const SectionCard({super.key, required this.child, required this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const SectionLabel({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}

class DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;
  final Widget? trailingWidget;

  const DetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
    this.trailingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withAlpha(18),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 15, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.outline,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          value,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppTheme.textCharcoal,
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                              ),
                        ),
                      ),
                      if (trailingWidget != null) ...[
                        const SizedBox(width: 8),
                        trailingWidget!,
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Icon(
                  Icons.copy_rounded,
                  size: 14,
                  color: color.withAlpha(120),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class InlineStatusDot extends StatelessWidget {
  final bool isOpen;
  const InlineStatusDot({super.key, required this.isOpen});

  @override
  Widget build(BuildContext context) {
    final color = isOpen ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(50), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            isOpen ? 'Open' : 'Closed',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class RowDivider extends StatelessWidget {
  const RowDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 42,
      color: AppTheme.textCharcoal.withAlpha(10),
    );
  }
}

class MetaChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? color;
  const MetaChip({super.key, required this.label, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.outline;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.withAlpha(15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withAlpha(40), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: c),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: c,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class SmallBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? dotColor;
  final Color color;
  final Color bg;
  final Color border;

  const SmallBadge({
    super.key,
    required this.label,
    this.icon,
    this.dotColor,
    required this.color,
    required this.bg,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 3),
          ] else if (dotColor != null) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
