import 'package:zagreus/modules/readarr.dart';

enum ReadarrReleasesSorting {
  age,
  alphabetical,
  seeders,
  size,
  type,
  weight,
}

extension ReadarrReleasesSortingExtension on ReadarrReleasesSorting {
  String get value {
    switch (this) {
      case ReadarrReleasesSorting.age:
        return 'age';
      case ReadarrReleasesSorting.alphabetical:
        return 'abc';
      case ReadarrReleasesSorting.seeders:
        return 'seeders';
      case ReadarrReleasesSorting.weight:
        return 'weight';
      case ReadarrReleasesSorting.type:
        return 'type';
      case ReadarrReleasesSorting.size:
        return 'size';
    }
  }

  String get readable {
    switch (this) {
      case ReadarrReleasesSorting.age:
        return 'Age';
      case ReadarrReleasesSorting.alphabetical:
        return 'Alphabetical';
      case ReadarrReleasesSorting.seeders:
        return 'Seeders';
      case ReadarrReleasesSorting.weight:
        return 'Weight';
      case ReadarrReleasesSorting.type:
        return 'Type';
      case ReadarrReleasesSorting.size:
        return 'Size';
    }
  }

  List<ReadarrReleaseData> sort(List data, bool ascending) =>
      _Sorter().byType(data, this, ascending) as List<ReadarrReleaseData>;
}

class _Sorter {
  List byType(
    List data,
    ReadarrReleasesSorting type,
    bool ascending,
  ) {
    switch (type) {
      case ReadarrReleasesSorting.age:
        return _age(data, ascending);
      case ReadarrReleasesSorting.alphabetical:
        return _alphabetical(data, ascending);
      case ReadarrReleasesSorting.seeders:
        return _seeders(data, ascending);
      case ReadarrReleasesSorting.weight:
        return _weight(data, ascending);
      case ReadarrReleasesSorting.type:
        return _type(data, ascending);
      case ReadarrReleasesSorting.size:
        return _size(data, ascending);
    }
  }

  List<ReadarrReleaseData> _alphabetical(List data, bool ascending) {
    List<ReadarrReleaseData> _data = List.from(data, growable: false);
    ascending
        ? _data.sort((a, b) => a.title.compareTo(b.title))
        : _data.sort((a, b) => b.title.compareTo(a.title));
    return _data;
  }

  List<ReadarrReleaseData> _weight(List data, bool ascending) {
    List<ReadarrReleaseData> _data = List.from(data, growable: false);
    ascending
        ? _data.sort((a, b) => a.releaseWeight.compareTo(b.releaseWeight))
        : _data.sort((a, b) => b.releaseWeight.compareTo(a.releaseWeight));
    return _data;
  }

  List<ReadarrReleaseData> _type(List data, bool ascending) {
    List<ReadarrReleaseData> _data = List.from(data, growable: false);
    List<ReadarrReleaseData> _usenet =
        _data.where((value) => !value.isTorrent).toList();
    List<ReadarrReleaseData> _torrent =
        _data.where((value) => value.isTorrent).toList();
    return ascending ? [..._usenet, ..._torrent] : [..._torrent, ..._usenet];
  }

  List<ReadarrReleaseData> _age(List data, bool ascending) {
    List<ReadarrReleaseData> _data = List.from(data, growable: false);
    ascending
        ? _data.sort((a, b) => a.ageHours.compareTo(b.ageHours))
        : _data.sort((a, b) => b.ageHours.compareTo(a.ageHours));
    return _data;
  }

  List<ReadarrReleaseData> _seeders(List data, bool ascending) {
    List<ReadarrReleaseData> _data = List.from(data, growable: false);
    List<ReadarrReleaseData> _usenet =
        _data.where((value) => !value.isTorrent).toList();
    List<ReadarrReleaseData> _torrent =
        _data.where((value) => value.isTorrent).toList();
    ascending
        ? _torrent.sort((a, b) => (b.seeders ?? 0).compareTo(a.seeders ?? 0))
        : _torrent.sort((a, b) => (a.seeders ?? 0).compareTo(b.seeders ?? 0));
    return [..._torrent, ..._usenet];
  }

  List<ReadarrReleaseData> _size(List data, bool ascending) {
    List<ReadarrReleaseData> _data = List.from(data, growable: false);
    ascending
        ? _data.sort((a, b) => a.size.compareTo(b.size))
        : _data.sort((a, b) => b.size.compareTo(a.size));
    return _data;
  }
}
