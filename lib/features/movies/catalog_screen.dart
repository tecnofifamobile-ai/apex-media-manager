import '../../core/widgets/ios_spinner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/glass.dart';
import '../../core/widgets/remote_action.dart';
import '../../core/widgets/remote_text_field.dart';
import '../channels/widgets/iptv_image.dart';
import '../iptv_parser/providers/iptv_provider.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key, this.series = false});
  final bool series;
  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  String _search = '';
  @override
  Widget build(BuildContext context) {
    final data = ref.watch(widget.series ? seriesProvider : moviesProvider);
    final narrow = MediaQuery.sizeOf(context).width < 600;
    final inset = narrow ? 20.0 : 40.0;
    return GlassScaffold(
      body: data.when(
        loading: () => const Center(child: IosSpinner()),
        error: (_, _) =>
            const Center(child: Text('No se pudo cargar el catálogo.')),
        data: (items) {
          final visible = items
              .where((item) => item.name.toLowerCase().contains(_search))
              .toList();
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(inset, 20, inset, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.series ? 'Series' : 'Películas',
                        style: TextStyle(
                          fontSize: narrow ? 32 : 42,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        widget.series
                            ? 'Historias para seguir descubriendo.'
                            : 'Tu próxima gran historia.',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 26),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: RemoteTextField(
                          decoration: InputDecoration(
                            hintText: widget.series
                                ? 'Buscar una serie'
                                : 'Buscar una película',
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: Colors.white54,
                            ),
                          ),
                          onChanged: (value) =>
                              setState(() => _search = value.toLowerCase()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (visible.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(inset),
                    child: GlassSurface(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.video_library_outlined,
                            size: 38,
                            color: Colors.white38,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            items.isEmpty
                                ? 'Tu catálogo aparecerá aquí'
                                : 'Sin resultados',
                          ),
                          if (items.isEmpty)
                            TextButton(
                              onPressed: () => context.go('/profile'),
                              child: const Text('Elegir fuente'),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(inset, 0, inset, 32),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    childAspectRatio: .61,
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 22,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = visible[index];
                    return RemoteAction(
                      autofocus: index == 0,
                      label: item.name,
                      onTap: () {
                        if (widget.series) {
                          context.pushNamed('episodes', extra: item);
                        } else {
                          final client = ref.read(xtreamClientProvider);
                          if (client != null) {
                            context.pushNamed(
                              'player',
                              extra: client.movieChannel(item),
                            );
                          }
                        }
                      },
                      child: GlassSurface(
                        radius: 22, blur: true, grouped: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: IptvImage(
                                    url: item.streamIcon,
                                    fallbackUrl: '',
                                    width: double.infinity,
                                    height: double.infinity,
                                    errorWidget: Icon(
                                      widget.series
                                          ? Icons.video_library_outlined
                                          : Icons.movie_outlined,
                                      size: 48,
                                      color: Colors.white24,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
                              child: Text(
                                item.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }, childCount: visible.length),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
