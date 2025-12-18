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
                if (result.item1 && result.item2 != null) {
                  // Get episode IDs from current manual import
                  List<int> episodeIds = [];
                  final manualImport = context
                      .read<SonarrManualImportDetailsTileState>()
                      .manualImport;
                  if (manualImport.episodes != null) {
                    episodeIds = manualImport.episodes!
                        .where((e) => e.id != null)
                        .map((e) => e.id!)
                        .toList();
                  }
                  context
                      .read<SonarrManualImportDetailsTileState>()
                      .fetchUpdates(context, result.item2!.id, episodeIds);
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
                // TODO: Implement language selection
                showZagInfoSnackBar(
                  title: 'Not Implemented',
                  message: 'Language selection coming soon',
                );
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
