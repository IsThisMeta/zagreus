import 'package:zagreus/core.dart';
import 'package:zagreus/modules/sonarr.dart';

part 'sorting_releases.g.dart';

@HiveType(typeId: 17, adapterName: 'SonarrReleasesSortingAdapter')
enum SonarrReleasesSorting {
  @HiveField(0)
  AGE,
  @HiveField(1)
  ALPHABETICAL,
  @HiveField(2)
  SEEDERS,
  @HiveField(3)
  SIZE,
  @HiveField(4)
  TYPE,
  @HiveField(5)
  WEIGHT,
  @HiveField(6)
  WORD_SCORE,
  @HiveField(7)
  CUSTOM_FORMAT_SCORE,
}

extension SonarrReleasesSortingExtension on SonarrReleasesSorting {
  String get key {
    switch (this) {
      case SonarrReleasesSorting.AGE:
        return 'age';
      case SonarrReleasesSorting.ALPHABETICAL:
        return 'abc';
      case SonarrReleasesSorting.SEEDERS:
        return 'seeders';
      case SonarrReleasesSorting.WEIGHT:
        return 'weight';
      case SonarrReleasesSorting.TYPE:
        return 'type';
      case SonarrReleasesSorting.SIZE:
        return 'size';
      case SonarrReleasesSorting.WORD_SCORE:
        return 'word_score';
      case SonarrReleasesSorting.CUSTOM_FORMAT_SCORE:
        return 'customFormatScore';
    }
  }

  String get readable {
    switch (this) {
      case SonarrReleasesSorting.AGE:
        return 'Age';
      case SonarrReleasesSorting.ALPHABETICAL:
        return 'Alphabetical';
      case SonarrReleasesSorting.SEEDERS:
        return 'Seeders';
      case SonarrReleasesSorting.WEIGHT:
        return 'Weight';
      case SonarrReleasesSorting.TYPE:
        return 'Type';
      case SonarrReleasesSorting.SIZE:
        return 'Size';
      case SonarrReleasesSorting.WORD_SCORE:
        return 'sonarr.WordScore'.tr();
      case SonarrReleasesSorting.CUSTOM_FORMAT_SCORE:
        return 'sonarr.CustomFormatScore'.tr();
    }
  }

  SonarrReleasesSorting? fromKey(String? key) {
    switch (key) {
      case 'age':
        return SonarrReleasesSorting.AGE;
      case 'abc':
        return SonarrReleasesSorting.ALPHABETICAL;
      case 'seeders':
        return SonarrReleasesSorting.SEEDERS;
      case 'size':
        return SonarrReleasesSorting.SIZE;
      case 'type':
        return SonarrReleasesSorting.TYPE;
      case 'weight':
        return SonarrReleasesSorting.WEIGHT;
      case 'word_score':
        return SonarrReleasesSorting.WORD_SCORE;
      case 'customFormatScore':
        return SonarrReleasesSorting.CUSTOM_FORMAT_SCORE;
      default:
        return null;
    }
  }

  List<SonarrRelease> sort(List<SonarrRelease> releases, bool ascending) =>
      _Sorter().byType(releases, this, ascending);
}

class _Sorter {
  List<SonarrRelease> byType(
    List<SonarrRelease> releases,
    SonarrReleasesSorting type,
    bool ascending,
  ) {
    switch (type) {
      case SonarrReleasesSorting.AGE:
        return _age(releases, ascending);
      case SonarrReleasesSorting.ALPHABETICAL:
        return _alphabetical(releases, ascending);
      case SonarrReleasesSorting.SEEDERS:
        return _seeders(releases, ascending);
      case SonarrReleasesSorting.WEIGHT:
        return _weight(releases, ascending);
      case SonarrReleasesSorting.TYPE:
        return _type(releases, ascending);
      case SonarrReleasesSorting.SIZE:
        return _size(releases, ascending);
      case SonarrReleasesSorting.WORD_SCORE:
        return _wordScore(releases, ascending);
      case SonarrReleasesSorting.CUSTOM_FORMAT_SCORE:
        return _customFormatScore(releases, ascending);
    }
  }

