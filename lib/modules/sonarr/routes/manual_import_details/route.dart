import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/widgets/pages/invalid_route.dart';

class SonarrManualImportDetailsRoute extends StatefulWidget {
  final String? path;
  final String? seriesId;
  final String? episodeId;

  const SonarrManualImportDetailsRoute({
    Key? key,
    required this.path,
    this.seriesId,
    this.episodeId,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<SonarrManualImportDetailsRoute>
    with ZagScrollControllerMixin, ZagLoadCallbackMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Future<void> loadCallback() async {
    context.read<SonarrState>().fetchAllSeries();
    context.read<SonarrState>().fetchQualityProfiles();
    context.read<SonarrState>().fetchLanguageProfiles();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.path?.isEmpty ?? true) {
      return InvalidRoutePage(
        title: 'sonarr.ManualImport'.tr(),
        message: 'sonarr.DirectoryNotFound'.tr(),
      );
    }
    return ChangeNotifierProvider(
      create: (BuildContext context) => SonarrManualImportDetailsState(
        context,
        path: widget.path!,
        hintSeriesId: widget.seriesId != null ? int.tryParse(widget.seriesId!) : null,
        hintEpisodeId: widget.episodeId != null ? int.tryParse(widget.episodeId!) : null,
      ),
      builder: (context, _) {
        return ZagScaffold(
          scaffoldKey: _scaffoldKey,
          appBar: _appBar(),
          body: _body(context),
          bottomNavigationBar: const SonarrManualImportDetailsBottomActionBar(),
        );
      },
    );
  }

  PreferredSizeWidget _appBar() {
    return ZagAppBar(
      title: 'sonarr.ManualImport'.tr(),
      scrollControllers: [scrollController],
    );
  }

  Widget _body(BuildContext context) {
    return FutureBuilder(
      future: Future.wait(
        [
          context.select(
              (SonarrManualImportDetailsState state) => state.manualImport!),
          context.select((SonarrState state) => state.qualityProfiles!),
          context.select((SonarrState state) => state.languageProfiles!),
        ],
      ),
      builder: (context, AsyncSnapshot<List<Object>> snapshot) {
        if (snapshot.hasError) {
          if (snapshot.connectionState != ConnectionState.waiting) {
            ZagLogger().error(
              'Unable to fetch Sonarr manual import: ${context.read<SonarrManualImportDetailsState>().path}',
              snapshot.error,
              snapshot.stackTrace,
            );
          }
          return ZagMessage.error(
            onTap: () => context
                .read<SonarrManualImportDetailsState>()
                .fetchManualImport(context),
          );
        }
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return _list(
            context,
            manualImport: snapshot.data![0] as List<SonarrManualImport>,
          );
        }
        return const ZagLoader();
      },
    );
  }

  Widget _list(
    BuildContext context, {
    required List<SonarrManualImport> manualImport,
  }) {
    if (manualImport.isEmpty) {
      return ZagMessage(
        text: 'sonarr.NoFilesFound'.tr(),
        buttonText: 'zagreus.Refresh'.tr(),
        onTap: () => context
            .read<SonarrManualImportDetailsState>()
            .fetchManualImport(context),
      );
    }
    context.read<SonarrManualImportDetailsState>().canExecuteAction = true;
    return ZagListViewBuilder(
      controller: scrollController,
      itemCount: manualImport.length,
      itemBuilder: (context, index) => SonarrManualImportDetailsTile(
        key: ObjectKey(manualImport[index].id),
        manualImport: manualImport[index],
      ),
    );
  }
}
