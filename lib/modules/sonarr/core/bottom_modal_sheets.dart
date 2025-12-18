import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/sonarr.dart';

class SonarrBottomModalSheets {
  Future<void> configureManualImport(BuildContext context) async {
    await ZagBottomModalSheet().show(
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<SonarrManualImportDetailsTileState>(),
        builder: (context, _) => ZagListViewModal(
          children: [
            ZagHeader(
              text: 'sonarr.Configure'.tr(),
              subtitle: context
                  .read<SonarrManualImportDetailsTileState>()
                  .manualImport
                  .relativePath,
            ),
            ZagBlock(
              title: 'sonarr.SelectSeries'.tr(),
              body: [
                TextSpan(
                  text: context
                      .watch<SonarrManualImportDetailsTileState>()
                      .manualImport
                      .zagSeriesAndEpisodes,
                ),
              ],
              trailing: const ZagIconButton.arrow(),
              onTap: () async {
                Tuple2<bool, SonarrSeries?> result = await selectSeries(context);
                if (!context.mounted) return;
                if (result.item1 && result.item2 != null) {
                  final tileState =
                      context.read<SonarrManualImportDetailsTileState>();
                  final selectedSeries = result.item2!;

                  tileState.setSeries(selectedSeries);

                  if (selectedSeries.id != null) {
                    final episodeResult = await selectEpisode(
                      context,
                      seriesId: selectedSeries.id!,
                    );
                    if (!context.mounted) return;
                    if (episodeResult.item1 && episodeResult.item2?.id != null) {
                      tileState.setEpisode(episodeResult.item2!);
                      final ok = await tileState.fetchUpdates(
                        context,
                        selectedSeries.id,
                        [episodeResult.item2!.id!],
                      );
                      if (!context.mounted) return;
                      if (!ok) {
                        showZagInfoSnackBar(
                          title: 'sonarr.Configure'.tr(),
                          message:
                              'Saved locally, but failed to sync selection with Sonarr',
                        );
                      }
                    }
                  }
                }
              },
            ),
            ZagBlock(
              title: 'sonarr.SelectEpisode'.tr(),
              body: [
                TextSpan(
                  text: () {
                    final manualImport = context
                        .watch<SonarrManualImportDetailsTileState>()
                        .manualImport;
                    final episode = manualImport.episode;
                    if (episode == null) return ZagUI.TEXT_EMDASH;
                    final season = (episode.seasonNumber ?? 0)
                        .toString()
                        .padLeft(2, '0');
                    final number = (episode.episodeNumber ?? 0)
                        .toString()
                        .padLeft(2, '0');
                    final title = episode.title?.isNotEmpty ?? false
                        ? episode.title!
                        : ZagUI.TEXT_EMDASH;
                    return 'S$season' 'E$number - $title';
                  }(),
                ),
              ],
              trailing: const ZagIconButton.arrow(),
              onTap: () async {
                final tileState =
                    context.read<SonarrManualImportDetailsTileState>();
                final seriesId = tileState.manualImport.series?.id;
                if (seriesId == null) {
                  showZagInfoSnackBar(
                    title: 'sonarr.SelectSeries'.tr(),
                    message: 'Please select a series first',
                  );
                  return;
                }
                final episodeResult = await selectEpisode(
                  context,
                  seriesId: seriesId,
                );
                if (!context.mounted) return;
                if (episodeResult.item1 && episodeResult.item2?.id != null) {
                  tileState.setEpisode(episodeResult.item2!);
                  final ok = await tileState.fetchUpdates(
                    context,
                    seriesId,
                    [episodeResult.item2!.id!],
                  );
                  if (!context.mounted) return;
                  if (!ok) {
                    showZagInfoSnackBar(
                      title: 'sonarr.Configure'.tr(),
                      message:
                          'Saved locally, but failed to sync selection with Sonarr',
                    );
                  }
                }
              },
            ),
            ZagBlock(
              title: 'sonarr.SelectQuality'.tr(),
              body: [
                TextSpan(
                  text: context
                      .watch<SonarrManualImportDetailsTileState>()
                      .manualImport
                      .zagQualityProfile,
                ),
              ],
              trailing: const ZagIconButton.arrow(),
              onTap: () async => selectQuality(context),
            ),
            ZagBlock(
              title: 'sonarr.SelectLanguage'.tr(),
              body: [
                TextSpan(
                  text: context
                      .watch<SonarrManualImportDetailsTileState>()
                      .manualImport
                      .zagLanguage,
                ),
              ],
              trailing: const ZagIconButton.arrow(),
              onTap: () async {
                final tileState =
                    context.read<SonarrManualImportDetailsTileState>();

                final languageResult = await selectLanguage(context);
                if (!context.mounted) return;

                if (languageResult.item1 && languageResult.item2 != null) {
                  tileState.setLanguage(languageResult.item2!);
                  final ok = await tileState.fetchUpdates(
                    context,
                    tileState.manualImport.series?.id,
                    tileState.manualImport.episode?.id != null
                        ? [tileState.manualImport.episode!.id!]
                        : null,
                  );
                  if (!context.mounted) return;
                  if (!ok) {
                    showZagInfoSnackBar(
                      title: 'sonarr.Configure'.tr(),
                      message:
                          'Saved locally, but failed to sync selection with Sonarr',
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> selectQuality(BuildContext context) async {
    List<SonarrQualityProfile> profiles =
        await context.read<SonarrState>().qualityProfiles!;

    await ZagBottomModalSheet().show(
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<SonarrManualImportDetailsTileState>(),
        builder: (context, _) => ZagListViewModalBuilder(
          itemCount: profiles.length,
          itemBuilder: (context, index) {
            return ZagBlock(
              title: profiles[index].name ?? ZagUI.TEXT_EMDASH,
              onTap: () {
                // Create quality object
                SonarrEpisodeFileQualityQuality quality = SonarrEpisodeFileQualityQuality(
                  id: profiles[index].id,
                  name: profiles[index].name,
                );
                context
                    .read<SonarrManualImportDetailsTileState>()
                    .updateQuality(quality);
                Navigator.of(context).pop();
              },
            );
          },
          appBar: ZagAppBar(
            title: 'sonarr.SelectQuality'.tr(),
            hideLeading: true,
          ),
        ),
      ),
    );
  }

  Future<Tuple2<bool, SonarrEpisodeFileLanguage?>> selectLanguage(
    BuildContext context,
  ) async {
    bool result = false;
    SonarrEpisodeFileLanguage? selected;

    final profiles = await context.read<SonarrState>().languageProfiles!;
    final firstProfile = profiles.isNotEmpty ? profiles.first : null;
    final items = firstProfile?.languages ?? const <SonarrLanguageProfileItem>[];

    final languages = items
        .where((i) => i.language != null)
        .map(
          (i) => SonarrEpisodeFileLanguage(
            id: i.language!.id,
            name: i.language!.name,
          ),
        )
        .toList()
      ..sort(
        (a, b) => (a.name ?? '').toLowerCase().compareTo((b.name ?? '').toLowerCase()),
      );

    await ZagBottomModalSheet().show(
      builder: (_) => ZagListViewModalBuilder(
        itemCount: languages.isEmpty ? 1 : languages.length,
        itemBuilder: (context, index) {
          if (languages.isEmpty) {
            return ZagMessage.inList(text: 'sonarr.NoResultsFound'.tr());
          }
          final language = languages[index];
          return ZagBlock(
            title: language.name ?? ZagUI.TEXT_EMDASH,
            onTap: () {
              result = true;
              selected = language;
              Navigator.of(context).pop();
            },
          );
        },
        appBar: ZagAppBar(
          title: 'sonarr.SelectLanguage'.tr(),
          hideLeading: true,
        ),
      ),
    );

    return Tuple2(result, selected);
  }

  Future<Tuple2<bool, SonarrEpisode?>> selectEpisode(
    BuildContext context, {
    required int seriesId,
  }) async {
    bool result = false;
    SonarrEpisode? selected;

    await ZagBottomModalSheet().show(
      builder: (sheetContext) => FutureBuilder(
        future: sheetContext.read<SonarrState>().api!.episode.getMulti(
              seriesId: seriesId,
            ),
        builder: (context, AsyncSnapshot<List<SonarrEpisode>> snapshot) {
          if (snapshot.hasError) {
            if (snapshot.connectionState != ConnectionState.waiting) {
              ZagLogger().error(
                'Unable to fetch Sonarr episodes for series: $seriesId',
                snapshot.error,
                snapshot.stackTrace,
              );
            }
            return ZagMessage(text: 'zagreus.AnErrorHasOccurred'.tr());
          }

          if (snapshot.hasData) {
            final episodes = [...snapshot.data!]
              ..sort((a, b) {
                final aSeason = a.seasonNumber ?? 0;
                final bSeason = b.seasonNumber ?? 0;
                if (aSeason != bSeason) return aSeason.compareTo(bSeason);
                final aNumber = a.episodeNumber ?? 0;
                final bNumber = b.episodeNumber ?? 0;
                return aNumber.compareTo(bNumber);
              });

            if (episodes.isEmpty) {
              return ZagMessage(text: 'sonarr.NoEpisodesFound'.tr());
            }

            return ZagListViewModalBuilder(
              itemCount: episodes.length,
              itemBuilder: (context, index) {
                final episode = episodes[index];
                final season =
                    (episode.seasonNumber ?? 0).toString().padLeft(2, '0');
                final number =
                    (episode.episodeNumber ?? 0).toString().padLeft(2, '0');
                final title = episode.title ?? ZagUI.TEXT_EMDASH;

                return ZagBlock(
                  title: 'S$season' 'E$number',
                  body: [TextSpan(text: title)],
                  onTap: () {
                    result = true;
                    selected = episode;
                    Navigator.of(context).pop();
                  },
                );
              },
              appBar: ZagAppBar(
                title: 'sonarr.SelectEpisode'.tr(),
                hideLeading: true,
              ),
            );
          }
          return const ZagLoader();
        },
      ),
    );

    return Tuple2(result, selected);
  }

  Future<Tuple2<bool, SonarrSeries?>> selectSeries(BuildContext context) async {
    bool result = false;
    SonarrSeries? series;
    context
        .read<SonarrManualImportDetailsTileState>()
        .configureSeriesSearchQuery = '';

    List<SonarrSeries> _sortAndFilter(List<SonarrSeries> allSeries, String query) {
      List<SonarrSeries> _filtered = allSeries
        ..sort((a, b) =>
            (a.sortTitle ?? '').toLowerCase().compareTo((b.sortTitle ?? '').toLowerCase()));
      if (query.isNotEmpty) {
        _filtered = _filtered
            .where((s) => (s.title ?? '').toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
      return _filtered;
    }

    await ZagBottomModalSheet().show(
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<SonarrManualImportDetailsTileState>(),
        builder: (context, _) => FutureBuilder(
          future: context.watch<SonarrState>().series,
          builder: (context, AsyncSnapshot<Map<int, SonarrSeries>> snapshot) {
            if (snapshot.hasError) {
              if (snapshot.connectionState != ConnectionState.waiting)
                ZagLogger().error(
                  'Unable to fetch Sonarr series',
                  snapshot.error,
                  snapshot.stackTrace,
                );
              return ZagMessage(text: 'zagreus.AnErrorHasOccurred'.tr());
            }
            if (snapshot.hasData) {
              if ((snapshot.data?.length ?? 0) == 0)
                return ZagMessage(text: 'sonarr.NoSeriesFound'.tr());
              String _query = context
                  .watch<SonarrManualImportDetailsTileState>()
                  .configureSeriesSearchQuery;
              List<SonarrSeries> seriesList = _sortAndFilter(snapshot.data!.values.toList(), _query);
              return ZagListViewModalBuilder(
                itemCount: seriesList.isEmpty ? 1 : seriesList.length,
                itemBuilder: (context, index) {
                  if (seriesList.isEmpty) {
                    return ZagMessage.inList(
                      text: 'sonarr.NoSeriesFound'.tr(),
                    );
                  }
                  String title = seriesList[index].title ?? ZagUI.TEXT_EMDASH;
                  String? overview = seriesList[index].overview;
                  if (overview?.isEmpty ?? true)
                    overview = 'sonarr.NoSummaryIsAvailable'.tr();
                  return ZagBlock(
                    title: title,
                    body: [
                      TextSpan(
                        text: overview,
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    onTap: () {
                      result = true;
                      series = seriesList[index];
                      Navigator.of(context).pop();
                    },
                  );
                },
                appBar: ZagAppBar(
                  title: 'sonarr.SelectSeries'.tr(),
                  bottom:
                      SonarrManualImportDetailsConfigureSeriesSearchBar(),
                  hideLeading: true,
                ),
                appBarHeight: ZagAppBar.APPBAR_HEIGHT +
                    ZagTextInputBar.defaultAppBarHeight,
              );
            }
            return const ZagLoader();
          },
        ),
      ),
    );
    return Tuple2(result, series);
  }
}
