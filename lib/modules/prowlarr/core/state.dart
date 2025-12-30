import 'package:flutter/material.dart';
import 'package:zagreus/api/prowlarr/models.dart';
import 'package:zagreus/database/tables/search.dart';

/// Sort options for Prowlarr search results
enum ProwlarrSortOption {
  ageAsc('Age (Newest)', Icons.schedule),
  ageDesc('Age (Oldest)', Icons.history),
  seedersDesc('Seeders (Most)', Icons.arrow_upward),
  seedersAsc('Seeders (Least)', Icons.arrow_downward),
  leechersDesc('Leechers (Most)', Icons.download),
  leechersAsc('Leechers (Least)', Icons.upload),
  sizeDesc('Size (Largest)', Icons.storage),
  sizeAsc('Size (Smallest)', Icons.sd_storage);

  final String label;
  final IconData icon;

  const ProwlarrSortOption(this.label, this.icon);
}

/// Filter configuration for Prowlarr search results
class ProwlarrFilterConfig {
  final Set<String> selectedIndexers;
  final int? minSeeders;
  final int? maxAgeDays;

  const ProwlarrFilterConfig({
    this.selectedIndexers = const {},
    this.minSeeders,
    this.maxAgeDays,
  });

  ProwlarrFilterConfig copyWith({
    Set<String>? selectedIndexers,
    int? minSeeders,
    int? maxAgeDays,
    bool clearMinSeeders = false,
    bool clearMaxAgeDays = false,
  }) {
    return ProwlarrFilterConfig(
      selectedIndexers: selectedIndexers ?? this.selectedIndexers,
      minSeeders: clearMinSeeders ? null : (minSeeders ?? this.minSeeders),
      maxAgeDays: clearMaxAgeDays ? null : (maxAgeDays ?? this.maxAgeDays),
    );
  }

  bool get hasActiveFilters =>
      selectedIndexers.isNotEmpty || minSeeders != null || maxAgeDays != null;

  int get activeFilterCount {
    int count = 0;
    if (selectedIndexers.isNotEmpty) count++;
    if (minSeeders != null) count++;
    if (maxAgeDays != null) count++;
    return count;
  }
}

/// State management for Prowlarr module
class ProwlarrState extends ChangeNotifier {
  List<ProwlarrCategory> _categories = [];
  List<ProwlarrItem> _searchResults = [];
  List<String> _searchHistory = [];
  bool _isLoading = false;
  String? _error;
  ProwlarrCategory? _selectedCategory;

  // Sorting and filtering
  ProwlarrSortOption _sortOption = ProwlarrSortOption.ageAsc;
  ProwlarrFilterConfig _filterConfig = const ProwlarrFilterConfig();

  List<ProwlarrCategory> get categories => _categories;
  List<ProwlarrItem> get searchResults => _searchResults;
  List<String> get searchHistory => _searchHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ProwlarrCategory? get selectedCategory => _selectedCategory;

  // Sorting and filtering getters
  ProwlarrSortOption get sortOption => _sortOption;
  ProwlarrFilterConfig get filterConfig => _filterConfig;

  /// Get unique indexer names from search results
  Set<String> get availableIndexers {
    return _searchResults
        .where((item) => item.indexer != null)
        .map((item) => item.indexer!)
        .toSet();
  }

  /// Get filtered and sorted search results
  List<ProwlarrItem> get filteredAndSortedResults {
    var results = List<ProwlarrItem>.from(_searchResults);

    // Apply filters
    if (_filterConfig.selectedIndexers.isNotEmpty) {
      results = results
          .where((item) =>
              item.indexer != null &&
              _filterConfig.selectedIndexers.contains(item.indexer))
          .toList();
    }

    if (_filterConfig.minSeeders != null) {
      results = results
          .where((item) =>
              item.seeders != null &&
              item.seeders! >= _filterConfig.minSeeders!)
          .toList();
    }

    if (_filterConfig.maxAgeDays != null) {
      results = results
          .where((item) =>
              item.age != null && item.age! <= _filterConfig.maxAgeDays!)
          .toList();
    }

    // Apply sorting
    results.sort((a, b) {
      switch (_sortOption) {
        case ProwlarrSortOption.ageAsc:
          return (a.age ?? 9999).compareTo(b.age ?? 9999);
        case ProwlarrSortOption.ageDesc:
          return (b.age ?? 0).compareTo(a.age ?? 0);
        case ProwlarrSortOption.seedersDesc:
          return (b.seeders ?? 0).compareTo(a.seeders ?? 0);
        case ProwlarrSortOption.seedersAsc:
          return (a.seeders ?? 0).compareTo(b.seeders ?? 0);
        case ProwlarrSortOption.leechersDesc:
          return (b.leechers ?? 0).compareTo(a.leechers ?? 0);
        case ProwlarrSortOption.leechersAsc:
          return (a.leechers ?? 0).compareTo(b.leechers ?? 0);
        case ProwlarrSortOption.sizeDesc:
          return (b.size ?? 0).compareTo(a.size ?? 0);
        case ProwlarrSortOption.sizeAsc:
          return (a.size ?? 0).compareTo(b.size ?? 0);
      }
    });

    return results;
  }

  void setSortOption(ProwlarrSortOption option) {
    _sortOption = option;
    notifyListeners();
  }

  void setFilterConfig(ProwlarrFilterConfig config) {
    _filterConfig = config;
    notifyListeners();
  }

  void clearFilters() {
    _filterConfig = const ProwlarrFilterConfig();
    notifyListeners();
  }

  void setCategories(List<ProwlarrCategory> categories) {
    _categories = categories;
    notifyListeners();
  }

  void setSearchResults(List<ProwlarrItem> results) {
    _searchResults = results;
    notifyListeners();
  }

  ProwlarrState() {
    _searchHistory =
        List<String>.from(SearchDatabase.PROWLARR_HISTORY.read());
  }

  void addSearchToHistory(String query) {
    if (!_searchHistory.contains(query)) {
      _searchHistory.insert(0, query);
      if (_searchHistory.length > 20) {
        _searchHistory = _searchHistory.sublist(0, 20);
      }
      SearchDatabase.PROWLARR_HISTORY.update(_searchHistory);
      notifyListeners();
    }
  }

  void clearSearchHistory() {
    _searchHistory.clear();
    SearchDatabase.PROWLARR_HISTORY.update(_searchHistory);
    notifyListeners();
  }

  void removeSearchFromHistory(String query) {
    _searchHistory.remove(query);
    SearchDatabase.PROWLARR_HISTORY.update(_searchHistory);
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void setSelectedCategory(ProwlarrCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reset() {
    _categories = [];
    _searchResults = [];
    _isLoading = false;
    _error = null;
    _selectedCategory = null;
    notifyListeners();
  }
}
