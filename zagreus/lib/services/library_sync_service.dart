import 'package:zagreus/core.dart';
import 'package:zagreus/services/device_id_service.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/supabase/core.dart';

/// Service for syncing library cache to Supabase
/// Ensures zero-knowledge architecture - backend never calls user servers
class LibrarySyncService {
  static final LibrarySyncService _instance = LibrarySyncService._internal();
  factory LibrarySyncService() => _instance;
  LibrarySyncService._internal();

  DateTime? _lastSyncTime;
  bool _isSyncing = false;

  /// Check if sync is needed (> 1 hour since last sync)
  bool get needsSync {
    if (_lastSyncTime == null) return true;
    final hoursSinceSync = DateTime.now().difference(_lastSyncTime!).inHours;
    return hoursSinceSync >= 1;
  }

  /// Sync library to Supabase cache
  /// Returns true if successful
  Future<bool> syncLibrary({
    bool force = false,
    bool syncRadarr = true,
    bool syncSonarr = true,
  }) async {
    if (_isSyncing && !force) {
      ZagLogger().debug('Library sync already in progress');
      return false;
    }

    if (!needsSync && !force) {
      ZagLogger().debug('Library sync not needed (last sync: ${_lastSyncTime})');
      return true;
    }

    _isSyncing = true;

    try {
      ZagLogger().debug('🔄 Starting library sync...');

      final deviceId = DeviceIdService().deviceId;
      final List<Map<String, dynamic>> movies = [];
      final List<Map<String, dynamic>> shows = [];

      // Fetch Radarr library
      if (syncRadarr) {
        try {
          final radarrState = RadarrState();
          if (radarrState.enabled && radarrState.api != null) {
            final radarrMovies = await radarrState.api!.movie.getAll();

            for (final movie in radarrMovies) {
              movies.add({
                'title': movie.title,
                'year': movie.year,
                'tmdb_id': movie.tmdbId,
                'has_file': movie.hasFile,
                'quality': movie.movieFile?.quality?.quality?.name,
                'genres': movie.genres,
              });
            }

            ZagLogger().debug('  ✓ Synced ${movies.length} movies from Radarr');
          }
        } catch (e, stack) {
          ZagLogger().error('Failed to fetch Radarr library', e, stack);
        }
      }

      // Fetch Sonarr library
      if (syncSonarr) {
        try {
          final sonarrState = SonarrState();
          if (sonarrState.enabled && sonarrState.api != null) {
            final sonarrShows = await sonarrState.api!.series.getAll();

            for (final show in sonarrShows) {
              // Get season numbers that have files
              final seasonsWithFiles = show.seasons
                  ?.where((s) => (s.statistics?.episodeFileCount ?? 0) > 0)
                  .map((s) => s.seasonNumber)
                  .toList() ?? [];

              shows.add({
                'title': show.title,
                'year': show.year,
                'tmdb_id': show.tvdbId, // Note: Sonarr uses tvdbId
                'seasons': seasonsWithFiles,
                'has_file': seasonsWithFiles.isNotEmpty,
                'genres': show.genres,
              });
            }

            ZagLogger().debug('  ✓ Synced ${shows.length} shows from Sonarr');
          }
        } catch (e, stack) {
          ZagLogger().error('Failed to fetch Sonarr library', e, stack);
        }
      }

      // Upload to Supabase
      try {
        await ZagSupabase.client.from('library_cache').upsert({
          'device_id': deviceId,
          'movies': movies,
          'shows': shows,
          'synced_at': DateTime.now().toIso8601String(),
        });

        _lastSyncTime = DateTime.now();
        ZagLogger().debug('✅ Library synced to Supabase (${movies.length} movies, ${shows.length} shows)');

        _isSyncing = false;
        return true;
      } catch (e, stack) {
        ZagLogger().error('Failed to upload library cache to Supabase', e, stack);
        _isSyncing = false;
        return false;
      }
    } catch (e, stack) {
      ZagLogger().error('Library sync failed', e, stack);
      _isSyncing = false;
      return false;
    }
  }

  /// Sync library if needed (convenience method)
  Future<void> syncIfNeeded() async {
    if (needsSync) {
      await syncLibrary();
    }
  }
}
