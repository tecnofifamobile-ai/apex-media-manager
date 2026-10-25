import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:window_manager/window_manager.dart';

import '../utils/device_capabilities.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({super.key, required this.child});
  final Widget child;
  static const _routes = [
    '/channels',
    '/favorites',
    '/movies',
    '/series',
    '/profile',
    '/account',
    '/settings',
  ];
  static const _labels = [
    'TV en directo',
    'Favoritos',
    'Películas',
    'Series',
    'Perfiles',
    'Cuenta',
    'Ajustes',
  ];
  static const _icons = [
    Icons.tv,
    Icons.star_border,
    Icons.movie_outlined,
    Icons.video_library_outlined,
    Icons.people_outline,
    Icons.person_outline,
    Icons.settings_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final index = _routes.indexWhere((route) => location.startsWith(route));
    final selected = index < 0 ? 6 : index;
    final desktop = Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    final wide =
        DeviceCapabilities.isTv || MediaQuery.sizeOf(context).width >= 700;
    return Scaffold(
      body: Column(
        children: [
          if (desktop)
            const SizedBox(
              height: 32,
              child: WindowCaption(
                brightness: Brightness.dark,
                backgroundColor: Colors.transparent,
              ),
            ),
          Expanded(
            child: Row(
              children: [
                if (wide)
                  NavigationRail(
                    extended: DeviceCapabilities.isTv,
                    minExtendedWidth: 170,
                    groupAlignment: -0.8,
                    selectedIndex: selected,
                    onDestinationSelected: (i) => context.go(_routes[i]),
                    destinations: List.generate(
                      _routes.length,
                      (i) => NavigationRailDestination(
                        icon: Icon(_icons[i]),
                        label: Text(_labels[i]),
                      ),
                    ),
                  ),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: selected > 3 ? 4 : selected,
              onDestinationSelected: (i) =>
                  context.go(i == 4 ? '/settings' : _routes[i]),
              destinations: [
                for (var i = 0; i < 4; i++)
                  NavigationDestination(
                    icon: Icon(_icons[i]),
                    label: _labels[i],
                  ),
                const NavigationDestination(
                  icon: Icon(Icons.settings),
                  label: 'Ajustes',
                ),
              ],
            ),
    );
  }
}
