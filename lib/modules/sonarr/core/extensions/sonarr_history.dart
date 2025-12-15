import 'package:zagreus/core.dart';
import 'package:zagreus/modules/sonarr.dart';

extension SonarrHistoryRecordZagExtension on SonarrHistoryRecord {
  String zagSeriesTitle() {
    return this.series?.title ?? ZagUI.TEXT_EMDASH;
  }

  String? zagSeasonEpisode() {
    if (this.episode == null) return null;
    String season = this.episode?.seasonNumber != null
        ? 'sonarr.SeasonNumber'.tr(
            args: [this.episode!.seasonNumber.toString()],
          )
        : 'zagreus.Unknown'.tr();
    String episode = this.episode?.episodeNumber != null
        ? 'sonarr.EpisodeNumber'.tr(
            args: [this.episode!.episodeNumber.toString()],
          )
        : 'zagreus.Unknown'.tr();
    return '$season ${ZagUI.TEXT_BULLET} $episode';
  }

  bool zagHasPreferredWordScore() {
    return (this.data!['preferredWordScore'] ?? '0') != '0';
  }

  String zagPreferredWordScore() {
    if (zagHasPreferredWordScore()) {
      int? _preferredScore = int.tryParse(this.data!['preferredWordScore']);
      if (_preferredScore != null) {
        String _prefix = _preferredScore > 0 ? '+' : '';
        return '$_prefix${this.data!['preferredWordScore']}';
      }
    }
    return ZagUI.TEXT_EMDASH;
  }
}
