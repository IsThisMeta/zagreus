import 'package:flutter/material.dart';
import 'package:zagreus/api/prowlarr/models.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/tables/search.dart';

/// Sort options for Prowlarr search results
enum ProwlarrSortOption {
  ageAsc('search.SortAgeNewest', Icons.schedule),
  ageDesc('search.SortAgeOldest', Icons.history),
  seedersDesc('search.SortSeedersMost', Icons.arrow_upward),
  seedersAsc('search.SortSeedersLeast', Icons.arrow_downward),
  leechersDesc('search.SortLeechersMost', Icons.download),
  leechersAsc('search.SortLeechersLeast', Icons.upload),
  sizeDesc('search.SortSizeLargest', Icons.storage),
  sizeAsc('search.SortSizeSmallest', Icons.sd_storage);

  final String labelKey;
  final IconData icon;

  const ProwlarrSortOption(this.labelKey, this.icon);

  String get label => labelKey.tr();
}

/// Protocol filter options
enum ProwlarrProtocolFilter {
  all,
  usenet,
  torrent,
}

/// Filter configuration for Prowlarr search results
class ProwlarrFilterConfig {
  final Set<String> selectedIndexers;
  final double minSizeGB;
  final double maxSizeGB;
  final int minGrabs;
  final int maxGrabs;
  final ProwlarrProtocolFilter protocol;

  // Max values for sliders
  static const double maxSizeValue = 30.0; // 30GB+
  static const int maxGrabsValue = 300; // 300+ grabs

  const ProwlarrFilterConfig({
    this.selectedIndexers = const {},
    this.minSizeGB = 0,
    this.maxSizeGB = maxSizeValue,
    this.minGrabs = 0,
    this.maxGrabs = maxGrabsValue,
    this.protocol = ProwlarrProtocolFilter.all,
  });

  ProwlarrFilterConfig copyWith({
    Set<String>? selectedIndexers,
    double? minSizeGB,
    double? maxSizeGB,
    int? minGrabs,
    int? maxGrabs,
    ProwlarrProtocolFilter? protocol,
  }) {
    return ProwlarrFilterConfig(
      selectedIndexers: selectedIndexers ?? this.selectedIndexers,
      minSizeGB: minSizeGB ?? this.minSizeGB,
      maxSizeGB: maxSizeGB ?? this.maxSizeGB,
      minGrabs: minGrabs ?? this.minGrabs,
      maxGrabs: maxGrabs ?? this.maxGrabs,
      protocol: protocol ?? this.protocol,
    );
  }

  // Note: We only check min values since max values are dynamic based on results
  // The actual filtering logic in ProwlarrState handles dynamic max checking
  bool get hasActiveFilters =>
      selectedIndexers.isNotEmpty ||
      minSizeGB > 0 ||
      minGrabs > 0 ||
      protocol != ProwlarrProtocolFilter.all;

  int get activeFilterCount {
    int count = 0;
    if (selectedIndexers.isNotEmpty) count++;
    if (minSizeGB > 0) count++;
    if (minGrabs > 0) count++;
    if (protocol != ProwlarrProtocolFilter.all) count++;
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

  /// Get max size in GB from search results (rounded up to nice values)
  double get maxSizeInResults {
    if (_searchResults.isEmpty) return ProwlarrFilterConfig.maxSizeValue;
    final maxBytes = _searchResults
        .map((item) => item.size ?? 0)
        .reduce((a, b) => a > b ? a : b);
    final exactGB = maxBytes / (1024 * 1024 * 1024);

    // Round up to nice increments
    if (exactGB <= 1) return 1;
    if (exactGB <= 5) return 5;
    if (exactGB <= 10) return 10;
    if (exactGB <= 20) return 20;
    if (exactGB <= 30) return 30;
    if (exactGB <= 50) return 50;
    if (exactGB <= 100) return 100;
    // Round to nearest 50GB for larger sizes
    return ((exactGB / 50).ceil() * 50).toDouble();
  }

  /// Get max grabs from search results (rounded up to nice values)
  int get maxGrabsInResults {
    if (_searchResults.isEmpty) return ProwlarrFilterConfig.maxGrabsValue;
    final maxGrabs = _searchResults
        .map((item) => item.grabs ?? 0)
        .reduce((a, b) => a > b ? a : b);

    // Round up to nice increments
    if (maxGrabs <= 10) return 10;
    if (maxGrabs <= 20) return 20;
    if (maxGrabs <= 50) return 50;
    if (maxGrabs <= 100) return 100;
    if (maxGrabs <= 200) return 200;
    if (maxGrabs <= 500) return 500;
    // Round to nearest 100 for larger values
    return ((maxGrabs / 100).ceil() * 100);
  }

  /// Get filtered and sorted search results
  List<ProwlarrItem> get filteredAndSortedResults {
    var results = List<ProwlarrItem>.from(_searchResults);

    // Apply indexer filter
    if (_filterConfig.selectedIndexers.isNotEmpty) {
      results = results
          .where((item) =>
              item.indexer != null &&
              _filterConfig.selectedIndexers.contains(item.indexer))
          .toList();
    }

    // Apply size filter (convert GB to bytes)
    if (_filterConfig.minSizeGB > 0 || _filterConfig.maxSizeGB < maxSizeInResults) {
      final minSizeBytes = (_filterConfig.minSizeGB * 1024 * 1024 * 1024).toInt();
      final maxSizeBytes = (_filterConfig.maxSizeGB * 1024 * 1024 * 1024).toInt();
      results = results.where((item) {
        final size = item.size ?? 0;
        return size >= minSizeBytes && size <= maxSizeBytes;
      }).toList();
    }

    // Apply grabs filter
    if (_filterConfig.minGrabs > 0 || _filterConfig.maxGrabs < maxGrabsInResults) {
      results = results.where((item) {
        final grabs = item.grabs ?? 0;
        return grabs >= _filterConfig.minGrabs && grabs <= _filterConfig.maxGrabs;
      }).toList();
    }

    // Apply protocol filter
    if (_filterConfig.protocol != ProwlarrProtocolFilter.all) {
      results = results.where((item) {
        final protocol = item.protocol?.toLowerCase() ?? '';
        final isTorrent = protocol == 'torrent' || item.seeders != null;
        if (_filterConfig.protocol == ProwlarrProtocolFilter.torrent) {
          return isTorrent;
        } else {
          return !isTorrent; // usenet
        }
      }).toList();
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
