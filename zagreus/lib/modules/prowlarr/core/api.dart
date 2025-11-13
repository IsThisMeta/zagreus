import 'package:dio/dio.dart';
import 'package:zagreus/api/prowlarr/prowlarr.dart';
import 'package:zagreus/database/models/indexer.dart';

/// Prowlarr API wrapper for the Zagreus application
class ProwlarrAPIWrapper {
  final ZagIndexer indexer;
  late final ProwlarrAPI api;

  ProwlarrAPIWrapper(this.indexer) {
    api = ProwlarrAPI(
      host: indexer.host,
      apiKey: indexer.apiKey,
      headers: indexer.headers.isNotEmpty ? indexer.headers : null,
    );
  }

  /// Get categories with error handling
  Future<List<dynamic>> getCategories() async {
    try {
      return await api.getCategories();
    } on DioException catch (e) {
      throw Exception('Failed to fetch categories: ${e.message}');
    }
  }

  /// Perform search with error handling
  Future<List<dynamic>> search(String query, {int? categoryId}) async {
    try {
      return await api.performSearch(query, categoryId: categoryId);
    } on DioException catch (e) {
      throw Exception('Search failed: ${e.message}');
    }
  }

  /// Download to client with error handling
  Future<bool> downloadToClient({
    required String guid,
    required int indexerId,
  }) async {
    try {
      return await api.downloadToClient(
        guid: guid,
        indexerId: indexerId,
      );
    } catch (e) {
      return false;
    }
  }
}