  List<SonarrRelease> _alphabetical(
      List<SonarrRelease> releases, bool ascending) {
    ascending
        ? releases.sort(
            (a, b) => a.title!.toLowerCase().compareTo(b.title!.toLowerCase()))
        : releases.sort(
            (a, b) => b.title!.toLowerCase().compareTo(a.title!.toLowerCase()));
    return releases;
  }

  List<SonarrRelease> _age(List<SonarrRelease> releases, bool ascending) {
    ascending
        ? releases.sort((a, b) => a.ageHours!.compareTo(b.ageHours!))
        : releases.sort((a, b) => b.ageHours!.compareTo(a.ageHours!));
    return releases;
  }

  List<SonarrRelease> _seeders(List<SonarrRelease> releases, bool ascending) {
    List<SonarrRelease> _torrent = _weight(
        releases
            .where((release) => release.protocol == SonarrProtocol.TORRENT)
            .toList(),
        true);
    List<SonarrRelease> _usenet = _weight(
        releases
            .where((release) => release.protocol == SonarrProtocol.USENET)
            .toList(),
        true);
    ascending
        ? _torrent
            .sort((a, b) => (a.seeders ?? -1).compareTo((b.seeders ?? -1)))
        : _torrent
            .sort((a, b) => (b.seeders ?? -1).compareTo((a.seeders ?? -1)));
    return [..._torrent, ..._usenet];
  }

  List<SonarrRelease> _weight(List<SonarrRelease> releases, bool ascending) {
    ascending
        ? releases.sort((a, b) =>
            (a.releaseWeight ?? -1).compareTo((b.releaseWeight ?? -1)))
        : releases.sort((a, b) =>
            (b.releaseWeight ?? -1).compareTo((a.releaseWeight ?? -1)));
    return releases;
  }

  List<SonarrRelease> _type(List<SonarrRelease> releases, bool ascending) {
    List<SonarrRelease> _torrent = _weight(
        releases
            .where((release) => release.protocol == SonarrProtocol.TORRENT)
            .toList(),
        true);
    List<SonarrRelease> _usenet = _weight(
        releases
            .where((release) => release.protocol == SonarrProtocol.USENET)
            .toList(),
        true);
    return ascending ? [..._torrent, ..._usenet] : [..._usenet, ..._torrent];
  }

  List<SonarrRelease> _size(List<SonarrRelease> releases, bool ascending) {
    ascending
        ? releases.sort((a, b) => (a.size ?? -1).compareTo((b.size ?? -1)))
        : releases.sort((a, b) => (b.size ?? -1).compareTo((a.size ?? -1)));
    return releases;
  }

  List<SonarrRelease> _wordScore(List<SonarrRelease> releases, bool ascending) {
    ascending
        ? releases.sort((a, b) =>
            (b.preferredWordScore ?? 0).compareTo((a.preferredWordScore ?? 0)))
        : releases.sort((a, b) =>
            (a.preferredWordScore ?? 0).compareTo((b.preferredWordScore ?? 0)));
    return releases;
  }

  List<SonarrRelease> _customFormatScore(
      List<SonarrRelease> releases, bool ascending) {
    // Note: For custom format score, ascending means high-to-low (reversed from normal)
    // to match user expectations (highest scores are "best")
    final sortDescending = ascending;

    releases.sort((a, b) {
      final aHasFormats = (a.customFormats?.isNotEmpty ?? false);
      final bHasFormats = (b.customFormats?.isNotEmpty ?? false);

      // Prioritize releases with formats over those without
      if (!bHasFormats && aHasFormats) return sortDescending ? -1 : 1;
      if (!aHasFormats && bHasFormats) return sortDescending ? 1 : -1;

      // Both have formats or both don't - sort by score
      final aScore = a.customFormatScore ?? 0;
      final bScore = b.customFormatScore ?? 0;
      return sortDescending ? bScore.compareTo(aScore) : aScore.compareTo(bScore);
    });

    return releases;
  }
}
