import 'package:flutter/material.dart';
import 'package:healthpin/models/user_model.dart';
import 'package:healthpin/services/auth_service.dart';
import 'package:healthpin/services/resource_service.dart';
import 'package:healthpin/services/user_database_service.dart';
import 'package:healthpin/theme/app_theme.dart';
import 'package:healthpin/ui/profile/widgets/profile_header.dart';
import 'package:healthpin/ui/profile/widgets/profile_stats_strip.dart';
import 'package:healthpin/ui/profile/widgets/profile_submissions_list.dart';

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
              flexibleSpace: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final top = constraints.maxHeight;
                  final safeArea = MediaQuery.of(context).padding.top;
                  final collapsedHeight = kToolbarHeight + safeArea;

                  // Calculate scroll-driven opacity for a buttery smooth fade
                  // Starts fading in when within 60px of the collapsed height
                  final fadeStart = collapsedHeight + 60.0;
                  final fadeEnd = collapsedHeight;
                  final double scrollOpacity =
                      1.0 -
                      ((top - fadeEnd) / (fadeStart - fadeEnd)).clamp(0.0, 1.0);

                  return FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    centerTitle: true,
                    title: Opacity(
                      opacity: scrollOpacity,
                      child: Text(
                        userModel?.fullName ?? 'Field Worker',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    background: ProfileHeader(userModel: userModel),
                  );
                },
              ),
            ),

            // ── Stats Strip ────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: ProfileStatsStrip(
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
              ProfileSubmissionsList(
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
