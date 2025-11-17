import 'package:zagreus/core.dart';
import 'package:zagreus/modules/readarr.dart';

class ReadarrState extends ZagModuleState {
  ReadarrState() {
    reset();
  }

  @override
  void reset() {}

  ///Catalogue Sticky Header Content
  String _searchCatalogueFilter = '';
  String get searchCatalogueFilter => _searchCatalogueFilter;
  set searchCatalogueFilter(String searchCatalogueFilter) {
    _searchCatalogueFilter = searchCatalogueFilter;
    notifyListeners();
  }

  ReadarrCatalogueSorting _sortCatalogueType =
      ReadarrCatalogueSorting.alphabetical;
  ReadarrCatalogueSorting get sortCatalogueType => _sortCatalogueType;
  set sortCatalogueType(ReadarrCatalogueSorting sortCatalogueType) {
    _sortCatalogueType = sortCatalogueType;
    notifyListeners();
  }

  bool _sortCatalogueAscending = true;
  bool get sortCatalogueAscending => _sortCatalogueAscending;
  set sortCatalogueAscending(bool sortCatalogueAscending) {
    _sortCatalogueAscending = sortCatalogueAscending;
    notifyListeners();
  }

  bool _hideUnmonitoredAuthors = false;
  bool get hideUnmonitoredAuthors => _hideUnmonitoredAuthors;
  set hideUnmonitoredAuthors(bool hideUnmonitoredAuthors) {
    _hideUnmonitoredAuthors = hideUnmonitoredAuthors;
    notifyListeners();
  }

  ///Releases Sticky Header Content

  String _searchReleasesFilter = '';
  String get searchReleasesFilter => _searchReleasesFilter;
  set searchReleasesFilter(String searchReleasesFilter) {
    _searchReleasesFilter = searchReleasesFilter;
    notifyListeners();
  }

  ReadarrReleasesSorting _sortReleasesType = ReadarrReleasesSorting.weight;
  ReadarrReleasesSorting get sortReleasesType => _sortReleasesType;
  set sortReleasesType(ReadarrReleasesSorting sortReleasesType) {
    _sortReleasesType = sortReleasesType;
    notifyListeners();
  }

  bool _sortReleasesAscending = true;
  bool get sortReleasesAscending => _sortReleasesAscending;
  set sortReleasesAscending(bool sortReleasesAscending) {
    _sortReleasesAscending = sortReleasesAscending;
    notifyListeners();
  }

  bool _hideRejectedReleases = false;
  bool get hideRejectedReleases => _hideRejectedReleases;
  set hideRejectedReleases(bool hideRejectedReleases) {
    _hideRejectedReleases = hideRejectedReleases;
    notifyListeners();
  }

  /// Add New Author Content

  String _addSearchQuery = '';
  String get addSearchQuery => _addSearchQuery;
  set addSearchQuery(String addSearchQuery) {
    _addSearchQuery = addSearchQuery;
    notifyListeners();
  }
}
