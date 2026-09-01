import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/l10n/app_localizations.dart';

/// App shell with the dark bottom navigation bar (Home / Shop / Tasks / Profile).
/// The active icon shows in orange via the app theme.
class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_rounded),
            label: l.navHome,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.shopping_bag_outlined),
            label: l.navShop,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.list_alt_rounded),
            label: l.navTasks,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_rounded),
            label: l.navProfile,
          ),
        ],
      ),
    );
  }
}
