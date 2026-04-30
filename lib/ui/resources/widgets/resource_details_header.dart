import 'package:flutter/material.dart';
import 'package:healthpin/theme/app_theme.dart';

class ResourceDetailsHeader extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final Color color;
  final IconData icon;
  final double expandedHeight;

  const ResourceDetailsHeader({
    super.key,
    required this.name,
    this.photoUrl,
    required this.color,
    required this.icon,
    this.expandedHeight = 300.0,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;

    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: true,
      backgroundColor: color,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _AppBarButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () => Navigator.maybePop(context),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _AppBarButton(icon: Icons.share_rounded, onTap: () {}),
        ),
      ],
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final safeArea = MediaQuery.of(context).padding.top;
          final collapsedHeight = kToolbarHeight + safeArea;
          final progress = ((expandedHeight - constraints.maxHeight) /
                  (expandedHeight - collapsedHeight))
              .clamp(0.0, 1.0);
          final titleOpacity = ((progress - 0.75) / 0.25).clamp(0.0, 1.0);

          return FlexibleSpaceBar(
            collapseMode: CollapseMode.parallax,
            centerTitle: true,
            title: Opacity(
              opacity: titleOpacity,
              child: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            background: hasPhoto
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        photoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _PlaceholderBg(color: color, icon: icon),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.black.withAlpha(170),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  )
                : _PlaceholderBg(color: color, icon: icon),
          );
        },
      ),
    );
  }
}

class _AppBarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _AppBarButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(55),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}

class _PlaceholderBg extends StatelessWidget {
  final Color color;
  final IconData icon;
  const _PlaceholderBg({required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryDeepForest, color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            right: -60,
            top: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(12),
              ),
            ),
          ),
          Positioned(
            left: -40,
            bottom: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(8),
              ),
            ),
          ),
          Center(
            child: Icon(icon, size: 72, color: Colors.white.withAlpha(50)),
          ),
        ],
      ),
    );
  }
}
