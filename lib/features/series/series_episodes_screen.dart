import '../../core/widgets/ios_spinner.dart';
import '../../core/widgets/glass.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/iptv_models.dart';
import '../iptv_parser/providers/iptv_provider.dart';

final seriesEpisodesProvider = FutureProvider.autoDispose
    .family<Map<String, List<Channel>>, String>((ref, id) {
      final client = ref.watch(xtreamClientProvider);
      return client?.getEpisodes(id) ?? Future.value({});
    });

class SeriesEpisodesScreen extends ConsumerWidget {
  const SeriesEpisodesScreen({super.key, required this.series});
  final VodItem series;
  @override
  Widget build(BuildContext context, WidgetRef ref) => GlassScaffold(
    appBar: AppBar(title: Text(series.name)),
    body: ref
        .watch(seriesEpisodesProvider(series.id))
        .when(
          loading: () => const Center(child: IosSpinner()),
          error: (_, _) => Center(
            child: TextButton(
              onPressed: () =>
                  ref.invalidate(seriesEpisodesProvider(series.id)),
              child: const Text(
                'No se pudieron cargar los episodios. Reintentar',
              ),
            ),
          ),
          data: (seasons) => seasons.isEmpty
              ? const Center(child: Text('No hay episodios disponibles.'))
              : CustomScrollView(
                  slivers: [
                    for (final entry in seasons.entries) ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            'Temporada ${entry.key}',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                      ),
                      SliverList.builder(
                        itemCount: entry.value.length,
                        itemBuilder: (context, index) => GlassTile(
                          title: Text(entry.value[index].name),
                          leading: const Icon(Icons.play_circle_outline),
                          onTap: () => context.pushNamed(
                            'player',
                            extra: entry.value[index],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
        ),
  );
}
