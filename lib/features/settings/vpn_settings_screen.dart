import 'package:flutter/cupertino.dart' show CupertinoSwitch;

import '../../core/widgets/ios_spinner.dart';
import '../../core/widgets/glass.dart';
import '../../core/widgets/remote_text_field.dart';
import '../../core/widgets/adaptive_backdrop.dart';

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
        title: const Text(
          'Zen Shield (VPN)',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
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
                    const Color(0xFF0D0F16).withValues(alpha: 0.9),
                    const Color(0xFF0D0F16).withValues(alpha: 0.4),
                    const Color(0xFF0D0F16).withValues(alpha: 0.9),
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
                    child: AdaptiveBackdrop(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: vpnEnabled
                                ? const Color(0xFF6B4EE6)
                                : Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          children: [
                            Icon(
                              Icons.shield,
                              color: vpnEnabled
                                  ? const Color(0xFF6B4EE6)
                                  : Colors.white54,
                              size: 48,
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Cloudflare WARP',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    vpnEnabled
                                        ? 'Your connection is encrypted and ISP blocks are bypassed.'
                                        : 'Enable to bypass ISP blocks and secure your connection.',
                                    style: TextStyle(
                                      color: vpnEnabled
                                          ? const Color(0xFF6B4EE6)
                                          : Colors.white54,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            if (isLoading)
                              const SizedBox(
                                width: 24,
                                height: 24,
                                child: IosSpinner(
                                  color: Color(0xFF6B4EE6),
                                  strokeWidth: 2,
                                ),
                              )
                            else
                              CupertinoSwitch(
                                value: vpnEnabled,
                                activeTrackColor: const Color(0xFF34C759),
                                onChanged: (val) {
                                  ref
                                      .read(vpnEnabledProvider.notifier)
                                      .toggle();
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
                          const Icon(
                            Icons.error_outline,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              vpnError,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  const Text(
                    'About Zen Shield',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.file_open_outlined),
                    label: const Text('Importar configuración WireGuard'),
                    onPressed: isLoading
                        ? null
                        : () => _importConfiguration(context, ref),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Zen Shield uses Cloudflare WARP (1.1.1.1) to encrypt your DNS queries and route your traffic through a secure tunnel. This helps bypass common ISP blocks on IPTV domains.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _importConfiguration(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final config = await showDialog<String>(
      context: context,
      builder: (ctx) => GlassDialog(
        title: const Text('Configuración WireGuard'),
        content: SizedBox(
          width: 520,
          child: RemoteTextField(
            controller: controller,
            minLines: 6,
            maxLines: 10,
            decoration: const InputDecoration(hintText: '[Interface]…'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    // The dialog transition can still reference its controller for one frame.
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.dispose());
    if (config == null || !context.mounted) return;
    try {
      await ref.read(vpnEnabledProvider.notifier).importConfiguration(config);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configuración guardada. Puedes activar la VPN.'),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configuración WireGuard no válida.')),
        );
      }
    }
  }
}
