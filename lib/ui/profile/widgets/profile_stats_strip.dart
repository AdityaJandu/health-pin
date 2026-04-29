import 'package:flutter/material.dart';
import 'package:healthpin/models/resource_model.dart';
import 'package:healthpin/services/resource_service.dart';
import 'package:healthpin/theme/app_theme.dart';

class ProfileStatsStrip extends StatelessWidget {
  final String? userId;
  final ResourceService resourceService;

  const ProfileStatsStrip({
    super.key,
    required this.userId,
    required this.resourceService,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: userId == null
          ? const SizedBox()
          : FutureBuilder<List<ResourceModel>>(
              future: resourceService.getResourcesByUser(userId!),
              builder: (context, snapshot) {
                final count = snapshot.data?.length ?? 0;
                final verified =
                    snapshot.data?.where((r) => r.isVerified == true).length ??
                    0;

                return Row(
                  children: [
                    _StatCell(
                      icon: Icons.upload_rounded,
                      label: 'Submissions',
                      value: snapshot.connectionState == ConnectionState.waiting
                          ? '—'
                          : '$count',
                    ),
                    _VerticalDivider(),
                    _StatCell(
                      icon: Icons.verified_rounded,
                      label: 'Verified',
                      value: snapshot.connectionState == ConnectionState.waiting
                          ? '—'
                          : '$verified',
                      valueColor: AppTheme.primaryDeepForest,
                    ),
                    _VerticalDivider(),
                    _StatCell(
                      icon: Icons.place_rounded,
                      label: 'Role',
                      value: 'Field Worker',
                      isText: true,
                    ),
                  ],
                );
              },
            ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool isText;

  const _StatCell({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.isText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: valueColor ?? AppTheme.textCharcoal.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: isText ? 11 : 20,
              fontWeight: FontWeight.w800,
              color: valueColor ?? AppTheme.textCharcoal,
              letterSpacing: isText ? 0 : -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.outline,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: Colors.grey.withValues(alpha: 0.15),
    );
  }
}
