import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/radarr.dart';

class RadarrMovieDetailsOverviewInformationBlock extends StatelessWidget {
  final RadarrMovie? movie;
  final RadarrQualityProfile? qualityProfile;
  final List<RadarrTag> tags;

  const RadarrMovieDetailsOverviewInformationBlock({
    Key? key,
    required this.movie,
    required this.qualityProfile,
    required this.tags,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagTableCard(
      content: [
        ZagTableContent(
          title: 'monitoring',
          body: (movie?.monitored ?? false) ? 'Yes' : 'No',
        ),
        ZagTableContent(title: 'path', body: movie?.path),
        ZagTableContent(title: 'quality', body: qualityProfile?.name),
        ZagTableContent(
          title: 'availability',
          body: movie?.zagMinimumAvailability,
        ),
        ZagTableContent(title: 'tags', body: movie?.zagTags(tags)),
        ZagTableContent(title: '', body: ''),
        ZagTableContent(title: 'status', body: movie?.status?.readable),
        ZagTableContent(title: 'in cinemas', body: movie?.zagInCinemasOn()),
        ZagTableContent(
          title: 'digital',
          body: movie?.zagDigitalReleaseDate(),
        ),
        ZagTableContent(
          title: 'physical',
          body: movie?.zagPhysicalReleaseDate(),
        ),
        ZagTableContent(title: 'added on', body: movie?.zagDateAdded()),
        ZagTableContent(title: '', body: ''),
        ZagTableContent(title: 'year', body: movie?.zagYear),
        ZagTableContent(title: 'studio', body: movie?.zagStudio),
        ZagTableContent(title: 'runtime', body: movie?.zagRuntime),
        ZagTableContent(title: 'rating', body: movie?.certification),
        ZagTableContent(title: 'genres', body: movie?.zagGenres),
        ZagTableContent(
            title: 'alternate titles', body: movie?.zagAlternateTitles),
      ],
    );
  }
}
