import 'features/channels/cache_clearer.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:window_manager/window_manager.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'dart:io';
import 'dart:ui';

import 'package:flutter/services.dart';

import 'core/utils/device_capabilities.dart';
import 'features/auth/local_mode_provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/models/isar_profile.dart';
import 'core/models/favorite_channel.dart';

Isar? isar;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([clearImageCache(), DeviceCapabilities.initialize()]);
  LocalModeNotifier.initiallyEnabled =
      (await SharedPreferences.getInstance()).getBool('local_mode') ?? false;

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(1280, 720),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  // Inicialización crítica del motor de video
  MediaKit.ensureInitialized();

  // Inicializar Supabase
  await Supabase.initialize(
    url: const String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: 'https://daozombwhujwomhuaryq.supabase.co',
    ),
    publishableKey: const String.fromEnvironment(
      'SUPABASE_PUBLISHABLE_KEY',
      defaultValue: 'sb_publishable_j5wg1avRmJ4tlbP_yl0u5w_k6MIzED1',
    ),
  );

  // Inicializar Isar
  final appDir = await getApplicationSupportDirectory();
  try {
    isar = await Isar.open([
      IsarProfileSchema,
      FavoriteChannelSchema,
    ], directory: appDir.path);
  } catch (_) {
    // Some TV runtimes lack native MDBX system calls. Preserve their Isar files.
    debugPrint('Native database unavailable; using compatible local storage.');
  }

  runApp(const ProviderScope(child: ESPTVPlayerApp()));
}

class ESPTVPlayerApp extends ConsumerWidget {
  const ESPTVPlayerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'APEX Media Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      shortcuts: {
        ...WidgetsApp.defaultShortcuts,
        const SingleActivator(LogicalKeyboardKey.select):
            const ActivateIntent(),
        const SingleActivator(LogicalKeyboardKey.gameButtonA):
            const ActivateIntent(),
      },
      builder: (context, child) => FocusTraversalGroup(
        policy: ReadingOrderTraversalPolicy(),
        child: SafeArea(child: child ?? const SizedBox.shrink()),
      ),
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.trackpad,
        },
      ),
      routerConfig: router,
    );
  }
}
