import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/int/bytes.dart';
import 'package:zagreus/modules/sonarr.dart';

extension ZagSonarrManualImportExtension on SonarrManualImport {
  String? get zagLanguage {
    if ((this.languages?.length ?? 0) > 1) return 'Multi-Language';
    if ((this.languages?.length ?? 0) == 1) return this.languages![0].name;
    return ZagUI.TEXT_EMDASH;
  }

  String get zagQualityProfile {
    return this.quality?.quality?.name ?? ZagUI.TEXT_EMDASH;
  }

  String get zagSize {
    return this.size.asBytes();
  }

  String get zagSeriesAndEpisodes {
    if (this.series == null) return ZagUI.TEXT_EMDASH;

    String seriesTitle = this.series!.title ?? ZagUI.TEXT_EMDASH;

    // Build episode info
    List<SonarrEpisode> allEpisodes = [];
    if (this.episode != null) allEpisodes.add(this.episode!);
    if (this.episodes != null) allEpisodes.addAll(this.episodes!);

    if (allEpisodes.isEmpty) return seriesTitle;

    // Format episodes (e.g., "S01E01-E03" or "S01E01")
    String episodeInfo = allEpisodes.map((ep) {
      String season = (ep.seasonNumber ?? 0).toString().padLeft(2, '0');
      String episode = (ep.episodeNumber ?? 0).toString().padLeft(2, '0');
      return 'S${season}E${episode}';
    }).join(', ');

    return '$seriesTitle - $episodeInfo';
  }
}
