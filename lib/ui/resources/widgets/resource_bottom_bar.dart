import 'package:flutter/material.dart';
import 'package:healthpin/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourceBottomBar extends StatelessWidget {
  final Color color;
  final bool upvoted;
  final int upvoteCount;
  final VoidCallback onUpvote;
  final double long;
  final double lat;

  const ResourceBottomBar({
    super.key,
    required this.color,
    required this.upvoted,
    required this.upvoteCount,
    required this.onUpvote,
    required this.long,
    required this.lat,
  });

  Future<void> _openMaps(BuildContext context) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$long&travelmode=driving',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open maps')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + safeBottom),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Upvote button
          GestureDetector(
            onTap: onUpvote,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: upvoted
                    ? AppTheme.primaryDeepForest
                    : AppTheme.primaryDeepForest.withAlpha(15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppTheme.primaryDeepForest.withAlpha(upvoted ? 0 : 50),
                  width: 0.5,
                ),
                boxShadow: upvoted
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryDeepForest.withAlpha(60),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    upvoted
                        ? Icons.thumb_up_alt_rounded
                        : Icons.thumb_up_alt_outlined,
                    size: 18,
                    color: upvoted ? Colors.white : AppTheme.primaryDeepForest,
                  ),
                  const SizedBox(width: 7),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: Text(
                      '$upvoteCount',
                      key: ValueKey(upvoteCount),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: upvoted
                            ? Colors.white
                            : AppTheme.primaryDeepForest,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Directions button
          Expanded(
            child: SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => _openMaps(context),
                icon: const Icon(Icons.directions_rounded, size: 18),
                label: const Text(
                  'Get Directions',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: 0.3,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryDeepForest,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
