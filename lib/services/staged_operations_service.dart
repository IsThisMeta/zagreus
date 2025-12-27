import 'package:zagreus/core.dart';
import 'package:zagreus/supabase/core.dart';

/// Model for a staged media item from Z Assistant
class StagedMediaItem {
  final int tmdbId; // For movies/shows, or person_id for people
  final int? tvdbId; // For TV shows (Sonarr uses TVDB)
  final String title; // For movies/shows, or name for people
  final int? year;
  final String? posterPath; // poster_path for movies/shows, profile_path for people
  final String? overview;
  final String mediaType; // "movie", "tv", or "person"
  final bool verified;
  final String? reason; // Why this item is recommended (for explore operations)
  final String? knownForDepartment; // For people only (e.g., "Acting", "Directing")
  final double? popularity; // For people only

  StagedMediaItem({
    required this.tmdbId,
    this.tvdbId,
    required this.title,
    this.year,
    this.posterPath,
    this.overview,
    required this.mediaType,
    required this.verified,
    this.reason,
    this.knownForDepartment,
    this.popularity,
  });

  factory StagedMediaItem.fromJson(Map<String, dynamic> json) {
    final mediaType = json['media_type'] as String;

    // People use different field names
    final isPerson = mediaType == 'person';

    return StagedMediaItem(
      tmdbId: (json['person_id'] ?? json['tmdb_id']) as int,
      tvdbId: json['tvdb_id'] as int?,
      title: (json['name'] ?? json['title']) as String,
      year: json['year'] as int?,
      posterPath: (json['profile_path'] ?? json['poster_path']) as String?,
      overview: json['overview'] as String?,
      mediaType: mediaType,
      verified: json['verified'] as bool? ?? true,
      reason: json['reason'] as String?,
      knownForDepartment: isPerson ? json['known_for_department'] as String? : null,
      popularity: isPerson ? (json['popularity'] as num?)?.toDouble() : null,
    );
  }

  String get posterUrl {
    if (posterPath == null) return '';
    return 'https://image.tmdb.org/t/p/w342$posterPath';
  }

  String get profileUrl {
    if (posterPath == null) return '';
    return 'https://image.tmdb.org/t/p/w185$posterPath';
  }

  bool get isMovie => mediaType == 'movie';
  bool get isShow => mediaType == 'tv';
  bool get isPerson => mediaType == 'person';

  int get personId => tmdbId; // Alias for clarity when dealing with people
}

/// Model for a staged operation from Z Assistant
class StagedOperation {
  final String stageId;
  final String operation;
  final List<StagedMediaItem> items;
  final String status;
  final String? userId;
  final DateTime createdAt;
  final Map<String, dynamic>?
      params; // Operation parameters (e.g., target quality profile)

  StagedOperation({
    required this.stageId,
    required this.operation,
    required this.items,
    required this.status,
    this.userId,
    required this.createdAt,
    this.params,
  });

  factory StagedOperation.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>;
    final items = itemsJson
        .map((item) => StagedMediaItem.fromJson(item as Map<String, dynamic>))
        .toList();

    return StagedOperation(
      stageId: json['stage_id'] as String,
      operation: json['operation'] as String,
      items: items,
      status: json['status'] as String,
      userId: json['user_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      params: json['params'] as Map<String, dynamic>?,
    );
  }
}

/// Service for fetching staged operations from Supabase
class StagedOperationsService {
  /// Fetch a staged operation by stage_id
  Future<StagedOperation?> fetchStagedOperation(String stageId) async {
    try {
      ZagLogger().debug('Fetching staged operation: $stageId');

      final response = await ZagSupabase.client
          .from('staged_operations')
          .select()
          .eq('stage_id', stageId)
          .single();

      ZagLogger().debug('Staged operation fetched successfully');
      return StagedOperation.fromJson(response);
    } catch (e, stack) {
      ZagLogger().error('Failed to fetch staged operation', e, stack);
      return null;
    }
  }

  /// Fetch all staged operations for the current user
  Future<List<StagedOperation>> fetchUserStagedOperations() async {
    try {
      ZagLogger().debug('Fetching user staged operations');

      final userId = ZagSupabase.client.auth.currentUser?.id;
      if (userId == null) {
        ZagLogger()
            .warning('No user logged in, cannot fetch staged operations');
        return [];
      }

      final response = await ZagSupabase.client
          .from('staged_operations')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final operations = (response as List<dynamic>)
          .map((item) => StagedOperation.fromJson(item as Map<String, dynamic>))
          .toList();

      ZagLogger().debug('Fetched ${operations.length} staged operations');
      return operations;
    } catch (e, stack) {
      ZagLogger().error('Failed to fetch user staged operations', e, stack);
      return [];
    }
  }

  /// Delete a staged operation by stage_id
  Future<bool> deleteStagedOperation(String stageId) async {
    try {
      ZagLogger().debug('Deleting staged operation: $stageId');

      await ZagSupabase.client
          .from('staged_operations')
          .delete()
          .eq('stage_id', stageId);

      ZagLogger().debug('Staged operation deleted successfully');
      return true;
    } catch (e, stack) {
      ZagLogger().error('Failed to delete staged operation', e, stack);
      return false;
    }
  }

  /// Create a staged operation (for testing)
  Future<String> createStagedOperation(
      String operation, List<Map<String, dynamic>> items,
      {Map<String, dynamic>? params}) async {
    try {
      ZagLogger().debug(
          'Creating staged operation: $operation with ${items.length} items');

      // Generate a stage ID
      final stageId = DateTime.now().millisecondsSinceEpoch.toString();

      final insertData = {
        'stage_id': stageId,
        'operation': operation,
        'items': items,
        'status': 'pending',
      };

      if (params != null) {
        insertData['params'] = params;
      }

      await ZagSupabase.client.from('staged_operations').insert(insertData);

      ZagLogger().debug('Staged operation created: $stageId');
      return stageId;
    } catch (e, stack) {
      ZagLogger().error('Failed to create staged operation', e, stack);
      rethrow;
    }
  }
}
