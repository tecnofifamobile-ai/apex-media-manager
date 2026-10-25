import 'dart:ui';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:window_manager/window_manager.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width >= 600;

    if (isWideScreen) {
      return Scaffold(
        backgroundColor: const Color(0xFF0D0F16),
        body: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.only(left: 80.0), // Space for collapsed sidebar
                child: child,
              ),
            ),
            const Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: _ZenSidebar(),
            ),
            if (Platform.isWindows || Platform.isLinux || Platform.isMacOS)
              const Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: 32,
                child: WindowCaption(
                  brightness: Brightness.dark,
                  backgroundColor: Colors.transparent,
                ),
              ),
          ],
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: const Color(0xFF0D0F16),
        body: child,
        bottomNavigationBar: const _MobileBottomNav(),
      );
    }
  }
}

class _MobileBottomNav extends StatelessWidget {
  const _MobileBottomNav();

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final items = [
      {'icon': Icons.tv, 'label': 'Live TV', 'route': '/channels'},
      {'icon': Icons.movie, 'label': 'Movies', 'route': '/movies'},
      {'icon': Icons.live_tv, 'label': 'Series', 'route': '/series'},
      {'icon': Icons.settings, 'label': 'Settings', 'route': '/settings'},
    ];

    return Container(
      padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: items.map((item) {
          final isSelected = location.startsWith(item['route'] as String);
          return GestureDetector(
            onTap: () => context.go(item['route'] as String),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(horizontal: isSelected ? 20 : 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.2) : Colors.black26,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(item['icon'] as IconData, color: isSelected ? Colors.white : Colors.white54, size: 24),
                  if (isSelected) ...[
                    const SizedBox(width: 8),
                    Text(
                      item['label'] as String,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ZenSidebar extends StatefulWidget {
  const _ZenSidebar();

  @override
  State<_ZenSidebar> createState() => _ZenSidebarState();
}

class _ZenSidebarState extends State<_ZenSidebar> {
  bool isSidebarHovered = false;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    return MouseRegion(
      onEnter: (_) => setState(() => isSidebarHovered = true),
      onExit: (_) => setState(() => isSidebarHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutExpo,
        width: isSidebarHovered ? 240 : 80,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(isSidebarHovered ? 0.6 : 0.2),
          border: Border(
            right: BorderSide(
              color: Colors.white.withOpacity(0.05),
              width: 1,
            ),
          ),
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30.0, sigmaY: 30.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: SizedBox(
                width: isSidebarHovered ? 240 : 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 48), // Padding para el WindowCaption
                    _SidebarItem(
                      icon: Icons.search,
                      label: 'Search',
                      isSelected: false,
                      isExpanded: isSidebarHovered,
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    _SidebarItem(
                      icon: Icons.tv,
                      label: 'Live TV',
                      isSelected: location.startsWith('/channels') || location == '/',
                      isExpanded: isSidebarHovered,
                      onTap: () => context.go('/channels'),
                    ),
                    const SizedBox(height: 12),
                    _SidebarItem(
                      icon: Icons.star_border,
                      label: 'Favorites',
                      isSelected: location.startsWith('/favorites'),
                      isExpanded: isSidebarHovered,
                      onTap: () => context.go('/favorites'),
                    ),
                    const SizedBox(height: 12),
                    _SidebarItem(
                      icon: Icons.movie_outlined,
                      label: 'Movies',
                      isSelected: location.startsWith('/movies'),
                      isExpanded: isSidebarHovered,
                      onTap: () => context.go('/movies'),
                    ),
                    const SizedBox(height: 12),
                    _SidebarItem(
                      icon: Icons.chair_outlined,
                      label: 'Series',
                      isSelected: location.startsWith('/series'),
                      isExpanded: isSidebarHovered,
                      onTap: () => context.go('/series'),
                    ),
                    const Spacer(),
                    _SidebarItem(
                      icon: Icons.person_outline,
                      label: 'Profile',
                      isSelected: location.startsWith('/profile'),
                      isExpanded: isSidebarHovered,
                      onTap: () => context.go('/profile'),
                    ),
                    const SizedBox(height: 12),
                    _SidebarItem(
                      icon: Icons.settings_outlined,
                      label: 'Settings',
                      isSelected: location.startsWith('/settings'),
                      isExpanded: isSidebarHovered,
                      onTap: () => context.go('/settings'),
                    ),
                    const SizedBox(height: 24),
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

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isExpanded;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white60,
              size: 24,
            ),
            if (isExpanded) ...[
              const SizedBox(width: 16),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white60,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
