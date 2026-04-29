import 'package:flutter/material.dart';
import 'package:healthpin/components/primary_button.dart';
import 'package:healthpin/models/resource_model.dart';
import 'package:healthpin/models/user_model.dart';
import 'package:healthpin/services/auth_service.dart';
import 'package:healthpin/services/resource_service.dart';
import 'package:healthpin/services/user_database_service.dart';
import 'package:healthpin/theme/app_theme.dart';
import 'package:healthpin/ui/home/widgets/resource_list_item.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final ResourceService _resourceService = ResourceService();
  final UserDatabase _userService = UserDatabase();

  String? userId;
  UserModel? userModel;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _loadUserData();
  }

  Future<void> _loadUserData() async {
    userId = _authService.getUserId();
    userModel = await _userService.getUserById(userId!);
    if (mounted) {
      setState(() {});
      _animController.forward();
    }
  }

  Future<void> _handleRefresh() async {
    _animController.reset();
    await _loadUserData();
  }

  void _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.backgroundWarmOffWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Log out?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text('You will be returned to the login screen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.primaryDeepForest),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Log Out',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) await _authService.logOut();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWarmOffWhite,
      body: RefreshIndicator(
        color: AppTheme.primaryDeepForest,
        onRefresh: _handleRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── Collapsible Header ──────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 260,
              pinned: true,
              backgroundColor: AppTheme.primaryDeepForest,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: Colors.white70),
                  tooltip: 'Log Out',
                  onPressed: _handleLogout,
                ),
                const SizedBox(width: 8),
              ],
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: _ProfileHeaderBg(userModel: userModel),
              ),
            ),

            // ── Stats Strip ────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: _StatsStrip(
                    userId: userId,
                    resourceService: _resourceService,
                  ),
                ),
              ),
            ),

            // ── Section Header ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 12),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryDeepForest,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Recent Submissions',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: AppTheme.textCharcoal,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Submissions List ───────────────────────────────────────────
            if (userId == null)
              const SliverFillRemaining(
                child: Center(
                  child: Text('Please log in to view submissions.'),
                ),
              )
            else
              _SubmissionsSliver(
                userId: userId!,
                resourceService: _resourceService,
                fadeAnim: _fadeAnim,
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Profile Header Background
// ─────────────────────────────────────────────────────────────────────────────
class _ProfileHeaderBg extends StatelessWidget {
  final UserModel? userModel;
  const _ProfileHeaderBg({required this.userModel});

  String _initials() {
    final name = userModel?.fullName ?? '';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Deep forest gradient base
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryDeepForest,
                Color.lerp(AppTheme.primaryDeepForest, Colors.black, 0.35)!,
              ],
            ),
          ),
        ),
        // Decorative circular blobs
        Positioned(
          top: -40,
          right: -40,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.05),
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          left: -30,
          child: Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.04),
            ),
          ),
        ),
        // Content
        Positioned(
          bottom: 28,
          left: 24,
          right: 24,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Avatar
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.35),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    _initials(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 18),
              // Name & email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      userModel?.fullName ?? 'Field Worker',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.alternate_email_rounded,
                          size: 13,
                          color: Colors.white54,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            userModel?.email ?? 'Data Contributor',
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats Strip
// ─────────────────────────────────────────────────────────────────────────────
class _StatsStrip extends StatelessWidget {
  final String? userId;
  final ResourceService resourceService;

  const _StatsStrip({required this.userId, required this.resourceService});

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
            color: Colors.black.withOpacity(0.06),
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
            color: valueColor ?? AppTheme.textCharcoal.withOpacity(0.4),
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
      color: Colors.grey.withOpacity(0.15),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Submissions Sliver
// ─────────────────────────────────────────────────────────────────────────────
class _SubmissionsSliver extends StatelessWidget {
  final String userId;
  final ResourceService resourceService;
  final Animation<double> fadeAnim;

  const _SubmissionsSliver({
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
            separatorBuilder: (_, __) => const SizedBox(height: 10),
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(16), child: child),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty State
// ─────────────────────────────────────────────────────────────────────────────
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
              color: (color ?? AppTheme.primaryDeepForest).withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 32,
              color: (color ?? AppTheme.primaryDeepForest).withOpacity(0.5),
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
