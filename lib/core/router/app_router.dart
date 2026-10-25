import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/main_layout.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/channels/channels_screen.dart';
import '../../features/profile/account_screen.dart';
import '../../features/movies/movies_screen.dart';
import '../../features/series/series_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/settings/vpn_settings_screen.dart';
import '../../features/settings/wallpaper_settings_screen.dart';
import '../../features/player/player_screen.dart';
import '../../features/favorites/favorites_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../core/models/iptv_models.dart';

// Transicion suave (Fade) para pantallas principales
CustomTransitionPage buildPageWithDefaultTransition<T>({
  required BuildContext context, 
  required GoRouterState state, 
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) => 
        FadeTransition(opacity: animation, child: child),
    transitionDuration: const Duration(milliseconds: 300),
  );
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isAuthRoute = state.uri.toString() == '/auth';
      final isSplashRoute = state.uri.toString() == '/';
      
      if (session == null && !isAuthRoute && !isSplashRoute) return '/auth';
      // Do not redirect to profile if we are in splash! Splash will handle it.
      if (session != null && isAuthRoute) return '/profile';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) => buildPageWithDefaultTransition(context: context, state: state, child: const ProfileScreen()),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
        routes: [
          GoRoute(
            path: '/favorites',
            pageBuilder: (context, state) => buildPageWithDefaultTransition(context: context, state: state, child: const FavoritesScreen()),
          ),
          GoRoute(
            path: '/channels',
            pageBuilder: (context, state) => buildPageWithDefaultTransition(context: context, state: state, child: const ChannelsScreen()),
          ),
          GoRoute(
            path: '/account',
            pageBuilder: (context, state) => buildPageWithDefaultTransition(context: context, state: state, child: const AccountScreen()),
          ),
          GoRoute(
            path: '/movies',
            pageBuilder: (context, state) => buildPageWithDefaultTransition(context: context, state: state, child: const MoviesScreen()),
          ),
          GoRoute(
            path: '/series',
            pageBuilder: (context, state) => buildPageWithDefaultTransition(context: context, state: state, child: const SeriesScreen()),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => buildPageWithDefaultTransition(context: context, state: state, child: const SettingsScreen()),
          ),
          GoRoute(
            path: '/vpn_settings',
            pageBuilder: (context, state) => buildPageWithDefaultTransition(context: context, state: state, child: const VpnSettingsScreen()),
          ),
          GoRoute(
            path: '/wallpaper_settings',
            pageBuilder: (context, state) => buildPageWithDefaultTransition(context: context, state: state, child: const WallpaperSettingsScreen()),
          ),
        ],
      ),
      GoRoute(
        path: '/player',
        name: 'player',
        builder: (context, state) {
          final channel = state.extra as Channel?;
          return PlayerScreen(channel: channel);
        },
      ),
    ],
  );
});

