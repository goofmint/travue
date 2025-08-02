import 'package:flutter/material.dart';

class TravueBottomNavigationItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final String route;

  const TravueBottomNavigationItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    required this.route,
  });
}

class TravueBottomNavigationBar extends StatelessWidget {
  final List<TravueBottomNavigationItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;

  const TravueBottomNavigationBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: items.map((item) {
        final isSelected = items.indexOf(item) == currentIndex;
        return BottomNavigationBarItem(
          icon: Icon(isSelected && item.activeIcon != null ? item.activeIcon : item.icon),
          label: item.label,
        );
      }).toList(),
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: backgroundColor,
      selectedItemColor: selectedItemColor ?? Theme.of(context).colorScheme.primary,
      unselectedItemColor: unselectedItemColor ?? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
      elevation: 8,
    );
  }
}