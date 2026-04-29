import 'package:flutter/material.dart';
import 'package:healthpin/theme/app_theme.dart';

class MapIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const MapIconButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: AppTheme.textCharcoal),
      ),
    );
  }
}
