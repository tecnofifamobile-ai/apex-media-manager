import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/models/iptv_models.dart';
import '../channels/widgets/iptv_image.dart';
import '../iptv_parser/providers/iptv_provider.dart';
import '../iptv_parser/providers/logo_provider.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  final Channel? channel;

  const PlayerScreen({super.key, required this.channel});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  late final Player player;
  late final VideoController controller;
  
  bool _showOverlay = true;
  Timer? _hideOverlayTimer;
  bool _isPlaying = true;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    player = Player();
    controller = VideoController(player);

    if (Platform.isAndroid || Platform.isIOS) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
    
    // Hide mouse cursor by default after a while
    _startHideTimer();

    if (widget.channel != null) {
      player.open(Media(widget.channel!.url));
      player.stream.playing.listen((playing) {
        if (mounted) setState(() => _isPlaying = playing);
      });
    }
  }

  @override
  void dispose() {
    _hideOverlayTimer?.cancel();
    player.dispose();
    _restoreWindow();
    
    if (Platform.isAndroid || Platform.isIOS) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      windowManager.setFullScreen(false);
    }
    super.dispose();
  }

  void _restoreWindow() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      if (await windowManager.isFullScreen()) {
        await windowManager.setFullScreen(false);
      }
      if (await windowManager.isAlwaysOnTop()) {
        await windowManager.setAlwaysOnTop(false);
        await windowManager.setSize(const Size(1280, 720));
        await windowManager.setAlignment(Alignment.center);
      }
    }
  }

  void _startHideTimer() {
    _hideOverlayTimer?.cancel();
    _hideOverlayTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _showOverlay = false);
      }
    });
  }

  void _onHover() {
    if (!_showOverlay) {
      setState(() => _showOverlay = true);
    }
    _startHideTimer();
  }
  
  void _togglePlayPause() {
    player.playOrPause();
  }

  void _toggleFullScreen() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final isFull = await windowManager.isFullScreen();
      await windowManager.setFullScreen(!isFull);
      setState(() => _isFullScreen = !isFull);
    }
  }

  void _togglePiP() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final isAlwaysOnTop = await windowManager.isAlwaysOnTop();
      if (isAlwaysOnTop) {
        await windowManager.setAlwaysOnTop(false);
        await windowManager.setSize(const Size(1280, 720));
        await windowManager.setAlignment(Alignment.center);
      } else {
        if (_isFullScreen) {
          await windowManager.setFullScreen(false);
          setState(() => _isFullScreen = false);
        }
        await windowManager.setAlwaysOnTop(true);
        await windowManager.setSize(const Size(400, 225));
        await windowManager.setAlignment(Alignment.bottomRight);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final channelsAsync = ref.watch(channelsProvider);
    final allChannels = channelsAsync.value ?? [];
    final logoDb = ref.watch(logoDatabaseProvider).value ?? {};
    final fallbackUrl = widget.channel != null ? getLogoFallback(widget.channel!.name, logoDb) : '';

    return Scaffold(
      backgroundColor: Colors.black,
      body: MouseRegion(
        onHover: (_) => _onHover(),
        child: GestureDetector(
          onTap: _onHover,
          onDoubleTap: _toggleFullScreen,
          child: Stack(
            children: [
              Center(
                child: Video(
                  controller: controller,
                  controls: NoVideoControls, // Usamos nuestros propios controles
                ),
              ),
              
              // Custom Zen Player Overlay
              IgnorePointer(
                ignoring: !_showOverlay,
                child: AnimatedOpacity(
                  opacity: _showOverlay ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withOpacity(0.9),
                        ],
                        stops: const [0.0, 0.2, 0.7, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
              IgnorePointer(
                ignoring: !_showOverlay,
                child: Stack(
                  children: [
                    // Top Bar
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                      top: _showOverlay ? 16 : -80,
                      left: 16,
                      right: 16,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white, size: 28),
                            onPressed: () async {
                              if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
                                if (await windowManager.isFullScreen()) {
                                  await windowManager.setFullScreen(false);
                                }
                                if (await windowManager.isAlwaysOnTop()) {
                                  await windowManager.setAlwaysOnTop(false);
                                  await windowManager.setSize(const Size(1280, 720));
                                  await windowManager.setAlignment(Alignment.center);
                                }
                              }
                              if (mounted) {
                                Navigator.of(context).pop();
                              }
                            },
                          ),
                          const SizedBox(width: 16),
                          if (widget.channel != null) ...[
                            Text(
                              widget.channel!.name,
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.picture_in_picture_alt, color: Colors.white),
                            onPressed: _togglePiP,
                          ),
                          IconButton(
                            icon: Icon(_isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen, color: Colors.white),
                            onPressed: _toggleFullScreen,
                          ),
                        ],
                      ),
                    ),
                    
                    // Center Play/Pause & Watermark
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: _showOverlay ? 1.0 : 0.0,
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.channel != null)
                              Opacity(
                                opacity: 0.5,
                                child: IptvImage(
                                  url: widget.channel!.logo,
                                  fallbackUrl: fallbackUrl,
                                  errorWidget: const Icon(Icons.tv, color: Colors.white, size: 48),
                                  width: 120,
                                  height: 120,
                                ),
                              ),
                            const SizedBox(width: 24),
                            GestureDetector(
                              onTap: _togglePlayPause,
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white,
                                  size: 48,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Bottom Area
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                      bottom: _showOverlay ? 0 : -200,
                      left: 0,
                      right: 0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Quick Action Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildQuickButton(Icons.closed_caption_outlined, 'Language and subtitles'),
                              const SizedBox(width: 16),
                              _buildQuickButton(Icons.bedtime_outlined, 'Sleep timer'),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          // Channel List
                          SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: allChannels.length > 50 ? 50 : allChannels.length, // Limit for performance if needed
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              itemBuilder: (context, index) {
                                final ch = allChannels[index];
                                // Skip separators
                                if (ch.name.startsWith('+') || ch.name.startsWith('-') || ch.name.startsWith('=')) return const SizedBox();
                                
                                bool isCurrent = widget.channel?.name == ch.name;
                                return _buildBottomChannelCard(ch, isCurrent, logoDb);
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickButton(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBottomChannelCard(Channel ch, bool isCurrent, Map<String, String> logoDb) {
    final fallbackUrl = getLogoFallback(ch.name, logoDb);
    
    return GestureDetector(
      onTap: () {
        player.open(Media(ch.url));
        // We could also pushReplacement if we want to change the channel entirely in the route
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isCurrent ? const Color(0xFF2C3144) : const Color(0xFF141624).withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isCurrent ? const Color(0xFF6B4EE6) : Colors.transparent, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IptvImage(url: ch.logo, fallbackUrl: fallbackUrl, errorWidget: const Icon(Icons.tv, color: Colors.white, size: 24), width: 60, height: 40),
            const SizedBox(height: 8),
            Text(
              ch.name,
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
