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

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/models/isar_profile.dart';
import 'core/models/favorite_channel.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

late Isar isar;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  clearImageCache();

  
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
  
  HttpOverrides.global = MyHttpOverrides();
  
  // Inicialización crítica del motor de video
  MediaKit.ensureInitialized();

  // Inicializar Supabase
  await Supabase.initialize(
    url: 'https://amyownwbukcoiuldhozx.supabase.co',
    anonKey: 'sb_publishable_G0A4-he7nul_Lg6AJ-kbIw_Iyv8V6v4',
  );

  // Inicializar Isar
  final appDir = await getApplicationSupportDirectory();
  isar = await Isar.open(
    [IsarProfileSchema, FavoriteChannelSchema],
    directory: appDir.path,
  );

  runApp(
    const ProviderScope(
      child: ESPTVPlayerApp(),
    ),
  );
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
