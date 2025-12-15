import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/widgets/pages/invalid_route.dart';

class SeriesEditRoute extends StatefulWidget {
  final int seriesId;

  const SeriesEditRoute({
    Key? key,
    required this.seriesId,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<SeriesEditRoute>
    with ZagLoadCallbackMixin, ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Future<void> loadCallback() async {
    context.read<SonarrState>().fetchTags();
    context.read<SonarrState>().fetchQualityProfiles();
    context.read<SonarrState>().fetchLanguageProfiles();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.seriesId <= 0)
      return InvalidRoutePage(
        title: 'sonarr.EditSeries'.tr(),
        message: 'sonarr.SeriesNotFound'.tr(),
      );
    return ChangeNotifierProvider(
        create: (_) => SonarrSeriesEditState(),
        builder: (context, _) {
          ZagLoadingState state =
              context.select<SonarrSeriesEditState, ZagLoadingState>(
                  (state) => state.state);
          return ZagScaffold(
            scaffoldKey: _scaffoldKey,
            appBar: _appBar() as PreferredSizeWidget?,
            body:
                state == ZagLoadingState.ERROR ? _bodyError() : _body(context),
            bottomNavigationBar: state == ZagLoadingState.ERROR
                ? null
                : const SonarrEditSeriesActionBar(),
          );
        });
  }

  Widget _appBar() {
    return ZagAppBar(
      scrollControllers: [scrollController],
      title: 'sonarr.EditSeries'.tr(),
    );
  }

  Widget _bodyError() {
    return ZagMessage.goBack(
      context: context,
      text: 'zagreus.AnErrorHasOccurred'.tr(),
    );
  }

  Widget _body(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        context.select<SonarrState, Future<Map<int?, SonarrSeries>>?>(
            (state) => state.series)!,
        context.select<SonarrState, Future<List<SonarrQualityProfile>>?>(
            (state) => state.qualityProfiles)!,
        context.select<SonarrState, Future<List<SonarrTag>>?>(
            (state) => state.tags)!,
        context.select<SonarrState, Future<List<SonarrLanguageProfile>>?>(
            (state) => state.languageProfiles)!,
      ]),
      builder: (context, AsyncSnapshot<List<Object>> snapshot) {
        if (snapshot.hasError) {
          return ZagMessage.error(onTap: loadCallback);
        }
        if (snapshot.hasData) {
          SonarrSeries? series = (snapshot.data![0] as Map)[widget.seriesId];
          if (series == null) return const ZagLoader();
          return _list(
            context,
            series: series,
            qualityProfiles: snapshot.data![1] as List<SonarrQualityProfile>,
            tags: snapshot.data![2] as List<SonarrTag>,
            languageProfiles: snapshot.data![3] as List<SonarrLanguageProfile>,
          );
        }
        return const ZagLoader();
      },
    );
  }

  Widget _list(
    BuildContext context, {
    required SonarrSeries series,
    required List<SonarrQualityProfile> qualityProfiles,
    required List<SonarrLanguageProfile> languageProfiles,
    required List<SonarrTag> tags,
  }) {
    if (context.read<SonarrSeriesEditState>().series == null) {
      context.read<SonarrSeriesEditState>().series = series;
      context
          .read<SonarrSeriesEditState>()
          .initializeQualityProfile(qualityProfiles);
      context
          .read<SonarrSeriesEditState>()
          .initializeLanguageProfile(languageProfiles);
      context.read<SonarrSeriesEditState>().initializeTags(tags);
      context.read<SonarrSeriesEditState>().canExecuteAction = true;
    }
    return ZagListView(
      controller: scrollController,
      children: [
        const SonarrSeriesEditMonitoredTile(),
        const SonarrSeriesEditSeasonFoldersTile(),
        SonarrSeriesEditQualityProfileTile(profiles: qualityProfiles),
        if (languageProfiles.isNotEmpty)
          SonarrSeriesEditLanguageProfileTile(profiles: languageProfiles),
        const SonarrSeriesEditSeriesTypeTile(),
        const SonarrSeriesEditSeriesPathTile(),
        const SonarrSeriesEditTagsTile(),
      ],
    );
  }
}
