import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:babyblue/core/theme/app_theme.dart';

/// Bottom-navigation shell that wraps the three main tabs.
///
/// Uses [StatefulNavigationShell] from GoRouter to preserve
/// each branch's navigation state independently.
class MainShell extends StatelessWidget {
  /// The GoRouter navigation shell controlling tab state.
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardWhite,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryLavender.withAlpha(15),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: BottomNavigationBar(
              currentIndex: navigationShell.currentIndex,
              onTap: (index) => navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              ),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.emoji_emotions_outlined),
                  activeIcon: Icon(Icons.emoji_emotions_rounded),
                  label: 'Mood',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu_book_outlined),
                  activeIcon: Icon(Icons.menu_book_rounded),
                  label: 'Lessons',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.edit_note_outlined),
                  activeIcon: Icon(Icons.edit_note_rounded),
                  label: 'Journal',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
