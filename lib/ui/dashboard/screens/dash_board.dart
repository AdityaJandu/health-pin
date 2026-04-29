import 'package:flutter/material.dart';
import 'package:healthpin/ui/dashboard/widgets/bottom_nav_bar.dart';
import 'package:healthpin/ui/home/screens/home_map_screen.dart';
import 'package:healthpin/ui/resources/screens/add_resource_screen.dart';
import 'package:healthpin/ui/resources/screens/list_resource_screen.dart';
import 'package:healthpin/ui/profile/screens/profile_screen.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {

  int currentIndex = 0;

  List<Widget> get pageViewList => [
    const HomeMapScreen(),
    const ListResourceScreen(),
    AddResourceScreen(
      onSuccess: () {
        setState(() {
          currentIndex = 0;
        });
      },
    ),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: pageViewList),
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentIndex,
        onDestinationSelected: (int value) {
          setState(() {
            currentIndex = value;
          });
        },
        item1: 'Map',
        item2: 'Resources',
        item3: 'Add',
        item4: 'Profile',
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title.toUpperCase()), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              title == 'Resources'
                  ? Icons.list_alt_rounded
                  : title == 'Impact'
                  ? Icons.favorite_rounded
                  : Icons.person_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withAlpha(50),
            ),
            const SizedBox(height: 16),
            Text(
              '$title Screen',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Detailed view coming soon...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
