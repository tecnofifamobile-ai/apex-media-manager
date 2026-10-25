import '../../core/widgets/ios_spinner.dart';
import '../../core/widgets/glass.dart';

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/models/iptv_models.dart';
import '../../core/utils/device_capabilities.dart';
import '../../core/widgets/remote_action.dart';
import '../iptv_parser/providers/iptv_provider.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key, required this.channel});
  final Channel? channel;
  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  late final Player _player;
  late final VideoController _video;
  late Channel? _channel;
  final _remoteFocus = FocusNode(debugLabel: 'player remote');
  final _playFocus = FocusNode(debugLabel: 'play pause');
  final _subscriptions = <StreamSubscription<dynamic>>[];
  Timer? _hideTimer;
  bool _showControls = true, _playing = true, _buffering = true;
  String? _error;
  Duration _position = Duration.zero, _duration = Duration.zero;
  bool get _desktop =>
      Platform.isWindows || Platform.isLinux || Platform.isMacOS;

  @override
  void initState() {
    super.initState();
    _channel = widget.channel;
    _player = Player();
    _video = VideoController(_player);
    _subscriptions.addAll([
      _player.stream.playing.listen((v) {
        if (mounted) setState(() => _playing = v);
      }),
      _player.stream.buffering.listen((v) {
        if (mounted) setState(() => _buffering = v);
      }),
      _player.stream.error.listen((_) {
        if (mounted) {
          setState(() {
            _error = 'No se pudo reproducir este contenido.';
            _showControls = true;
          });
        }
      }),
      _player.stream.position.listen((v) {
        if (mounted && _showControls && _channel?.isLive == false) {
          setState(() => _position = v);
        }
      }),
      _player.stream.duration.listen((v) {
        if (mounted) setState(() => _duration = v);
      }),
    ]);
    if (_channel != null) {
      _open(_channel!);
    } else {
      _error = 'Selecciona un contenido para reproducir.';
      _buffering = false;
    }
    if (Platform.isAndroid) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
    _restartTimer();
  }

  Future<void> _open(Channel channel) async {
    if (mounted) {
      setState(() {
        _channel = channel;
        _error = null;
        _buffering = true;
        _position = Duration.zero;
        _duration = Duration.zero;
      });
    }
    try {
      await _player.open(Media(channel.url));
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'No se pudo abrir el contenido.';
          _buffering = false;
        });
      }
    }
  }

  void _restartTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 6), () {
      if (mounted && _error == null) _hide();
    });
  }

  void _hide() {
    _remoteFocus.requestFocus();
    setState(() => _showControls = false);
  }

  void _show() {
    if (!_showControls) setState(() => _showControls = true);
    _restartTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _playFocus.requestFocus();
    });
  }

  void _seek(int seconds) {
    if (_channel?.isLive != false || _duration == Duration.zero) return;
    final position = (_player.state.position.inSeconds + seconds).clamp(
      0,
      _duration.inSeconds,
    );
    _player.seek(Duration(seconds: position));
    _restartTimer();
  }

  KeyEventResult _key(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    _restartTimer();
    if (key == LogicalKeyboardKey.mediaPlayPause ||
        key == LogicalKeyboardKey.space) {
      _player.playOrPause();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.mediaPlay) {
      _player.play();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.mediaPause) {
      _player.pause();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.mediaFastForward) {
      _seek(30);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.mediaRewind) {
      _seek(-10);
      return KeyEventResult.handled;
    }
    if (!_showControls) {
      if (_channel?.isLive == false && key == LogicalKeyboardKey.arrowRight) {
        _seek(10);
        return KeyEventResult.handled;
      }
      if (_channel?.isLive == false && key == LogicalKeyboardKey.arrowLeft) {
        _seek(-10);
        return KeyEventResult.handled;
      }
      if ([
        LogicalKeyboardKey.select,
        LogicalKeyboardKey.enter,
        LogicalKeyboardKey.arrowUp,
        LogicalKeyboardKey.arrowDown,
        LogicalKeyboardKey.arrowLeft,
        LogicalKeyboardKey.arrowRight,
      ].contains(key)) {
        _show();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  Future<void> _fullScreen() async {
    if (_desktop) {
      await windowManager.setFullScreen(!await windowManager.isFullScreen());
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _remoteFocus.dispose();
    _playFocus.dispose();
    _player.dispose();
    if (_desktop) windowManager.setFullScreen(false);
    if (Platform.isAndroid) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations(
        DeviceCapabilities.isTv
            ? [
                DeviceOrientation.landscapeLeft,
                DeviceOrientation.landscapeRight,
              ]
            : [],
      );
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final channels = _channel?.isLive == true
        ? ref.watch(channelsProvider).value ?? <Channel>[]
        : <Channel>[];
    return PopScope(
      canPop: !_showControls,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _hide();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Focus(
          focusNode: _remoteFocus,
          autofocus: true,
          onKeyEvent: _key,
          child: GestureDetector(
            onTap: _show,
            onDoubleTap: _fullScreen,
            behavior: HitTestBehavior.opaque,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Video(controller: _video, controls: NoVideoControls),
                ),
                if (_buffering && _error == null)
                  const Center(child: IosSpinner()),
                if (_error != null)
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        if (_channel != null)
                          TextButton(
                            onPressed: () => _open(_channel!),
                            child: const Text('Reintentar'),
                          ),
                      ],
                    ),
                  ),
                if (_showControls)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xA0000000),
                            Color(0x00000000),
                            Color(0xC0000000),
                          ],
                          stops: [0, .45, 1],
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              IconButton(
                                tooltip: 'Volver',
                                icon: const Icon(Icons.arrow_back),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              Expanded(
                                child: Text(
                                  _channel?.name ?? 'Reproductor',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                              if (_desktop)
                                IconButton(
                                  tooltip: 'Pantalla completa',
                                  icon: const Icon(Icons.fullscreen),
                                  onPressed: _fullScreen,
                                ),
                            ],
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_channel?.isLive == false)
                                IconButton(
                                  tooltip: 'Retroceder 10 segundos',
                                  iconSize: 40,
                                  icon: const Icon(Icons.replay_10),
                                  onPressed: () => _seek(-10),
                                ),
                              IconButton(
                                focusNode: _playFocus,
                                autofocus: true,
                                tooltip: _playing ? 'Pausar' : 'Reproducir',
                                iconSize: 64,
                                icon: Icon(
                                  _playing
                                      ? Icons.pause_circle
                                      : Icons.play_circle,
                                ),
                                onPressed: () {
                                  _player.playOrPause();
                                  _restartTimer();
                                },
                              ),
                              if (_channel?.isLive == false)
                                IconButton(
                                  tooltip: 'Avanzar 10 segundos',
                                  iconSize: 40,
                                  icon: const Icon(Icons.forward_10),
                                  onPressed: () => _seek(10),
                                ),
                            ],
                          ),
                          const Spacer(),
                          if (_channel?.isLive == false &&
                              _duration.inSeconds > 0)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                              ),
                              child: Row(
                                children: [
                                  Text(_time(_position)),
                                  Expanded(
                                    child: Slider(
                                      value: _position.inSeconds
                                          .clamp(0, _duration.inSeconds)
                                          .toDouble(),
                                      max: _duration.inSeconds.toDouble(),
                                      onChanged: (value) {
                                        _player.seek(
                                          Duration(seconds: value.toInt()),
                                        );
                                        _restartTimer();
                                      },
                                    ),
                                  ),
                                  Text(_time(_duration)),
                                ],
                              ),
                            ),
                          if (channels.isNotEmpty)
                            SizedBox(
                              height: 76,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: channels.length,
                                itemExtent: 168,
                                itemBuilder: (context, index) => Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: RemoteAction(
                                    onTap: () {
                                      _open(channels[index]);
                                      _restartTimer();
                                    },
                                    child: GlassSurface(
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            channels[index].name,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _time(Duration value) =>
      '${value.inMinutes}:${(value.inSeconds % 60).toString().padLeft(2, '0')}';
}
