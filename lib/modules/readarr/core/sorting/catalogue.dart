import 'package:zagreus/core.dart';
import 'package:zagreus/modules/readarr.dart';

enum ReadarrCatalogueSorting {
  alphabetical,
  dateAdded,
  metadata,
  quality,
  size,
  books,
  type,
}

extension ReadarrCatalogueSortingExtension on ReadarrCatalogueSorting {
  String get value {
    switch (this) {
      case ReadarrCatalogueSorting.alphabetical:
        return 'abc';
      case ReadarrCatalogueSorting.dateAdded:
        return 'date_added';
      case ReadarrCatalogueSorting.size:
        return 'size';
      case ReadarrCatalogueSorting.metadata:
        return 'metadata';
      case ReadarrCatalogueSorting.quality:
        return 'quality';
      case ReadarrCatalogueSorting.books:
        return 'books';
      case ReadarrCatalogueSorting.type:
        return 'type';
    }
  }

  String get readable {
    switch (this) {
      case ReadarrCatalogueSorting.alphabetical:
        return 'readarr.SortAlphabetical'.tr();
      case ReadarrCatalogueSorting.dateAdded:
        return 'readarr.SortDateAdded'.tr();
      case ReadarrCatalogueSorting.size:
        return 'readarr.SortSize'.tr();
      case ReadarrCatalogueSorting.metadata:
        return 'readarr.SortMetadataProfile'.tr();
      case ReadarrCatalogueSorting.quality:
        return 'readarr.SortQualityProfile'.tr();
      case ReadarrCatalogueSorting.books:
        return 'readarr.SortBooks'.tr();
      case ReadarrCatalogueSorting.type:
        return 'readarr.SortType'.tr();
    }
  }

  List<ReadarrCatalogueData> sort(List data, bool ascending) =>
      _Sorter().byType(data, this, ascending) as List<ReadarrCatalogueData>;
}

class _Sorter {
  List byType(
    List data,
    ReadarrCatalogueSorting type,
    bool ascending,
  ) {
    switch (type) {
      case ReadarrCatalogueSorting.alphabetical:
        return _alphabetical(data, ascending);
      case ReadarrCatalogueSorting.dateAdded:
        return _dateAdded(data, ascending);
      case ReadarrCatalogueSorting.size:
        return _size(data, ascending);
      case ReadarrCatalogueSorting.metadata:
        return _metadata(data, ascending);
      case ReadarrCatalogueSorting.quality:
        return _quality(data, ascending);
      case ReadarrCatalogueSorting.books:
        return _books(data, ascending);
      case ReadarrCatalogueSorting.type:
        return _type(data, ascending);
    }
  }

  List<ReadarrCatalogueData> _alphabetical(List data, bool ascending) {
    List<ReadarrCatalogueData> _data = List.from(data, growable: false);
    ascending
        ? _data.sort((a, b) => a.sortTitle.compareTo(b.sortTitle))
        : _data.sort((a, b) => b.sortTitle.compareTo(a.sortTitle));
    return _data;
  }

  List<ReadarrCatalogueData> _dateAdded(List data, bool ascending) {
    List<ReadarrCatalogueData> _data = _alphabetical(data, true);
    List<ReadarrCatalogueData> _hasNoDate =
        _data.where((item) => item.dateAddedObject == null).toList();
    List<ReadarrCatalogueData> _hasDate =
        _data.where((item) => item.dateAddedObject != null).toList();
    _hasDate.sort((a, b) {
      return ascending
          ? a.dateAddedObject!.compareTo(b.dateAddedObject!)
          : b.dateAddedObject!.compareTo(a.dateAddedObject!);
    });
    return [..._hasDate, ..._hasNoDate];
  }

  List<ReadarrCatalogueData> _size(List data, bool ascending) {
    List<ReadarrCatalogueData> _data = _alphabetical(data, true);
    ascending
        ? _data.sort((a, b) => a.sizeOnDisk.compareTo(b.sizeOnDisk))
        : _data.sort((a, b) => b.sizeOnDisk.compareTo(a.sizeOnDisk));
    return _data;
  }

  List<ReadarrCatalogueData> _quality(List data, bool ascending) {
    List<ReadarrCatalogueData> _data = _alphabetical(data, true);
    ascending
        ? _data.sort((a, b) => a.qualityProfile!.compareTo(b.qualityProfile!))
        : _data.sort((a, b) => b.qualityProfile!.compareTo(a.qualityProfile!));
    return _data;
  }

  List<ReadarrCatalogueData> _metadata(List data, bool ascending) {
    List<ReadarrCatalogueData> _data = _alphabetical(data, true);
    ascending
        ? _data.sort((a, b) => a.metadataProfile!.compareTo(b.metadataProfile!))
        : _data
            .sort((a, b) => b.metadataProfile!.compareTo(a.metadataProfile!));
    return _data;
  }

  List<ReadarrCatalogueData> _books(List data, bool ascending) {
    List<ReadarrCatalogueData> _data = List.from(data, growable: false);
    ascending
        ? _data.sort((a, b) => a.statistics['percentOfBooks']
            .compareTo(b.statistics['percentOfBooks']))
        : _data.sort((a, b) => b.statistics['percentOfBooks']
            .compareTo(a.statistics['percentOfBooks']));
    return _data;
  }

  List<ReadarrCatalogueData> _type(List data, bool ascending) {
    List<ReadarrCatalogueData> _data = _alphabetical(data, true);
    ascending
        ? _data.sort((a, b) => a.authorType.compareTo(b.authorType))
        : _data.sort((a, b) => b.authorType.compareTo(a.authorType));
    return _data;
  }
}
