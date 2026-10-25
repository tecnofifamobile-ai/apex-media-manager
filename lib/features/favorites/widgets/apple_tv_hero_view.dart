import '../../../core/widgets/remote_action.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/iptv_models.dart';
import '../utils/wallpaper_mapper.dart';
import '../../channels/widgets/iptv_image.dart';
import '../../iptv_parser/providers/logo_provider.dart';

class AppleTvHeroView extends StatefulWidget {
  final List<Channel> favoriteChannels;
  final Map<String, String> logoDb;

  const AppleTvHeroView({
    super.key,
    required this.favoriteChannels,
    required this.logoDb,
  });

  @override
  State<AppleTvHeroView> createState() => _AppleTvHeroViewState();
}

class _AppleTvHeroViewState extends State<AppleTvHeroView> {
  String _hoveredCleanName = '';

  @override
  void initState() {
    super.initState();
    if (widget.favoriteChannels.isNotEmpty) {
      _hoveredCleanName = widget.favoriteChannels.first.name
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]'), '');
    }
  }

  @override
  void didUpdateWidget(AppleTvHeroView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.favoriteChannels.isNotEmpty &&
        !widget.favoriteChannels.any(
          (c) =>
              c.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '') ==
              _hoveredCleanName,
        )) {
      _hoveredCleanName = widget.favoriteChannels.first.name
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]'), '');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.favoriteChannels.isEmpty) {
      return const Center(
        child: Text(
          'Aún no tienes canales favoritos',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    final String wallpaperUrl = WallpaperMapper.getHeroWallpaper(
      _hoveredCleanName,
      null,
    );

    return Stack(
      children: [
        // Background Hero
        Positioned.fill(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Image.network(
              wallpaperUrl,
              key: ValueKey(wallpaperUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),

        // Gradient Shadow
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0D0F16).withValues(alpha: 0.95),
                  const Color(0xFF0D0F16).withValues(alpha: 0.4),
                  Colors.transparent,
                  const Color(0xFF0D0F16).withValues(alpha: 0.9),
                ],
                stops: const [0.0, 0.2, 0.6, 1.0],
                begin: Alignment.centerLeft,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),

        // Carousel
        Positioned(
          left: 40,
          right: 0,
          bottom: 40,
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.favoriteChannels.length,
            itemBuilder: (context, index) {
              final channel = widget.favoriteChannels[index];
              final cleanName = channel.name.toLowerCase().replaceAll(
                RegExp(r'[^a-z0-9]'),
                '',
              );
              final isHovered = _hoveredCleanName == cleanName;
              String fallback = getLogoFallback(channel.name, widget.logoDb);

              return MouseRegion(
                onEnter: (_) => setState(() => _hoveredCleanName = cleanName),
                child: RemoteAction(
                  onTap: () {
                    context.pushNamed('player', extra: channel);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutExpo,
                    margin: const EdgeInsets.only(right: 20),
                    width: isHovered ? 260 : 220,
                    height: isHovered ? 180 : 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: const Color(0xFF1E2132).withValues(alpha: 0.9),
                      border: Border.all(
                        color: isHovered ? Colors.white : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: isHovered
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ]
                          : [],
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: IptvImage(
                                url: channel.logo,
                                fallbackUrl: fallback,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                          ),
                        ),
                        if (isHovered)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(14),
                                ),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withValues(alpha: 0.8),
                                    Colors.transparent,
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                              child: Text(
                                channel.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
