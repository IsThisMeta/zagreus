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
          body: (series?.monitored ?? false) ? 'Yes' : 'No',
        ),
        ZagTableContent(
          title: 'type',
          body: series?.zagSeriesType,
        ),
        ZagTableContent(
          title: 'path',
          body: series?.path,
        ),
        ZagTableContent(
          title: 'quality',
          body: qualityProfile?.name,
        ),
        ZagTableContent(
          title: 'language',
          body: languageProfile?.name,
        ),
        ZagTableContent(
          title: 'tags',
          body: series?.zagTags(tags),
        ),
        ZagTableContent(title: '', body: ''),
        ZagTableContent(
          title: 'status',
          body: series?.status?.toTitleCase(),
        ),
        ZagTableContent(
          title: 'next airing',
          body: series?.zagNextAiring(),
        ),
        ZagTableContent(
          title: 'added on',
          body: series?.zagDateAdded,
        ),
        ZagTableContent(title: '', body: ''),
        ZagTableContent(
          title: 'year',
          body: series?.zagYear,
        ),
        ZagTableContent(
          title: 'network',
          body: series?.zagNetwork,
        ),
        ZagTableContent(
          title: 'runtime',
          body: series?.zagRuntime,
        ),
        ZagTableContent(
          title: 'rating',
          body: series?.certification,
        ),
        ZagTableContent(
          title: 'genres',
          body: series?.zagGenres,
        ),
        ZagTableContent(
          title: 'alternate titles',
          body: series?.zagAlternateTitles,
        ),
      ],
    );
  }
}
