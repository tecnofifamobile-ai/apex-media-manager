import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../vpn/vpn_provider.dart';
import '../../core/utils/wallpaper_provider.dart';

class VpnSettingsScreen extends ConsumerWidget {
  const VpnSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vpnEnabled = ref.watch(vpnEnabledProvider);
    final vpnError = ref.watch(vpnErrorProvider);
    final isLoading = ref.watch(vpnLoadingProvider);
    final wallpaper = ref.watch(wallpaperProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0F16),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Zen Shield (VPN)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 700),
              child: Image.asset(
                wallpaper,
                key: ValueKey(wallpaper),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0D0F16).withOpacity(0.9),
                    const Color(0xFF0D0F16).withOpacity(0.4),
                    const Color(0xFF0D0F16).withOpacity(0.9),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: vpnEnabled ? const Color(0xFF6B4EE6) : Colors.white.withOpacity(0.1)),
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          children: [
                            Icon(Icons.shield, color: vpnEnabled ? const Color(0xFF6B4EE6) : Colors.white54, size: 48),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Cloudflare WARP', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text(
                                    vpnEnabled ? 'Your connection is encrypted and ISP blocks are bypassed.' : 'Enable to bypass ISP blocks and secure your connection.',
                                    style: TextStyle(color: vpnEnabled ? const Color(0xFF6B4EE6) : Colors.white54, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            if (isLoading)
                              const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(color: Color(0xFF6B4EE6), strokeWidth: 2),
                              )
                            else
                              Switch(
                                value: vpnEnabled,
                                activeColor: const Color(0xFF6B4EE6),
                                onChanged: (val) {
                                  ref.read(vpnEnabledProvider.notifier).toggle();
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  if (vpnError != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withAlpha(100)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.redAccent),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              vpnError,
                              style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  const Text('About Zen Shield', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Text(
                    'Zen Shield uses Cloudflare WARP (1.1.1.1) to encrypt your DNS queries and route your traffic through a secure tunnel. This helps bypass common ISP blocks on IPTV domains.',
                    style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
