import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/string/string.dart';
import 'package:zagreus/modules/sonarr.dart';

class SonarrManualImportDetailsTile extends StatelessWidget {
  final SonarrManualImport manualImport;

  const SonarrManualImportDetailsTile({
    Key? key,
    required this.manualImport,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SonarrManualImportDetailsTileState(context, manualImport),
      builder: (context, _) => ZagExpandableListTile(
        key: ObjectKey(manualImport),
        title: context
            .watch<SonarrManualImportDetailsTileState>()
            .manualImport
            .relativePath!,
        collapsedTrailing: _trailing(context),
        collapsedSubtitles: [
          _subtitle1(context),
          _subtitle2(context),
        ],
        expandedTableButtons: _buttons(context),
        expandedTableContent: _table(context),
        backgroundColor: context
                .watch<SonarrManualImportDetailsState>()
                .selectedFiles
                .contains(manualImport.id)
            ? ZagColours.currentAccent.withOpacity(ZagUI.OPACITY_SPLASH)
            : null,
      ),
    );
  }

  TextSpan _subtitle1(BuildContext context) {
    return TextSpan(
      children: [
        TextSpan(
            text: context
                .watch<SonarrManualImportDetailsTileState>()
                .manualImport
                .zagQualityProfile),
        TextSpan(text: ZagUI.TEXT_BULLET.pad()),
        TextSpan(
            text: context
                .watch<SonarrManualImportDetailsTileState>()
                .manualImport
                .zagLanguage),
        TextSpan(text: ZagUI.TEXT_BULLET.pad()),
        TextSpan(
            text: context
                .watch<SonarrManualImportDetailsTileState>()
                .manualImport
                .zagSize),
      ],
    );
  }

  TextSpan _subtitle2(BuildContext context) {
    return TextSpan(
      text: context
          .watch<SonarrManualImportDetailsTileState>()
          .manualImport
          .zagSeriesAndEpisodes,
      style: TextStyle(
        fontWeight: ZagUI.FONT_WEIGHT_BOLD,
        color: ZagColours.currentAccent,
      ),
    );
  }

  Widget _trailing(BuildContext context) {
    return Consumer<SonarrManualImportDetailsState>(
      builder: (context, state, _) => Checkbox(
        value: state.selectedFiles.contains(manualImport.id),
        onChanged: (value) => state.setSelectedFile(manualImport.id!, value!),
      ),
    );
  }

  List<ZagTableContent> _table(BuildContext context) {
    return [
      ZagTableContent(
        title: 'sonarr.Series'.tr(),
        body: context
            .watch<SonarrManualImportDetailsTileState>()
            .manualImport
            .zagSeriesAndEpisodes,
      ),
      ZagTableContent(
        title: 'sonarr.Quality'.tr(),
        body: context
            .watch<SonarrManualImportDetailsTileState>()
            .manualImport
            .zagQualityProfile,
      ),
      ZagTableContent(
        title: 'sonarr.Languages'.tr(),
        body: context
            .watch<SonarrManualImportDetailsTileState>()
            .manualImport
            .zagLanguage,
      ),
      ZagTableContent(
        title: 'sonarr.Size'.tr(),
        body: context
            .watch<SonarrManualImportDetailsTileState>()
            .manualImport
            .zagSize,
      ),
    ];
  }

  List<ZagButton> _buttons(BuildContext context) {
    return [
      _configureButton(context),
      if ((context
                  .read<SonarrManualImportDetailsTileState>()
                  .manualImport
                  .rejections
                  ?.length ??
              0) >
          0)
        _rejectionsButton(context),
    ];
  }

  ZagButton _configureButton(BuildContext context) {
    return ZagButton.text(
        text: 'sonarr.Configure'.tr(),
        icon: Icons.edit_rounded,
        onTap: () async {
          await SonarrBottomModalSheets().configureManualImport(context);
          if (!context.mounted) return;
          context
              .read<SonarrManualImportDetailsTileState>()
              .checkIfShouldSelect(context);
        });
  }

  ZagButton _rejectionsButton(BuildContext context) {
    return ZagButton.text(
      text: 'sonarr.Rejected'.tr(),
      icon: Icons.report_outlined,
      color: ZagColours.red,
      onTap: () async => ZagDialogs().showRejections(
        context,
        context
                .read<SonarrManualImportDetailsTileState>()
                .manualImport
                .rejections
                ?.map<String>((rejection) => rejection.reason!)
                .toList() ??
            [],
      ),
    );
  }
}

