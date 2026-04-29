import 'package:flutter/material.dart';
import 'package:healthpin/models/resource_model.dart';
import 'package:healthpin/services/resource_service.dart';
import 'package:healthpin/theme/app_theme.dart';
import 'package:healthpin/ui/home/widgets/resource_list_item.dart';

class ProfileSubmissionsList extends StatelessWidget {
  final String userId;
  final ResourceService resourceService;
  final Animation<double> fadeAnim;

  const ProfileSubmissionsList({
    super.key,
    required this.userId,
    required this.resourceService,
    required this.fadeAnim,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ResourceModel>>(
      future: resourceService.getResourcesByUser(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: _EmptyState(
              icon: Icons.error_outline_rounded,
              message: 'Could not load submissions.',
              color: Colors.redAccent,
            ),
          );
        }

        final resources = snapshot.data ?? [];

        if (resources.isEmpty) {
          return SliverToBoxAdapter(
            child: _EmptyState(
              icon: Icons.inbox_rounded,
              message:
                  'No submissions yet.\nStart contributing to see them here.',
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverList.separated(
            itemCount: resources.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              return FadeTransition(
                opacity: fadeAnim,
                child: _SubmissionCard(
                  child: ResourceListItem(
                    resource: resources[index],
                    distance: 'N/A',
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _SubmissionCard extends StatelessWidget {
  final Widget child;
  const _SubmissionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(16), child: child),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color? color;

  const _EmptyState({required this.icon, required this.message, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 40),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: (color ?? AppTheme.primaryDeepForest).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 32,
              color: (color ?? AppTheme.primaryDeepForest).withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.outline,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
