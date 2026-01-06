import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/router/router.dart';
import 'package:zagreus/api/bazarr/bazarr.dart';
import 'package:zagreus/utils/zagreus_pro.dart';

class SonarrEditSeriesActionBar extends StatelessWidget {
  const SonarrEditSeriesActionBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagBottomActionBar(
      actions: [
        ZagButton(
          type: ZagButtonType.TEXT,
          text: 'zagreus.Update'.tr(),
          icon: Icons.edit_rounded,
          loadingState: context.watch<SonarrSeriesEditState>().state,
          onTap: () async => _updateOnTap(context),
        ),
      ],
    );
  }

  BazarrAPI? _getBazarrApi() {
    if (!ZagreusPro.isEnabled) return null;
    final profile = ZagProfile.current;
    if (!profile.bazarrEnabled) return null;
    final host = profile.effectiveBazarrHost();
    if (host.isEmpty || profile.bazarrKey.isEmpty) return null;
    return BazarrAPI(
      host: host,
      apiKey: profile.bazarrKey,
      headers: Map<String, dynamic>.from(profile.bazarrHeaders),
    );
  }

  Future<void> _updateOnTap(BuildContext context) async {
    final state = context.read<SonarrSeriesEditState>();
    if (state.canExecuteAction) {
      state.state = ZagLoadingState.ACTIVE;
      if (state.series != null) {
        SonarrSeries series = state.series!.updateEdits(state);
        bool result = await SonarrAPIController().updateSeries(
          context: context,
          series: series,
          moveFiles: state.moveFiles,
        );

        // Update Bazarr language profile if changed
        if (result && state.bazarrProfileChanged) {
          final bazarrApi = _getBazarrApi();
          if (bazarrApi != null) {
            try {
              await bazarrApi.series.updateLanguageProfile(
                seriesId: series.id!,
                profileId: state.bazarrLanguageProfile?.profileId,
              );
            } catch (e, stack) {
              ZagLogger().error('Failed to update Bazarr language profile', e, stack);
              showZagErrorSnackBar(
                title: 'bazarr.FailedToUpdateProfile'.tr(),
                message: e.toString(),
              );
            }
          }
        }

        if (result) ZagRouter().popSafely();
      }
    }
  }
}
