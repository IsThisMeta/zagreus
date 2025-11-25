import 'package:flutter/material.dart';
import 'package:zagreus/api/prowlarr/models.dart';
import 'package:zagreus/database/tables/search.dart';

/// State management for Prowlarr module
class ProwlarrState extends ChangeNotifier {
  List<ProwlarrCategory> _categories = [];
  List<ProwlarrItem> _searchResults = [];
  List<String> _searchHistory = [];
  bool _isLoading = false;
  String? _error;
  ProwlarrCategory? _selectedCategory;

  List<ProwlarrCategory> get categories => _categories;
  List<ProwlarrItem> get searchResults => _searchResults;
  List<String> get searchHistory => _searchHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ProwlarrCategory? get selectedCategory => _selectedCategory;

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
        List<String>.from(SearchDatabase.PROWLARR_HISTORY.read() ?? const []);
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
