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
          title: 'radarr.Monitoring'.tr(),
          body: (movie?.monitored ?? false)
              ? 'zagreus.Yes'.tr()
              : 'zagreus.No'.tr(),
        ),
        ZagTableContent(title: 'radarr.Path'.tr(), body: movie?.path),
        ZagTableContent(title: 'radarr.Quality'.tr(), body: qualityProfile?.name),
        ZagTableContent(
          title: 'radarr.Availability'.tr(),
          body: movie?.zagMinimumAvailability,
        ),
        ZagTableContent(title: 'radarr.Tags'.tr(), body: movie?.zagTags(tags)),
        ZagTableContent(title: '', body: ''),
        ZagTableContent(title: 'radarr.Status'.tr(), body: movie?.status?.readable),
        ZagTableContent(
          title: 'radarr.InCinemas'.tr(),
          body: movie?.zagInCinemasOn(),
        ),
        ZagTableContent(
          title: 'radarr.Digital'.tr(),
          body: movie?.zagDigitalReleaseDate(),
        ),
        ZagTableContent(
          title: 'radarr.Physical'.tr(),
          body: movie?.zagPhysicalReleaseDate(),
        ),
        ZagTableContent(title: 'radarr.DateAdded'.tr(), body: movie?.zagDateAdded()),
        ZagTableContent(title: '', body: ''),
        ZagTableContent(title: 'radarr.Year'.tr(), body: movie?.zagYear),
        ZagTableContent(title: 'radarr.Studio'.tr(), body: movie?.zagStudio),
        ZagTableContent(title: 'radarr.Runtime'.tr(), body: movie?.zagRuntime),
        ZagTableContent(title: 'radarr.Rating'.tr(), body: movie?.certification),
        ZagTableContent(title: 'radarr.Genres'.tr(), body: movie?.zagGenres),
        ZagTableContent(
            title: 'radarr.AlternateTitles'.tr(),
            body: movie?.zagAlternateTitles),
      ],
    );
  }
}
