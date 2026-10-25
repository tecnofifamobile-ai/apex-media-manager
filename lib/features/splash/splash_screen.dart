import '../../core/widgets/ios_spinner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/iptv_parser/providers/logo_provider.dart';
import '../../features/iptv_parser/providers/category_provider.dart';
import '../../features/vpn/vpn_provider.dart';
import '../auth/local_mode_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkInitialization() {
    if (_initialized) return;

    final logoDbAsync = ref.read(logoDatabaseProvider);
    final categoryDbAsync = ref.read(categoryDatabaseProvider);

    if (logoDbAsync.hasValue && categoryDbAsync.hasValue) {
      _initialized = true;
      // Trigger VPN auto-start if enabled in settings
      ref.read(vpnEnabledProvider);

      Future.delayed(Duration.zero, () {
        if (!mounted) return;
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null || ref.read(localModeProvider)) {
          context.go('/profile');
        } else {
          context.go('/auth');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(logoDatabaseProvider, (prev, next) {
      if (next.hasValue) _checkInitialization();
    });
    ref.listen(categoryDatabaseProvider, (prev, next) {
      if (next.hasValue) _checkInitialization();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialization();
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0F111A), // Dark Apple TV background
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  'assets/icon.jpg',
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'APEX',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Iniciando sistema...',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 14,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 48),
              const SizedBox(
                width: 30,
                height: 30,
                child: IosSpinner(
                  color: Colors.white24,
                  strokeWidth: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
