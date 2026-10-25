import '../../core/widgets/remote_text_field.dart';

import 'package:go_router/go_router.dart';

import '../../core/widgets/remote_action.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../channels/widgets/iptv_image.dart';
import '../iptv_parser/providers/iptv_provider.dart';

class MoviesScreen extends ConsumerStatefulWidget {
  const MoviesScreen({super.key});

  @override
  ConsumerState<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends ConsumerState<MoviesScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final moviesAsync = ref.watch(moviesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      body: moviesAsync.when(
        data: (movies) {
          final filtered = _searchQuery.isEmpty
              ? movies
              : movies
                    .where(
                      (m) => m.name.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ),
                    )
                    .toList();

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                floating: true,
                expandedHeight: 148,
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Movies',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        RemoteTextField(
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Search movies...',
                            hintStyle: const TextStyle(color: Colors.white54),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.white54,
                            ),
                            filled: true,
                            fillColor: const Color(0xFF1E2132),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (val) =>
                              setState(() => _searchQuery = val),
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
                    crossAxisCount: (MediaQuery.of(context).size.width / 160)
                        .ceil(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.65,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final movie = filtered[index];
                    return RemoteAction(
                      onTap: () => context.pushNamed(
                        'player',
                        extra: ref
                            .read(xtreamClientProvider)!
                            .movieChannel(movie),
                      ),
                      child: Container(
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
                                url: movie.streamIcon,
                                fallbackUrl: '',
                                errorWidget: const Icon(
                                  Icons.movie,
                                  color: Colors.white24,
                                  size: 48,
                                ),
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                movie.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }, childCount: filtered.length),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF6B4EE6)),
        ),
        error: (e, st) => Center(
          child: Text('Error: $e', style: const TextStyle(color: Colors.red)),
        ),
      ),
    );
  }
}
