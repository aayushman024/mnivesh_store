import 'dart:ui'; // Required for ImageFilter
import 'package:flutter/material.dart';

class HomeBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final int updateCount;

  const HomeBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.updateCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    // Define a lighter purple explicitly for better contrast on dark/black
    final Color lighterPurple = const Color(0xFFD0BCFF);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.0),
            Colors.black,
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0F).withOpacity(0.98),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.06),
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 30,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(
                      label: "Installed",
                      icon: Icons.check_circle_outline,
                      activeIcon: Icons.check_circle,
                      isActive: currentIndex == 0,
                      color: lighterPurple,
                      onTap: () => onTap(0),
                    ),
                    _NavItemWithBadge(
                      label: "Updates",
                      icon: Icons.system_update_outlined,
                      activeIcon: Icons.system_update,
                      isActive: currentIndex == 1,
                      color: lighterPurple,
                      updateCount: updateCount,
                      onTap: () => onTap(1),
                    ),
                    _NavItem(
                      label: "Store",
                      icon: Icons.storefront_outlined,
                      activeIcon: Icons.storefront,
                      isActive: currentIndex == 2,
                      color: lighterPurple,
                      onTap: () => onTap(2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.isActive,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 20 : 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 24,
              color: isActive ? color : Colors.grey[500],
            ),
            if (isActive) ...[
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: 0.2,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class _NavItemWithBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool isActive;
  final Color color;
  final int updateCount;
  final VoidCallback onTap;

  const _NavItemWithBadge({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.isActive,
    required this.color,
    required this.updateCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final child = _NavItem(
      label: label,
      icon: icon,
      activeIcon: activeIcon,
      isActive: isActive,
      color: color,
      onTap: onTap,
    );

    if (updateCount <= 0) return child;

    return Badge(
      label: Text(
        '$updateCount',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: const Color(0xFFFF5252),
      textColor: Colors.white,
      offset: const Offset(8, -10),
      child: child,
    );
  }
}