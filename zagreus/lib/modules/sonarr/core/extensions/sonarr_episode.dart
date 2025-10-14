import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/int/bytes.dart';
import 'package:zagreus/modules/sonarr.dart';

extension SonarrEpisodeExtension on SonarrEpisode {
  bool _hasAired() {
    return this.airDateUtc?.toLocal().isAfter(DateTime.now()) ?? true;
  }

  /// Creates a clone of the [SonarrEpisode] object (deep copy).
  SonarrEpisode clone() => SonarrEpisode.fromJson(this.toJson());

  String zagAirDate() {
    if (this.airDateUtc == null) return 'zagreus.UnknownDate'.tr();
    return DateFormat.yMMMMd().format(this.airDateUtc!.toLocal());
  }

  String zagDownloadedQuality(
    SonarrEpisodeFile? file,
    SonarrQueueRecord? queueRecord,
  ) {
    if (queueRecord != null) {
      return [
        queueRecord.zagPercentage(),
        ZagUI.TEXT_EMDASH,
        queueRecord.zagStatusParameters().item1,
      ].join(' ');
    }

    if (!this.hasFile!) {
      if (_hasAired()) return 'sonarr.Unaired'.tr();
      return 'sonarr.Missing'.tr();
    }
    if (file == null) return 'zagreus.Unknown'.tr();
    String quality = file.quality?.quality?.name ?? 'zagreus.Unknown'.tr();
    String size = file.size?.asBytes() ?? '0.00 B';
    return '$quality ${ZagUI.TEXT_EMDASH} $size';
  }

  Color zagDownloadedQualityColor(
    SonarrEpisodeFile? file,
    SonarrQueueRecord? queueRecord,
  ) {
    if (queueRecord != null) {
      return queueRecord.zagStatusParameters(canBeWhite: false).item3;
    }

    if (!this.hasFile!) {
      if (_hasAired()) return ZagColours.blue;
      return ZagColours.red;
    }
    if (file == null) return ZagColours.blueGrey;
    if (file.qualityCutoffNotMet!) return ZagColours.orange;
    return ZagColours.currentAccent;
  }

  String zagSeasonEpisode() {
    String season = this.seasonNumber != null
        ? 'sonarr.SeasonNumber'.tr(
            args: [this.seasonNumber.toString()],
          )
        : 'zagreus.Unknown'.tr();
    String episode = this.episodeNumber != null
        ? 'sonarr.EpisodeNumber'.tr(
            args: [this.episodeNumber.toString()],
          )
        : 'zagreus.Unknown'.tr();
    return '$season ${ZagUI.TEXT_BULLET} $episode';
  }
}
