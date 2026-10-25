import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../channels/widgets/iptv_image.dart';
import '../iptv_parser/providers/iptv_provider.dart';

class SeriesScreen extends ConsumerStatefulWidget {
  const SeriesScreen({super.key});

  @override
  ConsumerState<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends ConsumerState<SeriesScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final seriesAsync = ref.watch(seriesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      body: seriesAsync.when(
        data: (series) {
          final filtered = _searchQuery.isEmpty 
            ? series 
            : series.where((s) => s.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                floating: true,
                expandedHeight: 120,
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Series', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        TextField(
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Search series...',
                            hintStyle: const TextStyle(color: Colors.white54),
                            prefixIcon: const Icon(Icons.search, color: Colors.white54),
                            filled: true,
                            fillColor: const Color(0xFF1E2132),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                          onChanged: (val) => setState(() => _searchQuery = val),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: (MediaQuery.of(context).size.width / 160).ceil(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.65,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = filtered[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2132),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: IptvImage(
                                url: item.streamIcon,
                                fallbackUrl: '',
                                errorWidget: const Icon(Icons.live_tv, color: Colors.white24, size: 48),
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                item.name,
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: filtered.length,
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF6B4EE6))),
        error: (e, st) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
      ),
    );
  }
}
