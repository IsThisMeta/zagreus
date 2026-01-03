import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:zagreus/modules/discover/core/tmdb_api.dart';
import 'package:zagreus/router/routes/discover.dart';

class MovieGenresSection extends StatefulWidget {
  final bool showTitle;

  const MovieGenresSection({
    super.key,
    this.showTitle = true,
  });

  @override
  State<MovieGenresSection> createState() => _MovieGenresSectionState();
}

class _MovieGenresSectionState extends State<MovieGenresSection> {
  List<Map<String, dynamic>>? _genres;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGenres();
  }

  Future<void> _loadGenres() async {
    final genres = await TMDBApi.getMovieGenres();
    if (mounted) {
      setState(() {
        _genres = genres;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showTitle)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Movie Genres',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
            ),
          if (widget.showTitle) SizedBox(height: 4 * MediaQuery.textScalerOf(context).scale(1.0)),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 5,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Container(
                    width: 160,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    if (_genres == null || _genres!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showTitle)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Movie Genres',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
          ),
        if (widget.showTitle) SizedBox(height: 4 * MediaQuery.textScalerOf(context).scale(1.0)),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _genres!.length,
            itemBuilder: (context, index) {
              final genre = _genres![index];
              return _GenreCard(
                genreId: genre['id'] as int,
                genreName: genre['name'] as String,
                backdropUrl: genre['backdrop'] as String?,
                isMovie: true,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _GenreCard extends StatelessWidget {
  final int genreId;
  final String genreName;
  final String? backdropUrl;
  final bool isMovie;

  const _GenreCard({
    required this.genreId,
    required this.genreName,
    required this.backdropUrl,
    required this.isMovie,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          DiscoverRoutes.MOVIE_GENRE_DISCOVER.go(
            params: {'genreId': genreId.toString()},
            extra: {
              'genreName': genreName,
              'backdropUrl': backdropUrl,
            },
          );
        },
        child: Container(
          width: 160,
          height: 90,
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade800,
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Backdrop image
                if (backdropUrl != null)
                  CachedNetworkImage(
                    imageUrl: backdropUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: Colors.grey.shade900),
                    errorWidget: (context, url, error) =>
                        Container(color: Colors.grey.shade900),
                  ),
                // Gradient overlay for text readability
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
                // Genre name
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Text(
                    genreName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
