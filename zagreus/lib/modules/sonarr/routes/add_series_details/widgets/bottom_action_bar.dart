import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/router/router.dart';
import 'package:zagreus/router/routes/sonarr.dart';

class SonarrAddSeriesDetailsActionBar extends StatelessWidget {
  const SonarrAddSeriesDetailsActionBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagBottomActionBar(
      actions: [
        ZagActionBarCard(
          title: 'zagreus.Options'.tr(),
          subtitle: 'Language & Tags',
          onTap: () async => SonarrDialogs().addSeriesOptions(context),
        ),
        ZagButton(
          type: ZagButtonType.TEXT,
          text: 'zagreus.Add'.tr(),
          icon: Icons.add_rounded,
          onTap: () async => _onTap(context),
          loadingState: context.watch<SonarrSeriesAddDetailsState>().state,
        ),
      ],
    );
  }

  Future<void> _onTap(BuildContext context) async {
    if (context.read<SonarrSeriesAddDetailsState>().canExecuteAction) {
      context.read<SonarrSeriesAddDetailsState>().state =
          ZagLoadingState.ACTIVE;
      SonarrSeriesAddDetailsState _state =
          context.read<SonarrSeriesAddDetailsState>();
      await SonarrAPIController()
          .addSeries(
        context: context,
        series: _state.series,
        qualityProfile: _state.qualityProfile,
        languageProfile: _state.languageProfile,
        rootFolder: _state.rootFolder,
        seasonFolder: _state.useSeasonFolders,
        tags: _state.tags,
        seriesType: _state.seriesType,
        monitorType: _state.monitorType,
      )
          .then((series) async {
        context.read<SonarrState>().fetchAllSeries();
        context.read<SonarrSeriesAddDetailsState>().series.id = series!.id;

        ZagRouter.router.pop();
        SonarrRoutes.SERIES.go(params: {
          'series': series.id!.toString(),
        });
      }).catchError((error, stack) {
        context.read<SonarrSeriesAddDetailsState>().state =
            ZagLoadingState.ERROR;
      });
      context.read<SonarrSeriesAddDetailsState>().state =
          ZagLoadingState.INACTIVE;
    }
  }
}
