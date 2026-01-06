import 'package:zagreus/api/prowlarr/prowlarr.dart';
import 'package:zagreus/database/models/indexer.dart';

/// Prowlarr API wrapper for the Zagreus application
class ProwlarrAPIWrapper {
  final ZagIndexer indexer;
  late final ProwlarrAPI? api;
  String? initError;

  ProwlarrAPIWrapper(this.indexer) {
    try {
      api = ProwlarrAPI(
        host: indexer.host,
        apiKey: indexer.apiKey,
        headers: indexer.headers.isNotEmpty ? indexer.headers : null,
      );
    } catch (e) {
      api = null;
      initError = e.toString().contains('Scheme not starting')
          ? 'Invalid URL: Make sure to include http:// or https://'
          : 'Invalid Prowlarr configuration: ${e.toString()}';
    }
  }

  /// Check if the API was initialized successfully
  bool get isInitialized => api != null;

  /// Get categories with error handling
  Future<List<dynamic>> getCategories() async {
    if (api == null) {
      throw Exception(initError ?? 'Prowlarr API not initialized');
    }
    try {
      return await api!.getCategories();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  /// Perform search with error handling
  Future<List<dynamic>> search(
    String query, {
    int? categoryId,
  }) async {
    if (api == null) {
      throw Exception(initError ?? 'Prowlarr API not initialized');
    }
    try {
      return await api!.performSearch(
        query,
        categoryId: categoryId,
      );
    } catch (e) {
      throw Exception('Search failed: $e');
    }
  }

  /// Download to client with error handling
  Future<bool> downloadToClient({
    required String guid,
    required int indexerId,
  }) async {
    if (api == null) return false;
    try {
      return await api!.downloadToClient(
        guid: guid,
        indexerId: indexerId,
      );
    } catch (e) {
      return false;
    }
  }
}
