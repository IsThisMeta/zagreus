import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/string/string.dart';
import 'package:zagreus/modules/sonarr.dart';

class SonarrSeriesDetailsOverviewInformationBlock extends StatelessWidget {
  final SonarrSeries? series;
  final SonarrQualityProfile? qualityProfile;
  final SonarrLanguageProfile? languageProfile;
  final List<SonarrTag> tags;

  const SonarrSeriesDetailsOverviewInformationBlock({
    Key? key,
    required this.series,
    required this.qualityProfile,
    required this.languageProfile,
    required this.tags,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagTableCard(
      content: [
        ZagTableContent(
          title: 'sonarr.Monitoring'.tr(),
          body: (series?.monitored ?? false)
              ? 'zagreus.Yes'.tr()
              : 'zagreus.No'.tr(),
        ),
        ZagTableContent(
          title: 'sonarr.Type'.tr(),
          body: series?.zagSeriesType,
        ),
        ZagTableContent(
          title: 'sonarr.Path'.tr(),
          body: series?.path,
        ),
        ZagTableContent(
          title: 'sonarr.Quality'.tr(),
          body: qualityProfile?.name,
        ),
        ZagTableContent(
          title: 'sonarr.Language'.tr(),
          body: languageProfile?.name,
        ),
        ZagTableContent(
          title: 'sonarr.Tags'.tr(),
          body: series?.zagTags(tags),
        ),
        ZagTableContent(title: '', body: ''),
        ZagTableContent(
          title: 'sonarr.Status'.tr(),
          body: series?.status?.toTitleCase(),
        ),
        ZagTableContent(
          title: 'sonarr.NextAiring'.tr(),
          body: series?.zagNextAiring(),
        ),
        ZagTableContent(
          title: 'sonarr.AddedOn'.tr(),
          body: series?.zagDateAdded,
        ),
        ZagTableContent(title: '', body: ''),
        ZagTableContent(
          title: 'sonarr.Year'.tr(),
          body: series?.zagYear,
        ),
        ZagTableContent(
          title: 'sonarr.Network'.tr(),
          body: series?.zagNetwork,
        ),
        ZagTableContent(
          title: 'sonarr.Runtime'.tr(),
          body: series?.zagRuntime,
        ),
        ZagTableContent(
          title: 'sonarr.Rating'.tr(),
          body: series?.certification,
        ),
        ZagTableContent(
          title: 'sonarr.Genres'.tr(),
          body: series?.zagGenres,
        ),
        ZagTableContent(
          title: 'sonarr.AlternateTitles'.tr(),
          body: series?.zagAlternateTitles,
        ),
      ],
    );
  }
}