class SonarrManualImportDetailsTileState extends ChangeNotifier {
  SonarrManualImportDetailsTileState(BuildContext context, this._manualImport) {
    checkIfShouldSelect(context);
  }

  String _configureSeriesSearchQuery = '';
  String get configureSeriesSearchQuery => _configureSeriesSearchQuery;
  set configureSeriesSearchQuery(String configureSeriesSearchQuery) {
    _configureSeriesSearchQuery = configureSeriesSearchQuery;
    notifyListeners();
  }

  SonarrManualImport _manualImport;
  SonarrManualImport get manualImport => _manualImport;
  set manualImport(SonarrManualImport manualImport) {
    _manualImport = manualImport;
    notifyListeners();
  }

  void addLanguage(SonarrEpisodeFileLanguage language) {
    if ((_manualImport.languages ?? [])
            .indexWhere((lang) => lang.id == language.id) >=
        0) return;
    _manualImport.languages!.add(language);
    notifyListeners();
  }

  void removeLanguage(SonarrEpisodeFileLanguage language) {
    int index = (_manualImport.languages ?? [])
        .indexWhere((lang) => lang.id == language.id);
    if (index == -1) return;
    _manualImport.languages!.removeAt(index);
    notifyListeners();
  }

  void setLanguage(SonarrEpisodeFileLanguage language) {
    _manualImport.languages = [language];
    notifyListeners();
  }

  void checkIfShouldSelect(BuildContext context) {
    if (!context.mounted) return;
    if (_manualImport.series != null &&
        ((_manualImport.episode != null) ||
            (_manualImport.episodes?.isNotEmpty ?? false)) &&
        _manualImport.quality != null &&
        (_manualImport.languages?.length ?? 0) > 0 &&
        _manualImport.languages![0].id! >= 0)
      Future.microtask(() => context
          .read<SonarrManualImportDetailsState>()
          .addSelectedFile(_manualImport.id!));
  }

  void setSeries(SonarrSeries series) {
    final updated = _manualImport;
    updated.series = series;
    updated.episode = null;
    updated.episodes = null;
    manualImport = updated;
  }

  void setEpisode(SonarrEpisode episode) {
    final updated = _manualImport;
    updated.episode = episode;
    updated.episodes = null;
    manualImport = updated;
  }

  Future<bool> fetchUpdates(
    BuildContext context,
    int? seriesId,
    List<int>? episodeIds,
  ) async {
    if (!context.mounted) return false;

    final sonarrState = context.read<SonarrState>();
    if (sonarrState.enabled) {
      final safeEpisodeIds = (episodeIds?.isNotEmpty ?? false) ? episodeIds : null;
      SonarrManualImportUpdateData data = SonarrManualImportUpdateData(
        id: manualImport.id,
        path: manualImport.path,
        seriesId: seriesId,
        episodeIds: safeEpisodeIds,
        quality: manualImport.quality,
        languages: manualImport.languages,
        releaseGroup: manualImport.releaseGroup,
        downloadId: manualImport.downloadId,
      );
      try {
        final value =
            await sonarrState.api!.manualImport.update(
                  data: [data],
                );
        if (value.isNotEmpty) {
          SonarrManualImport updated = _manualImport;
          updated.series = value[0].series ?? updated.series;
          updated.episodes = value[0].episodes ?? updated.episodes;
          updated.id = value[0].id ?? updated.id;
          updated.path = value[0].path ?? updated.path;
          updated.rejections = value[0].rejections;
          manualImport = updated;
        }
        return true;
      } catch (e, stack) {
        ZagLogger().warning(
          'Failed to update manual import selection: ${e.toString()}',
        );
        ZagLogger()
            .debug('Manual import update stacktrace: ${stack.toString()}');
        return false;
      }
    }
    return false;
  }

  void updateQuality(SonarrEpisodeFileQualityQuality quality) {
    _manualImport.quality ??= SonarrEpisodeFileQuality(
      quality: quality,
      revision: SonarrEpisodeFileQualityRevision(
        version: 1,
        real: 0,
        isRepack: false,
      ),
    );
    _manualImport.quality!.quality = quality;
    notifyListeners();
  }
}
