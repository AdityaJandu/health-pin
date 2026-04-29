import 'package:flutter/material.dart';
import 'package:healthpin/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// VERIFIED BADGE
// ─────────────────────────────────────────────────────────────────────────────

class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Verified',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.withAlpha(20),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green.withAlpha(70), width: 0.5),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified_rounded, size: 11, color: Colors.green),
            SizedBox(width: 3),
            Text(
              'Verified',
              style: TextStyle(
                fontSize: 10,
                color: Colors.green,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DISTANCE PILL
// ─────────────────────────────────────────────────────────────────────────────

class DistancePill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String semanticLabel;

  const DistancePill({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withAlpha(18),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TYPE BADGE
// ─────────────────────────────────────────────────────────────────────────────

class TypeBadge extends StatelessWidget {
  final String label;
  final Color color;

  const TypeBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(22),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(55), width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OPEN STATUS BADGE
// ─────────────────────────────────────────────────────────────────────────────

class OpenStatusBadge extends StatelessWidget {
  final bool isOpen;
  const OpenStatusBadge({super.key, required this.isOpen});

  @override
  Widget build(BuildContext context) {
    final color = isOpen ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
    final bg = isOpen
        ? const Color(0xFF2E7D32).withAlpha(18)
        : const Color(0xFFC62828).withAlpha(18);
    final label = isOpen ? 'Open now' : 'Closed';
    final dot = isOpen ? Icons.circle : Icons.circle_outlined;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(55), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(dot, size: 7, color: color),
          const SizedBox(width: 4),
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

// ─────────────────────────────────────────────────────────────────────────────
// UPVOTE CHIP
// ─────────────────────────────────────────────────────────────────────────────

class UpvoteChip extends StatelessWidget {
  final int count;
  const UpvoteChip({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.outline.withAlpha(12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.thumb_up_alt_rounded,
            size: 12,
            color: AppTheme.outline.withAlpha(150),
          ),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.outline.withAlpha(150),
            ),
          ),
        ],
      ),
    );
  }
}
