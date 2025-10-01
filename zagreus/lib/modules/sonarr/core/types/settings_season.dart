import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/router/routes/sonarr.dart';

enum SonarrSeasonSettingsType {
  AUTOMATIC_SEARCH,
  INTERACTIVE_SEARCH,
  SEASON_CLEANUP,
}

extension SonarrSeasonSettingsTypeExtension on SonarrSeasonSettingsType {
  IconData get icon {
    switch (this) {
      case SonarrSeasonSettingsType.AUTOMATIC_SEARCH:
        return Icons.search_rounded;
      case SonarrSeasonSettingsType.INTERACTIVE_SEARCH:
        return Icons.youtube_searched_for_rounded;
      case SonarrSeasonSettingsType.SEASON_CLEANUP:
        return Icons.cleaning_services_rounded;
    }
  }

  String get name {
    switch (this) {
      case SonarrSeasonSettingsType.AUTOMATIC_SEARCH:
        return 'sonarr.AutomaticSearch'.tr();
      case SonarrSeasonSettingsType.INTERACTIVE_SEARCH:
        return 'sonarr.InteractiveSearch'.tr();
      case SonarrSeasonSettingsType.SEASON_CLEANUP:
        return 'Season Cleanup';
    }
  }

  Future<void> execute(
    BuildContext context,
    int? seriesId,
    int? seasonNumber,
  ) async {
    switch (this) {
      case SonarrSeasonSettingsType.AUTOMATIC_SEARCH:
        await SonarrAPIController().automaticSeasonSearch(
          context: context,
          seriesId: seriesId,
          seasonNumber: seasonNumber,
        );
        return;
      case SonarrSeasonSettingsType.INTERACTIVE_SEARCH:
        return SonarrRoutes.RELEASES.go(queryParams: {
          'series': seriesId.toString(),
          'season': seasonNumber.toString(),
        });
      case SonarrSeasonSettingsType.SEASON_CLEANUP:
        // Show confirmation dialog
        bool confirmed = false;
        await ZagDialog.dialog(
          context: context,
          title: seasonNumber == 0 ? 'Specials Cleanup' : 'Season $seasonNumber Cleanup',
          buttons: [
            ZagDialog.button(
              text: 'YES',
              textColor: ZagColours.red,
              onPressed: () {
                confirmed = true;
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
          ],
          content: [
            ZagDialog.textContent(
              text: 'This action will both unmonitor and delete all episode files for this season. Are you sure you want to do this?',
            ),
          ],
          contentPadding: ZagDialog.textDialogContentPadding(),
        );

        if (!confirmed) return;

        // Get the season object from state
        final sonarrState = context.read<SonarrState>();
        final series = await sonarrState.series!.then((allSeries) => allSeries[seriesId]);

        if (series == null) return;

        final season = series.seasons?.firstWhere(
          (s) => s.seasonNumber == seasonNumber,
        );

        if (season == null) return;

        // Perform cleanup
        await SonarrAPIController().seasonCleanup(
          context: context,
          season: season,
          seriesId: seriesId,
        );
        return;
    }
  }
}
