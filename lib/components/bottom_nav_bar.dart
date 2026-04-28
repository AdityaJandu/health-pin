import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import '../theme/app_theme.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.item1,
    required this.item2,
    required this.item3,
    required this.item4,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final String item1, item2, item3, item4;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(
            color: AppTheme.textCharcoal.withAlpha(20),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: SalomonBottomBar(
          currentIndex: currentIndex,
          onTap: onDestinationSelected,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          items: [
            /// Map / Home
            SalomonBottomBarItem(
              icon: const Icon(CupertinoIcons.map),
              title: Text(item1),
              selectedColor: AppTheme.primary,
            ),

            /// Resources
            SalomonBottomBarItem(
              icon: const Icon(CupertinoIcons.list_bullet),
              title: Text(item2),
              selectedColor: AppTheme.secondary,
            ),

            /// Impact / Community
            SalomonBottomBarItem(
              icon: const Icon(CupertinoIcons.heart),
              title: Text(item3),
              selectedColor: AppTheme.accentClayOrange,
            ),

            /// Profile
            SalomonBottomBarItem(
              icon: const Icon(CupertinoIcons.person),
              title: Text(item4),
              selectedColor: AppTheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

