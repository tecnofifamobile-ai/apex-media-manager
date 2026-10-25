import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:window_manager/window_manager.dart';

import 'glass.dart';
import 'liquid_switcher.dart';
import 'shell_insets.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({super.key, required this.child});
  final Widget child;
  static const segments = [
    LiquidSegment(
      '/favorites',
      'Favoritos',
      Icons.home_rounded,
      showIcon: true,
    ),
    LiquidSegment('/channels', 'Directo', Icons.tv_rounded),
    LiquidSegment('/movies', 'Películas', Icons.movie_outlined),
    LiquidSegment('/series', 'Series', Icons.video_library_outlined),
    LiquidSegment(
      '/account',
      'Cuenta y perfiles',
      Icons.person_outline_rounded,
      showIcon: true,
    ),
    LiquidSegment(
      '/settings',
      'Ajustes',
      Icons.settings_outlined,
      showIcon: true,
    ),
  ];
  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 680;
    final desktop = Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    final caption = desktop ? 28.0 : 0.0;
    final location = GoRouterState.of(context).uri.path;
    final selected = segments.any((s) => s.value == location)
        ? location
        : '/settings';
    final insets = EdgeInsets.only(
      top: caption + MediaQuery.paddingOf(context).top + (compact ? 4 : 66),
      bottom: compact ? 72 + MediaQuery.paddingOf(context).bottom : 0,
    );
    final navigation = SizedBox(
      width: compact ? 312 : 430,
      child: LiquidSwitcher(
        segments: segments,
        value: selected,
        iconsOnly: compact,
        onChanged: (route) => context.go(route),
      ),
    );
    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Positioned.fill(
              child: FloatingShellInsets(insets: insets, child: child),
            ),
            if (desktop)
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 28,
                child: WindowCaption(
                  brightness: Brightness.dark,
                  backgroundColor: Colors.transparent,
                ),
              ),
            if (!compact)
              Positioned(
                top: caption + MediaQuery.paddingOf(context).top + 10,
                left: 16,
                right: 16,
                child: Center(child: navigation),
              ),
            if (compact)
              Positioned(
                bottom: 10,
                left: 14,
                right: 14,
                child: SafeArea(top: false, child: Center(child: navigation)),
              ),
          ],
        ),
      ),
    );
  }
}
