import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:window_manager/window_manager.dart';

import 'glass.dart';
import 'remote_action.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({super.key, required this.child});
  final Widget child;
  static const _routes = [
    '/favorites',
    '/channels',
    '/movies',
    '/series',
    '/profile',
    '/settings',
  ];
  static const _labels = [
    'Inicio',
    'TV en directo',
    'Películas',
    'Series',
    'Perfiles',
    'Ajustes',
  ];
  static const _icons = [
    Icons.home_rounded,
    Icons.tv_rounded,
    Icons.movie_outlined,
    Icons.video_library_outlined,
    Icons.person_outline_rounded,
    Icons.settings_outlined,
  ];

  Widget _navigation(BuildContext context, bool compact) {
    final location = GoRouterState.of(context).uri.path;
    return GlassSurface(
      blur: true,
      radius: 40,
      padding: const EdgeInsets.all(6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_routes.length, (i) {
          final selected =
              location.startsWith(_routes[i]) ||
              (i == 5 &&
                  [
                    '/account',
                    '/vpn_settings',
                    '/wallpaper_settings',
                  ].contains(location));
          final iconOnly = compact || i == 0 || i >= 4;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Tooltip(
              message: _labels[i],
              child: RemoteAction(
                label: _labels[i],
                onTap: () => context.go(_routes[i]),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 9 : iconOnly ? 13 : 19,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    color: selected
                        ? const Color(0x2FFFFFFF)
                        : Colors.transparent,
                  ),
                  child: iconOnly
                      ? Icon(
                          _icons[i],
                          size: 23,
                          color: selected ? Colors.white : Colors.white60,
                        )
                      : Text(
                          _labels[i],
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: selected ? Colors.white : Colors.white60,
                          ),
                        ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 740;
    final desktop = Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            if (desktop)
              const SizedBox(
                height: 30,
                child: WindowCaption(
                  brightness: Brightness.dark,
                  backgroundColor: Colors.transparent,
                ),
              ),
            if (!compact)
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 16, 28, 18),
                child: Row(
                  children: [
                    if (width >= 1120)
                      const SizedBox(
                        width: 160,
                        child: Row(
                          children: [
                            Icon(
                              Icons.play_circle_outline,
                              color: Colors.white70,
                              size: 25,
                            ),
                            SizedBox(width: 9),
                            Text(
                              'APEX',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Expanded(child: Center(child: _navigation(context, false))),
                    if (width >= 1120)
                      SizedBox(
                        width: 160,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            tooltip: 'Cuenta',
                            icon: const Icon(Icons.account_circle_outlined),
                            onPressed: () => context.go('/account'),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            Expanded(child: child),
            if (compact)
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: _navigation(context, true),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
