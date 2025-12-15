import 'package:flutter/material.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/vendor.dart';
import 'package:zagreus/widgets/ui.dart';

enum SonarrEpisodeMultiSettingsType {
  AUTOMATIC_SEARCH,
  DELETE_FILES;

  IconData get icon {
    switch (this) {
      case SonarrEpisodeMultiSettingsType.AUTOMATIC_SEARCH:
        return ZagIcons.SEARCH;
      case SonarrEpisodeMultiSettingsType.DELETE_FILES:
        return ZagIcons.DELETE;
    }
  }

  String get name {
    switch (this) {
      case SonarrEpisodeMultiSettingsType.AUTOMATIC_SEARCH:
        return 'sonarr.AutomaticSearch'.tr();
      case SonarrEpisodeMultiSettingsType.DELETE_FILES:
        return 'sonarr.DeleteFiles'.tr();
    }
  }

  Future<void> execute(
    BuildContext context,
    List<SonarrEpisode> episodes,
  ) async {
    switch (this) {
      case SonarrEpisodeMultiSettingsType.AUTOMATIC_SEARCH:
        final episodeIds = episodes.map((ep) => ep.id!).toList();
        await SonarrAPIController().multiEpisodeSearch(
          context: context,
          episodeIds: episodeIds,
        );
        break;
      case SonarrEpisodeMultiSettingsType.DELETE_FILES:
        final episodeIds = episodes
            .filter((ep) => ep.episodeFileId != null && ep.episodeFileId != 0)
            .map((ep) => ep.episodeFileId!)
            .toSet()
            .toList();
        await SonarrAPIController().deleteEpisodes(
          context: context,
          episodeFileIds: episodeIds,
        );
        break;
    }

    context.read<SonarrSeasonDetailsState>().fetchState(context);
  }
}
