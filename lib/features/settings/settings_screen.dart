import '../../core/widgets/adaptive_backdrop.dart';
import '../../core/widgets/remote_action.dart';

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../vpn/vpn_provider.dart';
import '../../core/utils/wallpaper_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vpnEnabled = ref.watch(vpnEnabledProvider);
    final wallpaper = ref.watch(wallpaperProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0F16),
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
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: const SizedBox(height: 80)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60.0),
                  child: Text(
                    'Configuración',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: const SizedBox(height: 40)),

              // Sections
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width > 800
                        ? 60.0
                        : 20.0,
                  ),
                  child: MediaQuery.of(context).size.width > 800
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildLeftColumn(vpnEnabled, context),
                            ),
                            const SizedBox(width: 40),
                            Expanded(child: _buildRightColumn(context)),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLeftColumn(vpnEnabled, context),
                            const SizedBox(height: 40),
                            _buildRightColumn(context),
                          ],
                        ),
                ),
              ),

              SliverToBoxAdapter(child: const SizedBox(height: 60)),
              SliverToBoxAdapter(
                child: const Center(
                  child: Text(
                    'APEX Media Manager - 2.2.55',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 13,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: const SizedBox(height: 40)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeftColumn(bool vpnEnabled, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Red y Seguridad'),
        _buildVpnGlassCard(vpnEnabled, context),
        const SizedBox(height: 40),
        _buildSectionTitle('Reproductor'),
        _buildGlassTileGroup([
          _buildGlassTile('Fuentes IPTV', Icons.cast_connected, context),
          _buildGlassTile(
            'Ajustes IPTV',
            Icons.settings_input_antenna,
            context,
          ),
          _buildGlassTile(
            'Reproductor de Vídeo',
            Icons.play_circle_outline,
            context,
          ),
          _buildGlassTile(
            'Descargas',
            Icons.download_done,
            context,
            isLast: true,
          ),
        ]),
      ],
    );
  }

  Widget _buildRightColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Apariencia'),
        _buildGlassTileGroup([
          _buildGlassTile(
            'Fondo de Pantalla',
            Icons.wallpaper,
            context,
            route: '/wallpaper_settings',
            isLast: true,
          ),
        ]),
        const SizedBox(height: 40),
        _buildSectionTitle('Soporte'),
        _buildGlassTileGroup([
          _buildGlassTile('Comunidad Discord', Icons.discord, context),
          _buildGlassTile(
            'Página de soporte',
            Icons.help_outline,
            context,
            isLast: true,
          ),
        ]),
        const SizedBox(height: 40),
        _buildSectionTitle('Legal'),
        _buildGlassTileGroup([
          _buildGlassTile(
            'Política de Privacidad',
            Icons.privacy_tip_outlined,
            context,
          ),
          _buildGlassTile(
            'Términos de Uso',
            Icons.article_outlined,
            context,
            isLast: true,
          ),
        ]),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 16),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.5),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildVpnGlassCard(bool vpnEnabled, BuildContext context) {
    return _GlassCard(
      onTap: () => context.push('/vpn_settings'),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: vpnEnabled
                    ? const Color(0xFF6B4EE6).withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shield,
                color: vpnEnabled ? const Color(0xFF6B4EE6) : Colors.white54,
                size: 28,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Zen Shield (VPN)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vpnEnabled
                        ? 'Conectado a Cloudflare WARP'
                        : 'Desactivado (riesgo de bloqueo ISP)',
                    style: TextStyle(
                      color: vpnEnabled
                          ? const Color(0xFF6B4EE6)
                          : Colors.white54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white38),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassTileGroup(List<Widget> children) {
    return _GlassCard(child: Column(children: children));
  }

  Widget _buildGlassTile(
    String title,
    IconData icon,
    BuildContext context, {
    bool isLast = false,
    String? route,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (route != null) {
            context.push(route);
          }
        },
        hoverColor: Colors.white.withValues(alpha: 0.05),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                children: [
                  Icon(icon, color: Colors.white70, size: 22),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.white38,
                    size: 20,
                  ),
                ],
              ),
            ),
            if (!isLast)
              Padding(
                padding: const EdgeInsets.only(left: 58),
                child: Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GlassCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _GlassCard({required this.child, this.onTap});

  @override
  State<_GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<_GlassCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: RemoteAction(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: _isHovered
              ? (Matrix4.identity()..scaleByDouble(1.02, 1.02, 1.0, 1.0))
              : Matrix4.identity(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AdaptiveBackdrop(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isHovered
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
