import '../../core/utils/updater_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:ui';
import 'package:flutter/cupertino.dart';

import '../../core/utils/wallpaper_provider.dart';
import '../../core/models/iptv_models.dart';
import 'providers/channels_filter_provider.dart';
import '../iptv_parser/providers/iptv_provider.dart';
import '../iptv_parser/providers/logo_provider.dart';
import '../iptv_parser/providers/epg_provider.dart';
import 'widgets/iptv_image.dart';
import '../favorites/providers/favorites_provider.dart';



class ChannelGroup {
  final String cleanName;
  final String category;
  final List<Channel> channels;

  ChannelGroup({required this.cleanName, required this.category, required this.channels});
}

// CACHE GIGANTE PARA EVITAR LAG EN EL BUILD
final Map<String, String> _cleanChannelNameCache = {};
final Map<String, List<EpgProgram>> _epgMatchCache = {};

String _getCleanChannelName(String raw) {
  if (_cleanChannelNameCache.containsKey(raw))
    return _cleanChannelNameCache[raw]!;

  String s = raw;
  s = s.replaceAll(RegExp(r'^.*?\|\s*'), '');
  s = s.replaceAll(
    RegExp(r'\blcampeons\b', caseSensitive: false),
    'LIGA DE CAMPEONES 1',
  );
  s = s.replaceAll(
    RegExp(
      r'\b(FHD|HD|SD|4K|HEVC|HDR|UHD|H265|VIP|PREMIUM|1080p|720p)\b',
      caseSensitive: false,
    ),
    '',
  );
  s = s.replaceAll(RegExp(r'\[BK\]|\(BK\)|BK\b', caseSensitive: false), '');
  s = s.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
  final res = s.toLowerCase().trim();

  _cleanChannelNameCache[raw] = res;
  return res;
}

String _extractQualityAndTags(String raw) {
  final exp = RegExp(
    r'\b(FHD|HD|SD|4K|HEVC|HDR|UHD|H265|1080p|720p)\b|\[BK\]|\(BK\)|BK\b',
    caseSensitive: false,
  );
  final matches = exp.allMatches(raw);
  return matches.map((m) => m.group(0)).join(' ');
}

int _getQualityWeight(String tags) {
  final t = tags.toLowerCase();
  if (t.contains('4k') || t.contains('uhd')) return 50;
  if (t.contains('fhd') || t.contains('1080')) return 40;
  if (t.contains('hd') || t.contains('720')) return 30;
  if (t.contains('sd')) return 10;
  return 20;
}

bool _isSeparator(String name) {
  final lower = name.toLowerCase();
  return name.contains('===') ||
         name.contains('---') ||
         name.contains('\u25C8') ||
         name.contains('\u25C6') ||
         name.contains('◆') ||
         name.contains('◈') ||
         name.contains('■') ||
         name.contains('●') ||
         name.startsWith('-') ||
         lower.contains('separador') ||
         lower.contains('separator');
}


final Map<String, String> _countryToIso = {
  'Afghanistan': 'af', 'Africa': 'za', 'Albania': 'al', 'Argentina': 'ar', 'Armenia': 'am',
  'Australia': 'au', 'Austria': 'at', 'Azerbaijan': 'az', 'Bangladesh': 'bd', 'Belgium': 'be',
  'Bolivia': 'bo', 'Brazil': 'br', 'Bulgaria': 'bg', 'Cambodia': 'kh', 'Cameroon': 'cm',
  'Ecuador': 'ec', 'España': 'es', 'Latinoamérica': 'es', 'Reino Unido': 'gb', 'Estados Unidos': 'us'
};

class ChannelsScreen extends ConsumerStatefulWidget {
  const ChannelsScreen({super.key});

  @override
  ConsumerState<ChannelsScreen> createState() => _ChannelsScreenState();
}


String _cleanGroupName(String rawGroup) {
  if (rawGroup.isEmpty) return 'General';
  String clean = rawGroup.replaceAll(RegExp(r'^=+\s*|\s*=+$'), ''); // removes === at start and end
  clean = clean.replaceAll(RegExp(r'^(EU|AM|AF|AS)\s*\|\s*'), ''); // removes EU | 
  return clean.trim();
}

