import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'features/addiction/presentation/pages/addiction_list_page.dart';
import 'features/habits/presentation/pages/habit_list_page.dart';

/// Root shell that hosts the bottom navigation bar.
///
/// Uses [IndexedStack] so each tab keeps its state when switching.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  static const _pages = [
    AddictionListPage(),
    HabitListPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

// ─── Bottom nav ───────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewPadding.bottom;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.darkCard.withAlpha(200),
            border: Border(
              top: BorderSide(color: Colors.white.withAlpha(15)),
            ),
          ),
          padding: EdgeInsets.only(bottom: bottom),
          child: Row(
            children: [
              _NavItem(
                icon: Icons.self_improvement_rounded,
                label: 'Addictions',
                selected: currentIndex == 0,
                gradient: AppTheme.primaryGradient,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.checklist_rounded,
                label: 'Habits',
                selected: currentIndex == 1,
                gradient: AppTheme.greenGradient,
                onTap: () => onTap(1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 32,
                decoration: BoxDecoration(
                  gradient: selected ? gradient : null,
                  color: selected ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: selected
                      ? Colors.white
                      : Colors.white.withAlpha(80),
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected
                      ? Colors.white
                      : Colors.white.withAlpha(80),
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
