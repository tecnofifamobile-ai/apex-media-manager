import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/iptv_models.dart';
import '../../core/widgets/glass.dart';
import '../../core/widgets/ios_spinner.dart';
import '../../core/widgets/remote_action.dart';
import '../channels/channel_groups.dart';
import '../iptv_parser/providers/iptv_provider.dart';
import 'leagues.dart';
import 'providers/league_favorites_provider.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});
  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  bool _choosing = false;

  Future<T?> _choose<T>(
    String title,
    String subtitle,
    List<T> items,
    String Function(T) label,
  ) => showDialog<T>(
    context: context,
    builder: (ctx) => GlassDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subtitle,
            style: const TextStyle(fontSize: 13, color: Colors.white60),
          ),
          const SizedBox(height: 6),
          Text(title),
        ],
      ),
      content: SizedBox(
        width: 430,
        height: (items.length * 60.0).clamp(60.0, 340.0),
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (_, i) => ListTile(
            autofocus: i == 0,
            title: Text(
              label(items[i]),
              maxLines: 2,
              style: const TextStyle(fontSize: 15),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white54,
            ),
            onTap: () => Navigator.pop(ctx, items[i]),
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

  Future<void> _open(League league, {bool change = false}) async {
    if (_choosing) return;
    final groups = ref.read(leagueChannelsProvider)[league.id] ?? [];
    if (groups.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tu lista no contiene canales de ${league.name}. Añade una fuente en Ajustes.',
          ),
        ),
      );
      return;
    }
    _choosing = true;
    final profileKey = ref.read(leagueProfileKeyProvider);
    try {
      final choices = await ref.read(
        leagueFavoritesProvider(profileKey).future,
      );
      if (!mounted || profileKey != ref.read(leagueProfileKeyProvider)) return;
      if (!change) {
        final savedUrl = choices[league.id]?.url;
        for (final group in groups) {
          for (final channel in group.channels) {
            if (savedUrl == channel.url) {
              context.pushNamed('player', extra: channel);
              return;
            }
          }
        }
      }
      final group = await _choose<ChannelGroup>(
        'Elige el canal',
        league.name,
        groups,
        (group) => channelDisplayName(group.channels.first.name),
      );
      if (group == null || !mounted) return;
      final selected = await _choose<Channel>(
        'Elige la calidad',
        channelDisplayName(group.channels.first.name),
        group.channels,
        (channel) => channel.name,
      );
      if (selected == null ||
          !mounted ||
          profileKey != ref.read(leagueProfileKeyProvider)) {
        return;
      }
      await ref
          .read(leagueFavoritesProvider(profileKey).notifier)
          .save(
            league.id,
            LeagueChoice(url: selected.url, channelName: selected.name),
          );
      if (mounted && !change) context.pushNamed('player', extra: selected);
    } finally {
      _choosing = false;
    }
  }

  Future<void> _manage() async {
    final profileKey = ref.read(leagueProfileKeyProvider);
    await showDialog<void>(
      context: context,
      builder: (_) => Consumer(
        builder: (ctx, ref, _) {
          final saved =
              ref.watch(leagueFavoritesProvider(profileKey)).value ?? {};
          final available = ref.watch(leagueChannelsProvider);
          return GlassDialog(
            title: const Text('Tus ligas'),
            content: SizedBox(
              width: 430,
              height: 360,
              child: ListView.builder(
                itemCount: leagues.length,
                itemBuilder: (_, i) {
                  final league = leagues[i];
                  final pinned = saved.containsKey(league.id);
                  final count = available[league.id]?.length ?? 0;
                  return ListTile(
                    autofocus: i == 0,
                    title: Text(
                      league.name,
                      style: const TextStyle(fontSize: 15),
                    ),
                    subtitle: Text(
                      count == 0
                          ? 'Sin canales en esta lista'
                          : '$count canales disponibles',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                    ),
                    trailing: Icon(
                      pinned
                          ? Icons.check_circle_rounded
                          : Icons.add_circle_outline,
                      color: pinned ? Colors.white : Colors.white38,
                    ),
                    onTap: () => ref
                        .read(leagueFavoritesProvider(profileKey).notifier)
                        .save(league.id, pinned ? null : const LeagueChoice()),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Listo'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final channels = ref.watch(channelsProvider);
    final available = ref.watch(leagueChannelsProvider);
    final saved = ref.watch(
      leagueFavoritesProvider(ref.watch(leagueProfileKeyProvider)),
    );
    return GlassScaffold(
      body: saved.when(
        loading: () => const Center(child: IosSpinner()),
        error: (_, _) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(
              leagueFavoritesProvider(ref.read(leagueProfileKeyProvider)),
            ),
            child: const Text('Reintentar'),
          ),
        ),
        data: (choices) {
          final pinned = leagues
              .where((league) => choices.containsKey(league.id))
              .toList();
          return LayoutBuilder(
            builder: (context, box) {
              final wide = box.maxWidth >= 1000;
              final columns = box.maxWidth >= 650 ? 2 : 1;
              final rows = wide
                  ? (pinned.length / 3).ceil()
                  : (pinned.length / columns).ceil();
              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      wide ? 44 : 22,
                      22,
                      wide ? 44 : 22,
                      24,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Favoritos',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -1,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Tus ligas. Tu juego.',
                                  style: TextStyle(color: Colors.white54),
                                ),
                              ],
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _manage,
                            icon: const Icon(Icons.add_rounded, size: 20),
                            label: Text(
                              box.maxWidth < 400 ? 'Ligas' : 'Editar ligas',
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.all(14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (channels.isLoading)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Center(child: IosSpinner()),
                      ),
                    ),
                  if (channels.hasError)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: TextButton(
                          onPressed: () => ref.invalidate(channelsProvider),
                          child: const Text(
                            'No se pudo cargar la lista. Reintentar',
                          ),
                        ),
                      ),
                    ),
                  if (pinned.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: TextButton.icon(
                          onPressed: _manage,
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('Añade tu primera liga'),
                        ),
                      ),
                    ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: wide ? 44 : 22),
                    sliver: SliverList.builder(
                      itemCount: rows,
                      itemBuilder: (context, row) {
                        Widget card(int index) {
                          if (index >= pinned.length) {
                            return const SizedBox.expand();
                          }
                          final league = pinned[index];
                          return _LeagueCard(
                            key: ValueKey('league-${league.id}'),
                            league: league,
                            channels: available[league.id]?.length ?? 0,
                            selection: choices[league.id]?.channelName,
                            autofocus: index == 0,
                            onTap: () => _open(league),
                            onChange: () => _open(league, change: true),
                          );
                        }

                        if (wide) {
                          final i = row * 3;
                          // A single tile keeps its hero size; following rows use a bento composition.
                          final second = i + 1 < pinned.length;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 18),
                            child: SizedBox(
                              height: 440,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(flex: 3, child: card(i)),
                                  const SizedBox(width: 18),
                                  Expanded(
                                    flex: 2,
                                    child: second
                                        ? Column(
                                            children: [
                                              Expanded(child: card(i + 1)),
                                              const SizedBox(height: 18),
                                              Expanded(child: card(i + 2)),
                                            ],
                                          )
                                        : _AddLeagueTile(onTap: _manage),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: SizedBox(
                            height: columns == 1 ? 310 : 300,
                            child: Row(
                              children: [
                                for (
                                  var column = 0;
                                  column < columns;
                                  column++
                                ) ...[
                                  if (column > 0) const SizedBox(width: 16),
                                  Expanded(child: card(row * columns + column)),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (pinned.isNotEmpty)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(24, 8, 24, 28),
                        child: Text(
                          'Mantén pulsada una liga para cambiar el canal o la calidad.\nEn TV: botón Menú · En ordenador: clic derecho.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.white38),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _AddLeagueTile extends StatelessWidget {
  const _AddLeagueTile({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => RemoteAction(
    onTap: onTap,
    label: 'Añadir ligas',
    child: GlassSurface(
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add_circle_outline_rounded,
              size: 36,
              color: Colors.white54,
            ),
            SizedBox(height: 14),
            Text(
              'Más de lo que te mueve',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 6),
            Text(
              'Añadir ligas',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      ),
    ),
  );
}

class _LeagueCard extends StatefulWidget {
  const _LeagueCard({
    super.key,
    required this.league,
    required this.channels,
    this.selection,
    required this.onTap,
    required this.onChange,
    this.autofocus = false,
  });
  final League league;
  final int channels;
  final String? selection;
  final VoidCallback onTap, onChange;
  final bool autofocus;
  @override
  State<_LeagueCard> createState() => _LeagueCardState();
}

class _LeagueCardState extends State<_LeagueCard> {
  bool _active = false;
  @override
  Widget build(BuildContext context) {
    final league = widget.league;
    return MouseRegion(
      onEnter: (_) => setState(() => _active = true),
      onExit: (_) => setState(() => _active = false),
      child: AnimatedScale(
        scale: _active ? 1.015 : 1,
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        child: RemoteAction(
          label: league.name,
          autofocus: widget.autofocus,
          onFocusChange: (value) => setState(() => _active = value),
          onTap: widget.onTap,
          onLongPress: widget.onChange,
          onSecondaryTap: widget.onChange,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                  child: Image.asset(
                    league.background,
                    fit: BoxFit.cover,
                    cacheWidth: 1100,
                  ),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x5810141E),
                        Color(0x5510141E),
                        Color(0xED080B13),
                      ],
                    ),
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0x32FFFFFF),
                      width: .8,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(26, 22, 26, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        league.subtitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: league.id == 'laliga'
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: Image.asset(
                                    'assets/images/leagues/laliga-logo.png',
                                    width: 190,
                                    height: 160,
                                    cacheWidth: 600,
                                    fit: BoxFit.contain,
                                    color: Colors.white,
                                    colorBlendMode: BlendMode.srcIn,
                                  ),
                                )
                              : Text(
                                  league.name,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: league.name.length > 16 ? 24 : 36,
                                    height: 1,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -1,
                                  ),
                                ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  league.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.selection ??
                                      '${widget.channels} canales · Elige tu señal',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.play_circle_fill_rounded,
                            size: 30,
                            color: Colors.white70,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
