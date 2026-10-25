import '../../core/widgets/remote_text_field.dart';
import '../channels/channel_groups.dart';
import '../../core/widgets/adaptive_backdrop.dart';
import '../../core/widgets/remote_action.dart';

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/iptv_models.dart';
import '../../core/models/favorite_channel.dart';
import '../iptv_parser/providers/iptv_provider.dart';
import '../iptv_parser/providers/logo_provider.dart';
import 'providers/favorites_provider.dart';
import 'utils/wallpaper_mapper.dart';
import '../channels/widgets/iptv_image.dart';
import 'widgets/hero_image.dart';

class FavoriteChannelData {
  final FavoriteChannel fav;
  final List<Channel> variants;
  FavoriteChannelData(this.fav, this.variants);

  Channel get currentChannel {
    if (fav.preferredUrl != null) {
      try {
        return variants.firstWhere((c) => c.url == fav.preferredUrl);
      } catch (_) {}
    }
    return variants.first;
  }
}

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});
  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  String _hoveredCleanName = '';
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showChangeCategoryDialog(FavoriteChannel fav) {
    final tc = TextEditingController(text: fav.category);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2132),
        title: const Text(
          'Cambiar Categoría',
          style: TextStyle(color: Colors.white),
        ),
        content: RemoteTextField(
          controller: tc,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Nombre de la nueva categoría',
            hintStyle: TextStyle(color: Colors.white54),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B4EE6),
            ),
            onPressed: () {
              if (tc.text.isNotEmpty) {
                ref
                    .read(favoritesProvider.notifier)
                    .setCategory(fav.cleanName, tc.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showOptionsDialog(FavoriteChannelData data) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2132),
        title: Text(
          'Opciones: ${formatTitle(data.variants.first.name)}',
          style: const TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (data.variants.length > 1) ...[
                const Text(
                  'Seleccionar Calidad',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ...data.variants.map(
                  (v) => ListTile(
                    title: Text(
                      v.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: data.fav.preferredUrl == v.url
                        ? const Icon(Icons.check, color: Colors.green)
                        : null,
                    onTap: () {
                      ref
                          .read(favoritesProvider.notifier)
                          .updatePreferred(data.fav.cleanName, v.url, v.name);
                      Navigator.pop(ctx);
                    },
                  ),
                ),
                const Divider(color: Colors.white24),
              ],
              ListTile(
                leading: const Icon(Icons.folder, color: Colors.blue),
                title: const Text(
                  'Mover a categoría...',
                  style: TextStyle(color: Colors.blue),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _showChangeCategoryDialog(data.fav);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Quitar de favoritos',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  ref
                      .read(favoritesProvider.notifier)
                      .toggleFavorite(data.fav.cleanName);
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String formatTitle(String rawName) {
    String name = rawName;
    name = name.replaceAll(RegExp(r'^.*?\|\s*'), '');
    name = name.replaceAll(
      RegExp(
        r'\b(fhd|hd|sd|4k|hevc|hdr|uhd|h265|vip|premium|1080p|720p)\b',
        caseSensitive: false,
      ),
      '',
    );
    name = name.replaceAll(
      RegExp(r'\[bk\]|\(bk\)|bk\b', caseSensitive: false),
      '',
    );
    name = name.replaceAll(RegExp(r'es\s*\|', caseSensitive: false), '');
    return name.trim();
  }

  String getQualityLabel(String name) {
    final upper = name.toUpperCase();
    if (upper.contains('4K')) return '4K UHD';
    if (upper.contains('FHD') || upper.contains('1080')) return 'FHD 1080p';
    if (upper.contains('HD') || upper.contains('720')) return 'HD 720p';
    return 'SD';
  }

  Widget _buildCategoryRow(
    String categoryName,
    List<FavoriteChannelData> items,
    Map<String, String> logoDb,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 8.0),
          child: Text(
            categoryName,
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isHovered = _hoveredCleanName == item.fav.cleanName;
              String fallback = getLogoFallback(
                item.variants.first.name,
                logoDb,
              );

              return MouseRegion(
                onEnter: (_) =>
                    setState(() => _hoveredCleanName = item.fav.cleanName),
                child: RemoteAction(
                  onFocusChange: (focused) {
                    if (focused) {
                      setState(() => _hoveredCleanName = item.fav.cleanName);
                    }
                  },
                  onTap: () {
                    if (item.variants.length > 1 &&
                        item.fav.preferredUrl == null) {
                      _showOptionsDialog(item);
                    } else {
                      context.pushNamed('player', extra: item.currentChannel);
                    }
                  },
                  onLongPress: () => _showOptionsDialog(item),
                  onSecondaryTap: () => _showOptionsDialog(item),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutExpo,
                    margin: const EdgeInsets.only(
                      right: 20,
                      top: 10,
                      bottom: 10,
                    ),
                    width: isHovered ? 260 : 220,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: AdaptiveBackdrop(
                        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isHovered
                                  ? Colors.white.withValues(alpha: 0.8)
                                  : Colors.white.withValues(alpha: 0.1),
                              width: isHovered ? 2 : 1,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: IptvImage(
                                      url: item.currentChannel.logo,
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
                                      formatTitle(item.currentChannel.name),
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
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(favoriteCategoriesProvider);
    final channelsAsync = ref.watch(channelsProvider);
    final logoDbAsync = ref.watch(logoDatabaseProvider);
    final logoDb = logoDbAsync.value ?? {};
    final allFavs = ref.watch(favoritesProvider);
    final channelIndex = ref.watch(channelsByIdentityProvider);

    Map<String, List<FavoriteChannelData>> channelsByCategory = {};
    FavoriteChannelData? hoveredItem;

    channelsAsync.whenData((channels) {
      if (_hoveredCleanName.isEmpty && allFavs.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() => _hoveredCleanName = allFavs.first.cleanName);
          }
        });
      }

      for (var cat in categories) {
        final favsInCat = allFavs.where((f) => f.category == cat).toList();
        List<FavoriteChannelData> favChannels = [];
        for (var fav in favsInCat) {
          final match = channelIndex[fav.cleanName] ?? <Channel>[];
          if (match.isNotEmpty) {
            final data = FavoriteChannelData(fav, match);
            favChannels.add(data);
            if (fav.cleanName == _hoveredCleanName) {
              hoveredItem = data;
            }
          }
        }
        if (favChannels.isNotEmpty) {
          channelsByCategory[cat] = favChannels;
        }
      }
    });

    final String wallpaperUrl = WallpaperMapper.getHeroWallpaper(
      _hoveredCleanName,
      null,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0D0F16),
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 700),
              child: HeroImage(key: ValueKey(wallpaperUrl), url: wallpaperUrl),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0D0F16).withValues(alpha: 0.95),
                    const Color(0xFF0D0F16).withValues(alpha: 0.7),
                    const Color(0xFF0D0F16).withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0D0F16).withValues(alpha: 1.0),
                    const Color(0xFF0D0F16).withValues(alpha: 0.5),
                    const Color(0xFF0D0F16).withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.4, 0.8],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),

          Positioned.fill(
            child: channelsAsync.when(
              data: (_) {
                if (channelsByCategory.isEmpty) {
                  return const Center(
                    child: Text(
                      'Aun no tienes canales favoritos',
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                  );
                }

                return ListView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    Container(
                      height: 400,
                      padding: const EdgeInsets.only(
                        left: 40,
                        right: 40,
                        top: 120,
                      ),
                      child: hoveredItem == null
                          ? const SizedBox()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  formatTitle(hoveredItem!.currentChannel.name),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 56,
                                    fontWeight: FontWeight.w900,
                                    height: 1.1,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 6),
                                    const Text(
                                      '5.0',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        getQualityLabel(
                                          hoveredItem!.currentChannel.name,
                                        ),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'Live TV',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: 600,
                                  child: Text(
                                    'Disfruta de la mejor programacion en directo a traves de ${formatTitle(hoveredItem!.currentChannel.name)}. Deportes, peliculas, series y eventos en vivo disponibles las 24 horas.',
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.7,
                                      ),
                                      fontSize: 16,
                                      height: 1.4,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    if (hoveredItem!.variants.length > 1 &&
                                        hoveredItem!.fav.preferredUrl == null) {
                                      _showOptionsDialog(hoveredItem!);
                                    } else {
                                      context.pushNamed(
                                        'player',
                                        extra: hoveredItem!.currentChannel,
                                      );
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.play_arrow,
                                    color: Colors.black,
                                  ),
                                  label: const Text(
                                    'Ver Ahora',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 40),
                    ...categories
                        .where((c) => channelsByCategory.containsKey(c))
                        .map(
                          (cat) => _buildCategoryRow(
                            cat,
                            channelsByCategory[cat]!,
                            logoDb,
                          ),
                        ),
                    const SizedBox(height: 100),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => const Center(
                child: Text('Error', style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
