import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/datetime.dart';
import 'package:zagreus/extensions/int/bytes.dart';
import 'package:zagreus/extensions/int/duration.dart';
import 'package:zagreus/extensions/string/string.dart';
import 'package:zagreus/modules/sonarr.dart';

extension SonarrSeriesExtension on SonarrSeries {
  String get zagRuntime {
    return this.runtime.asVideoDuration();
  }

  String get zagAlternateTitles {
    if (this.alternateTitles?.isNotEmpty ?? false) {
      return this.alternateTitles!.map((title) => title.title).join('\n');
    }
    return ZagUI.TEXT_EMDASH;
  }

  String get zagGenres {
    if (this.genres?.isNotEmpty ?? false) return this.genres!.join('\n');
    return ZagUI.TEXT_EMDASH;
  }

  String get zagNetwork {
    if (this.network?.isNotEmpty ?? false) return this.network!;
    return ZagUI.TEXT_EMDASH;
  }

  String zagTags(List<SonarrTag> tags) {
    if (tags.isNotEmpty) return tags.map<String>((t) => t.label!).join('\n');
    return ZagUI.TEXT_EMDASH;
  }

  int get zagPercentageComplete {
    int _total = this.statistics?.episodeCount ?? 0;
    int _available = this.statistics?.episodeFileCount ?? 0;
    return _total == 0 ? 0 : ((_available / _total) * 100).round();
  }

  String zagNextAiring([bool short = false]) {
    if (this.status == 'ended') return 'sonarr.SeriesEnded'.tr();
    if (this.nextAiring == null) return 'zagreus.Unknown'.tr();
    return this.nextAiring!.asDateTime(
          showSeconds: false,
          delimiter: '@'.pad(),
          shortenMonth: short,
        );
  }

  String zagPreviousAiring([bool short = false]) {
    if (this.previousAiring == null) return ZagUI.TEXT_EMDASH;
    return this.previousAiring!.asDateTime(
          showSeconds: false,
          delimiter: '@'.pad(),
          shortenMonth: short,
        );
  }

  String get zagDateAdded {
    if (this.added == null) {
      return 'zagreus.Unknown'.tr();
    }
    return DateFormat('MMMM dd, y').format(this.added!.toLocal());
  }

  String get zagDateAddedShort {
    if (this.added == null) {
      return 'zagreus.Unknown'.tr();
    }
    return DateFormat('MMM dd, y').format(this.added!.toLocal());
  }

  String get zagYear {
    if (this.year != null && this.year != 0) return this.year.toString();
    return ZagUI.TEXT_EMDASH;
  }

  String? get zagAirTime {
    if (this.previousAiring != null) {
      return ZagreusDatabase.USE_24_HOUR_TIME.read()
          ? DateFormat.Hm().format(this.previousAiring!.toLocal())
          : DateFormat('hh:mm a').format(this.previousAiring!.toLocal());
    }
    if (this.airTime == null) {
      return 'zagreus.Unknown'.tr();
    }
    return this.airTime;
  }

  String get zagSeriesType {
    if (this.seriesType == null) return 'zagreus.Unknown'.tr();
    return this.seriesType!.value!.toTitleCase();
  }

  String get zagSeasonCount {
    if (this.statistics?.seasonCount == null) {
      return 'zagreus.Unknown'.tr();
    }
    return this.statistics!.seasonCount == 1
        ? 'sonarr.OneSeason'.tr()
        : 'sonarr.ManySeasons'.tr(
            args: [this.statistics!.seasonCount.toString()],
          );
  }

  String get zagSizeOnDisk {
    if (this.statistics?.sizeOnDisk == null) {
      return '0.0 B';
    }
    return this.statistics!.sizeOnDisk.asBytes(decimals: 1);
  }

  String? get zagOverview {
    if (this.overview == null || this.overview!.isEmpty) {
      return 'sonarr.NoSummaryAvailable'.tr();
    }
    return this.overview;
  }

  String get zagAirsOn {
    if (this.status == 'ended') {
      return 'Aired on ${this.network ?? ZagUI.TEXT_EMDASH}';
    }
    return '${this.zagAirTime ?? 'Unknown Time'} on ${this.network ?? ZagUI.TEXT_EMDASH}';
  }

  String get zagEpisodeCount {
    int episodeFileCount = this.statistics?.episodeFileCount ?? 0;
    int episodeCount = this.statistics?.episodeCount ?? 0;
    int percentage = this.zagPercentageComplete;
    return '$episodeFileCount/$episodeCount ($percentage%)';
  }

  /// Creates a clone of the [SonarrSeries] object (deep copy).
  SonarrSeries clone() => SonarrSeries.fromJson(this.toJson());

  /// Copies changes from a [SonarrSeriesEditState] state object back to the [SonarrSeries] object.
  SonarrSeries updateEdits(SonarrSeriesEditState edits) {
    SonarrSeries series = this.clone();
    series.monitored = edits.monitored;
    series.seasonFolder = edits.useSeasonFolders;
    series.path = edits.seriesPath;
    series.qualityProfileId = edits.qualityProfile?.id ?? this.qualityProfileId;
    series.seriesType = edits.seriesType ?? this.seriesType;
    series.tags = edits.tags?.map((t) => t.id!).toList() ?? [];
    if (edits.languageProfile != null) {
      series.languageProfileId =
          edits.languageProfile!.id ?? this.languageProfileId;
    }

    return series;
  }
}
