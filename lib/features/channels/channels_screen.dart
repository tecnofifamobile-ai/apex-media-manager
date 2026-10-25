import '../../core/widgets/ios_spinner.dart';
import '../../core/widgets/glass.dart';
import '../../core/widgets/remote_text_field.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/models/iptv_models.dart';
import '../../core/utils/updater_service.dart';

import '../../core/widgets/remote_action.dart';
import '../favorites/leagues.dart';
import '../favorites/providers/league_favorites_provider.dart';
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
      builder: (ctx) => GlassDialog(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Calidad de reproducción',
              style: TextStyle(fontSize: 13, color: Colors.white54),
            ),
            const SizedBox(height: 8),
            Text(channelDisplayName(group.channels.first.name)),
          ],
        ),
        content: SizedBox(
          width: 420,
          height: (group.channels.length * 68.0).clamp(68.0, 340.0),
          child: ListView.builder(
            itemCount: group.channels.length,
            itemBuilder: (ctx, index) => ListTile(
              autofocus: index == 0,
              title: Text(
                group.channels[index].name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              focusColor: const Color(0x20FFFFFF),
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

    return GlassScaffold(
      body: Stack(
        children: [
          Column(
            children: [
              _filters(),
              Expanded(
                child: channels.when(
                  loading: () => const Center(child: IosSpinner()),
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
      padding: const EdgeInsets.fromLTRB(24, 2, 24, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: 8,
          children: [
            SizedBox(
              width: MediaQuery.sizeOf(context).width < 680 ? 175 : 220,
              child: RemoteTextField(
                decoration: const InputDecoration(
                  hintText: 'Buscar canal...',
                  prefixIcon: Icon(Icons.search),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                  constraints: BoxConstraints(maxHeight: 42),
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
              (value) =>
                  ref.read(countryFilterProvider.notifier).setValue(value),
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
    child: GlassSurface(
      radius: 24,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value ?? label,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(width: 10),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 17,
            color: Colors.white54,
          ),
        ],
      ),
    ),
  );

  Widget _card(
    ChannelGroup group,
    Map<String, String> logoDb, {
    bool autofocus = false,
  }) {
    final channel = group.channels.first;
    final leagueId = ref.watch(leagueIdsByChannelProvider)[group.cleanName];
    return RemoteAction(
      autofocus: autofocus,
      key: ValueKey('${group.category}/${group.cleanName}'),
      label: channelDisplayName(channel.name),
      onTap: () => _openGroup(group),
      child: GlassSurface(
        radius: 24,
        blur: false,
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
            if (leagueId != null)
              Positioned(
                top: 0,
                right: 0,
                child: Consumer(
                  builder: (context, ref, _) {
                    final profileKey = ref.watch(leagueProfileKeyProvider);
                    final favorite =
                        ref
                            .watch(leagueFavoritesProvider(profileKey))
                            .value
                            ?.containsKey(leagueId) ??
                        false;
                    return IconButton(
                      tooltip: favorite
                          ? 'Quitar liga de favoritos'
                          : 'Añadir liga a favoritos',
                      icon: Icon(
                        favorite ? Icons.star : Icons.star_border,
                        color: favorite ? Colors.amber : Colors.white60,
                        size: 22,
                      ),
                      onPressed: () => ref
                          .read(leagueFavoritesProvider(profileKey).notifier)
                          .save(
                            leagueId,
                            favorite ? null : const LeagueChoice(),
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
