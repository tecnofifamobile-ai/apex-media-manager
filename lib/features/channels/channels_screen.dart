import '../../core/widgets/remote_text_field.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/models/iptv_models.dart';
import '../../core/utils/updater_service.dart';
import '../../core/utils/wallpaper_provider.dart';
import '../../core/widgets/remote_action.dart';
import '../favorites/providers/favorites_provider.dart';
import '../iptv_parser/providers/iptv_provider.dart';
import '../iptv_parser/providers/logo_provider.dart';
import 'channel_groups.dart';
import 'providers/channels_filter_provider.dart';
import 'widgets/iptv_image.dart';
import '../auth/local_mode_provider.dart';

class ChannelsScreen extends ConsumerStatefulWidget {
  const ChannelsScreen({super.key});
  @override
  ConsumerState<ChannelsScreen> createState() => _ChannelsScreenState();
}

class _ChannelsScreenState extends ConsumerState<ChannelsScreen> {
  Timer? _searchTimer;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !ref.read(localModeProvider)) {
        UpdaterService.checkForUpdates(context);
      }
    });
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    super.dispose();
  }

  void _play(Channel channel) => context.pushNamed('player', extra: channel);

  Future<void> _openGroup(ChannelGroup group) async {
    if (group.channels.length == 1) {
      _play(group.channels.first);
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final preferred = prefs.getString('pref_quality_${group.cleanName}');
    for (final channel in group.channels) {
      if (channel.name == preferred) {
        _play(channel);
        return;
      }
    }
    _chooseQuality(group);
  }

  Future<void> _chooseQuality(ChannelGroup group) async {
    final selected = await showDialog<Channel>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(channelDisplayName(group.channels.first.name)),
        content: SizedBox(
          width: 420,
          height: 320,
          child: ListView.builder(
            itemCount: group.channels.length,
            itemBuilder: (ctx, index) => ListTile(
              autofocus: index == 0,
              title: Text(group.channels[index].name),
              trailing: const Icon(Icons.play_arrow),
              onTap: () => Navigator.pop(ctx, group.channels[index]),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
    if (selected == null || !mounted) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pref_quality_${group.cleanName}', selected.name);
    if (mounted) _play(selected);
  }

  @override
  Widget build(BuildContext context) {
    final channels = ref.watch(channelsProvider);
    final sections = ref.watch(channelSectionsProvider);
    final logoDb = ref.watch(logoDatabaseProvider).value ?? <String, String>{};
    final wallpaper = ref.watch(wallpaperProvider);
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: Image.asset(
                wallpaper,
                fit: BoxFit.cover,
                cacheWidth: 1280,
              ),
            ),
          ),
          const Positioned.fill(child: ColoredBox(color: Color(0xBB0D0F16))),
          Column(
            children: [
              _filters(),
              Expanded(
                child: channels.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('No se pudo cargar la lista de canales.'),
                        TextButton(
                          onPressed: () => ref.invalidate(channelsProvider),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                  data: (_) => sections.isEmpty
                      ? const Center(child: Text('No se encontraron canales'))
                      : CustomScrollView(
                          scrollCacheExtent: ScrollCacheExtent.pixels(240),
                          key: const PageStorageKey('channels'),
                          slivers: [
                            for (final section in sections) ...[
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    24,
                                    20,
                                    24,
                                    12,
                                  ),
                                  child: Text(
                                    section.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall,
                                  ),
                                ),
                              ),
                              SliverPadding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                sliver: SliverGrid(
                                  gridDelegate:
                                      const SliverGridDelegateWithMaxCrossAxisExtent(
                                        maxCrossAxisExtent: 220,
                                        childAspectRatio: 1.25,
                                        crossAxisSpacing: 16,
                                        mainAxisSpacing: 16,
                                      ),
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) => _card(
                                      section.groups[index],
                                      logoDb,
                                      autofocus:
                                          section == sections.first &&
                                          index == 0,
                                    ),
                                    childCount: section.groups.length,
                                  ),
                                ),
                              ),
                            ],
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 32),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filters() {
    final filters = ref.watch(availableFiltersProvider);
    final country = ref.watch(countryFilterProvider);
    final category = ref.watch(categoryFilterProvider);
    final platform = ref.watch(platformFilterProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 4),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 240,
            child: RemoteTextField(
              decoration: const InputDecoration(
                hintText: 'Buscar canal...',
                prefixIcon: Icon(Icons.search),
                isDense: true,
              ),
              onChanged: (value) {
                _searchTimer?.cancel();
                _searchTimer = Timer(const Duration(milliseconds: 180), () {
                  if (mounted) {
                    ref.read(searchFilterProvider.notifier).setValue(value);
                  }
                });
              },
            ),
          ),
          _dropdown(
            'País',
            country,
            filters['countries'] ?? [],
            (value) => ref.read(countryFilterProvider.notifier).setValue(value),
          ),
          _dropdown(
            'Categoría',
            category,
            filters['categories'] ?? [],
            (value) =>
                ref.read(categoryFilterProvider.notifier).setValue(value),
          ),
          _dropdown(
            'Proveedor',
            platform,
            filters['platforms'] ?? [],
            (value) =>
                ref.read(platformFilterProvider.notifier).setValue(value),
          ),
        ],
      ),
    );
  }

  Widget _dropdown(
    String label,
    String? value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) => PopupMenuButton<String>(
    tooltip: label,
    onSelected: (v) => onChanged(v.isEmpty ? null : v),
    itemBuilder: (_) => [
      const PopupMenuItem(value: '', child: Text('Todos')),
      ...options.map(
        (option) => PopupMenuItem(value: option, child: Text(option)),
      ),
    ],
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Text('$label: ${value ?? "Todos"} ▾'),
    ),
  );

  Widget _card(
    ChannelGroup group,
    Map<String, String> logoDb, {
    bool autofocus = false,
  }) {
    final channel = group.channels.first;
    return RemoteAction(
      autofocus: autofocus,
      key: ValueKey('${group.category}/${group.cleanName}'),
      label: channelDisplayName(channel.name),
      onTap: () => _openGroup(group),
      onLongPress: () => _chooseQuality(group),
      onSecondaryTap: () => _chooseQuality(group),
      child: Card(
        color: const Color(0xDD1E2132),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
              child: Column(
                children: [
                  Expanded(
                    child: IptvImage(
                      url: channel.logo,
                      fallbackUrl: getLogoFallback(channel.name, logoDb),
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    channelDisplayName(channel.name),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Consumer(
                builder: (context, ref, _) {
                  final favorite = ref.watch(
                    favoritesProvider.select(
                      (values) =>
                          values.any((f) => f.cleanName == group.cleanName),
                    ),
                  );
                  return IconButton(
                    tooltip: favorite ? 'Quitar favorito' : 'Añadir favorito',
                    icon: Icon(
                      favorite ? Icons.star : Icons.star_border,
                      color: favorite ? Colors.amber : Colors.white60,
                      size: 22,
                    ),
                    onPressed: () => ref
                        .read(favoritesProvider.notifier)
                        .toggleFavorite(
                          group.cleanName,
                          category: group.category,
                        ),
                  );
                },
              ),
            ),
            if (group.channels.length > 1)
              Positioned(
                top: 0,
                left: 0,
                child: IconButton(
                  tooltip: 'Elegir calidad (${group.channels.length})',
                  icon: const Icon(Icons.layers, size: 20),
                  onPressed: () => _chooseQuality(group),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