class _ChannelsScreenState extends ConsumerState<ChannelsScreen> {


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UpdaterService.checkForUpdates(context);
    });
  }

  Future<void> _handleChannelTap(BuildContext context, ChannelGroup group, WidgetRef ref) async {
    if (group.channels.length == 1) {
      context.pushNamed('player', extra: group.channels.first);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final prefQualityName = prefs.getString('pref_quality_${group.cleanName}');

    if (prefQualityName != null) {
      // Find the channel that matches the saved preference
      final matchedChannel = group.channels.firstWhere(
        (c) => c.name == prefQualityName,
        orElse: () => group.channels.first,
      );
      if (matchedChannel.name == prefQualityName) {
        if (!mounted) return;
        context.pushNamed('player', extra: matchedChannel);
        return;
      }
    }

    // If no preference saved, or preference no longer exists, show picker
    if (mounted) _showVersionPicker(context, group, ref);
  }

  void _showVersionPicker(
    BuildContext context,
    ChannelGroup group,
    WidgetRef ref,
  ) {
    if (group.channels.length == 1) {
      context.pushNamed('player', extra: group.channels.first);
      return;
    }

    final displayName = group.channels.first.name
        .replaceAll(RegExp(r'^.*?\|\s*'), '')
        .replaceAll(RegExp(r'\b(fhd|hd|sd|4k|hevc|hdr|uhd|h265|vip|premium|1080p|720p)\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'\[bk\]|\(bk\)|bk\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'es\s*\|', caseSensitive: false), '')
        .trim();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                child: Container(
                  width: 340,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2132).withOpacity(0.4),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.15),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Center(
                              child: Column(
                                children: [
                                  const Icon(Icons.tv, color: Colors.white, size: 28),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Elegir Calidad',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    displayName,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 13,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Consumer(
                              builder: (context, ref, _) {
                                final favs = ref.watch(favoritesProvider);
                                final isFav = favs.any((f) => f.cleanName == group.cleanName);
                                return IconButton(
                                  icon: Icon(
                                    isFav ? Icons.star : Icons.star_border,
                                    color: isFav ? Colors.amber : Colors.white54,
                                    size: 24,
                                  ),
                                  onPressed: () {
                                    ref.read(favoritesProvider.notifier).toggleFavorite(
                                      group.cleanName,
                                      category: group.category,
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: 1,
                        color: Colors.white.withOpacity(0.1),
                      ),
                      ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: group.channels.length,
                        separatorBuilder: (_, __) => Container(
                          height: 1,
                          color: Colors.white.withOpacity(0.05),
                        ),
                        itemBuilder: (context, index) {
                          final c = group.channels[index];
                          // Extract just the quality part if possible, or use full name
                          final rawName = c.name.replaceAll(RegExp(r'^.*?\|\s*'), '');
                          return InkWell(
                            onTap: () async {
                              final prefs = await SharedPreferences.getInstance();
                              await prefs.setString('pref_quality_${group.cleanName}', c.name);
                              
                              if (!context.mounted) return;
                              Navigator.pop(context);
                              context.pushNamed('player', extra: c);
                            },
                            hoverColor: Colors.white.withOpacity(0.05),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      rawName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.play_circle_fill,
                                    color: Colors.white70,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(parent: anim1, curve: Curves.easeOutExpo),
            ),
            child: child,
          ),
        );
      },
    );
  }

  
  @override
  Widget build(BuildContext context) {
    final filteredMetadata = ref.watch(filteredMetadataProvider);
    final logoDbAsync = ref.watch(logoDatabaseProvider);
    final logoDb = logoDbAsync.value ?? {};

    Widget contentWidget;
    if (filteredMetadata.isEmpty) {
      contentWidget = const Center(
        child: Text('No se encontraron canales', style: TextStyle(color: Colors.white, fontSize: 18)),
      );
    } else {
      List<Widget> children = [];
      Map<String, Map<String, ChannelGroup>> consolidatedGroups = {};

      for (final metadata in filteredMetadata) {
        String groupName = metadata.subCategory;
        if (!consolidatedGroups.containsKey(groupName)) {
          consolidatedGroups[groupName] = {};
        }

        final cleanName = _getCleanChannelName(metadata.channel.name);
        if (!consolidatedGroups[groupName]!.containsKey(cleanName)) {
          consolidatedGroups[groupName]![cleanName] = ChannelGroup(
            cleanName: cleanName,
            category: metadata.subCategory,
            channels: [],
          );
        }
        consolidatedGroups[groupName]![cleanName]!.channels.add(metadata.channel);
      }

      final sortedGroupNames = consolidatedGroups.keys.toList()..sort();
      for (final groupName in sortedGroupNames) {
        Map<String, ChannelGroup> groupMap = consolidatedGroups[groupName]!;
        
        children.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Text(
              groupName.isEmpty ? 'Canales' : groupName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );

        final groups = groupMap.values.toList();
        for (final group in groups) {
          group.channels.sort((a, b) {
            String qa = _extractQualityAndTags(a.name);
            String qb = _extractQualityAndTags(b.name);
            int wa = _getQualityWeight(qa);
            int wb = _getQualityWeight(qb);
            if (wa != wb) return wa.compareTo(wb);
            return a.name.compareTo(b.name);
          });
        }

        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                childAspectRatio: 1.2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: groups.length,
              itemBuilder: (context, index) {
                return _buildChannelCard(groups[index], logoDb, context);
              },
            ),
          ),
        );
      }

      contentWidget = ListView(
        padding: const EdgeInsets.only(top: 120, bottom: 40),
        physics: const BouncingScrollPhysics(),
        children: children,
      );
    }

    final String wallpaper = ref.watch(wallpaperProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0F16),
      body: Stack(
        children: [
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
                    const Color(0xFF0D0F16).withValues(alpha: 0.95),
                    const Color(0xFF0D0F16).withValues(alpha: 0.6),
                    const Color(0xFF0D0F16).withValues(alpha: 0.2),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),
          Positioned.fill(child: contentWidget),
          Positioned(
            top: 48,
            left: 0,
            right: 0,
            child: _buildSmartFilterBar(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartFilterBar(BuildContext context, WidgetRef ref) {
    final availableFilters = ref.watch(availableFiltersProvider);
    final search = ref.watch(searchFilterProvider);
    final selectedCountry = ref.watch(countryFilterProvider);
    final selectedCategory = ref.watch(categoryFilterProvider);
    final selectedPlatform = ref.watch(platformFilterProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          // Search Bar
          Expanded(
            flex: 2,
            child: CupertinoSearchTextField(
              backgroundColor: Colors.white.withOpacity(0.1),
              itemColor: Colors.white70,
              style: const TextStyle(color: Colors.white),
              placeholder: 'Buscar canal...',
              onChanged: (val) => ref.read(searchFilterProvider.notifier).state = val,
            ),
          ),
          const SizedBox(width: 16),
          // Country Filter
          _buildFilterDropdown(
            title: 'País: ${selectedCountry ?? "Todos"}',
            options: ['Todos', ...availableFilters['countries'] ?? []],
            selectedValue: selectedCountry ?? 'Todos',
            onSelected: (val) => ref.read(countryFilterProvider.notifier).state = val == 'Todos' ? null : val,
            isCountry: true,
          ),
          const SizedBox(width: 16),
          // Category Filter
          _buildFilterDropdown(
            title: 'Categoría: ${selectedCategory ?? "Todas"}',
            options: ['Todas', ...availableFilters['categories'] ?? []],
            selectedValue: selectedCategory ?? 'Todas',
            onSelected: (val) => ref.read(categoryFilterProvider.notifier).state = val == 'Todas' ? null : val,
          ),
          const SizedBox(width: 16),
          // Platform Filter
          _buildFilterDropdown(
            title: 'Proveedor: ${selectedPlatform ?? "Todos"}',
            options: ['Todos', ...availableFilters['platforms'] ?? []],
            selectedValue: selectedPlatform ?? 'Todos',
            onSelected: (val) => ref.read(platformFilterProvider.notifier).state = val == 'Todos' ? null : val,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String title,
    required List<String> options,
    required String selectedValue,
    required Function(String) onSelected,
    bool isCountry = false,
  }) {
    return PopupMenuButton<String>(
      tooltip: '',
      color: const Color(0xFF1A1C23),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: onSelected,
      itemBuilder: (context) {
        return options.map((opt) {
          Widget childWidget = Text(
            opt,
            style: TextStyle(
              color: opt == selectedValue ? Colors.blueAccent : Colors.white,
              fontWeight: opt == selectedValue ? FontWeight.bold : FontWeight.normal,
            ),
          );

          if (isCountry && opt != 'Todos') {
            final iso = _countryToIso[opt] ?? 'xx'; // Fallback
            childWidget = Row(
              children: [
                ClipOval(
                  child: Image.network(
                    'https://flagcdn.com/w40/$iso.png',
                    width: 20,
                    height: 20,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 20, height: 20, color: Colors.grey,
                      child: const Icon(Icons.public, size: 12, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                childWidget,
              ],
            );
          }

          return PopupMenuItem<String>(
            value: opt,
            child: childWidget,
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 13)),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_drop_down, color: Colors.white70, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelCard(
    ChannelGroup group,
    Map<String, String> logoDb,
    BuildContext context,
  ) {
    final mainChannel = group.channels.first;
    String fallback = getLogoFallback(mainChannel.name, logoDb);
    bool isHovered = false;
    return StatefulBuilder(
      builder: (context, setStateLocal) {
        return MouseRegion(
          onEnter: (_) => setStateLocal(() => isHovered = true),
          onExit: (_) => setStateLocal(() => isHovered = false),
          child: GestureDetector(
        onTap: () => _handleChannelTap(context, group, ref),
        onLongPress: () => _showVersionPicker(context, group, ref),
        onSecondaryTap: () => _showVersionPicker(context, group, ref),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutExpo,
          transform: isHovered
              ? (Matrix4.identity()..scale(1.05))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: isHovered
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isHovered
                    ? Colors.white.withValues(alpha: 0.3)
                    : Colors.transparent,
                width: isHovered ? 1.5 : 0,
              ),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 40.0, left: 24.0, right: 24.0),
                  child: Align(
                    alignment: Alignment.center,
                    child: IptvImage(
                      url: mainChannel.logo,
                      fallbackUrl: fallback,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Builder(
                      builder: (context) {
                        String displayName = mainChannel.name
                            .replaceAll(RegExp(r'^.*?\|\s*'), '')
                            .replaceAll(RegExp(r'\b(fhd|hd|sd|4k|hevc|hdr|uhd|h265|vip|premium|1080p|720p)\b', caseSensitive: false), '')
                            .replaceAll(RegExp(r'\[bk\]|\(bk\)|bk\b', caseSensitive: false), '')
                            .replaceAll(RegExp(r'es\s*\|', caseSensitive: false), '')
                            .trim();
                        if (displayName.toUpperCase().contains('CINE ESPA')) {
                          displayName = 'M+ CINE';
                        }
                        return Text(
                          displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Consumer(
                    builder: (context, ref, _) {
                      final favs = ref.watch(favoritesProvider);
                      final isFav = favs.any((f) => f.cleanName == group.cleanName);
                      return IconButton(
                        icon: Icon(
                          isFav ? Icons.star : Icons.star_border,
                          color: isFav ? Colors.amber : Colors.white54,
                          size: 24,
                        ),
                        onPressed: () {
                          ref.read(favoritesProvider.notifier).toggleFavorite(
                            group.cleanName,
                            category: group.category,
                          );
                        },
                      );
                    },
                  ),
                ),
                if (group.channels.length > 1)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.layers,
                            color: Colors.white,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${group.channels.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
     },
    );
  }

  

}
