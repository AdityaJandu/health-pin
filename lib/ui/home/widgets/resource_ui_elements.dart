import 'package:flutter/material.dart';
import 'package:healthpin/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PHOTO BANNER
// ─────────────────────────────────────────────────────────────────────────────

class ResourcePhotoBanner extends StatelessWidget {
  final String photoUrl;
  const ResourcePhotoBanner({super.key, required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(topRight: Radius.circular(20)),
          child: Image.network(
            photoUrl,
            height: 130,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
          ),
        ),
        Positioned.fill(
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(20),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withAlpha(100)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ICON TEXT ROW
// ─────────────────────────────────────────────────────────────────────────────

class ResourceIconTextRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? iconColor;

  const ResourceIconTextRow({
    super.key,
    required this.icon,
    required this.text,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1.5),
          child: Icon(
            icon,
            size: 13,
            color: iconColor ?? AppTheme.outline.withAlpha(180),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.outline,
                  fontSize: 12,
                  height: 1.4,
                ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VIEW BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class ResourceViewButton extends StatelessWidget {
  final Color color;
  const ResourceViewButton({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(11),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(60),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'View',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          SizedBox(width: 5),
          Icon(Icons.arrow_forward_ios_rounded, size: 11, color: Colors.white),
        ],
      ),
    );
  }
}
