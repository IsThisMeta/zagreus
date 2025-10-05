import 'package:zagreus/core.dart';
import 'package:zagreus/services/device_id_service.dart';
import 'package:zagreus/services/revenuecat_service.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/supabase/core.dart';

/// Service for syncing library cache to Supabase
/// Ensures zero-knowledge architecture - backend never calls user servers
/// Only syncs for Mega subscribers, max once per 24 hours
class LibrarySyncService {
  static final LibrarySyncService _instance = LibrarySyncService._internal();
  factory LibrarySyncService() => _instance;
  LibrarySyncService._internal();

  DateTime? _lastSyncTime;
  bool _isSyncing = false;

  /// Check if sync is needed (> 24 hours since last sync)
  bool get needsSync {
    if (_lastSyncTime == null) return true;
    final hoursSinceSync = DateTime.now().difference(_lastSyncTime!).inHours;
    return hoursSinceSync >= 24;
  }

  /// Sync library to Supabase cache
  /// Returns true if successful
  /// Only syncs for Mega subscribers
  Future<bool> syncLibrary({
    bool force = false,
    bool syncRadarr = true,
    bool syncSonarr = true,
  }) async {
    print('\n═══════════════════════════════════════');
    print('🔄 LIBRARY SYNC STARTED');
    print('═══════════════════════════════════════');
    print('Force: $force');
    print('Sync Radarr: $syncRadarr');
    print('Sync Sonarr: $syncSonarr');

    // Check for Mega subscription - library sync is Mega-only feature
    final rcService = RevenueCatService();
    if (!rcService.isMegaActive) {
      print('❌ SYNC BLOCKED: Mega subscription required');
      ZagLogger().debug('Library sync skipped - Mega subscription required');
      return false;
    }
    print('✓ Mega subscription active');

    if (_isSyncing && !force) {
      print('❌ SYNC BLOCKED: Already in progress');
      ZagLogger().debug('Library sync already in progress');
      return false;
    }

    if (!needsSync && !force) {
      print('ℹ️  SYNC SKIPPED: Not needed (last sync: ${_lastSyncTime})');
      ZagLogger().debug('Library sync not needed (last sync: ${_lastSyncTime})');
      return true;
    }

    _isSyncing = true;
    print('✓ Sync lock acquired');

    try {
      final deviceId = DeviceIdService().deviceId;
      print('Device ID: $deviceId');

      // Mark sync as in progress in Supabase
      print('\n→ Marking sync as in progress in Supabase...');
      try {
        await ZagSupabase.client.from('library_cache').upsert(
          {
            'device_id': deviceId,
            'is_syncing': true,
            'sync_started_at': DateTime.now().toIso8601String(),
          },
          onConflict: 'device_id',
        );
        print('✓ Supabase sync status updated');
      } catch (e, stack) {
        print('⚠️  Failed to mark sync in progress: $e');
        ZagLogger().error('Failed to mark sync as in progress', e, stack);
      }

      final List<Map<String, dynamic>> movies = [];
      final List<Map<String, dynamic>> shows = [];

      // Fetch Radarr library
      if (syncRadarr) {
        print('\n→ Fetching Radarr library...');
        try {
          final radarrState = RadarrState();
          print('  Radarr enabled: ${radarrState.enabled}');
          print('  Radarr API available: ${radarrState.api != null}');

          if (radarrState.enabled && radarrState.api != null) {
            print('  Calling Radarr API...');
            final radarrMovies = await radarrState.api!.movie.getAll();
            print('  Received ${radarrMovies.length} movies from Radarr');

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

            print('✓ Processed ${movies.length} movies from Radarr');
          } else {
            print('⊘ Radarr not configured - skipping');
          }
        } catch (e, stack) {
          print('❌ ERROR fetching Radarr library: $e');
          ZagLogger().error('Failed to fetch Radarr library', e, stack);
        }
      } else {
        print('⊘ Radarr sync disabled');
      }

      // Fetch Sonarr library
      if (syncSonarr) {
        print('\n→ Fetching Sonarr library...');
        try {
          final sonarrState = SonarrState();
          print('  Sonarr enabled: ${sonarrState.enabled}');
          print('  Sonarr API available: ${sonarrState.api != null}');

          if (sonarrState.enabled && sonarrState.api != null) {
            print('  Calling Sonarr API...');
            final sonarrShows = await sonarrState.api!.series.getAll();
            print('  Received ${sonarrShows.length} shows from Sonarr');

            for (final show in sonarrShows) {
              // Get season info with completion percentages
              final seasonsWithPercentages = show.seasons
                  ?.where((s) => (s.statistics?.episodeFileCount ?? 0) > 0)
                  .map((s) {
                    final fileCount = s.statistics?.episodeFileCount ?? 0;
                    final totalCount = s.statistics?.episodeCount ?? 0;
                    final percentage = totalCount > 0
                        ? ((fileCount / totalCount) * 100).round()
                        : 0;
                    return '${s.seasonNumber} (${percentage}%)';
                  })
                  .toList() ?? [];

              shows.add({
                'title': show.title,
                'year': show.year,
                'tvdb_id': show.tvdbId,  // Sonarr uses TVDB IDs
                'seasons': seasonsWithPercentages,
                'has_file': seasonsWithPercentages.isNotEmpty,
                'genres': show.genres,
              });
            }

            print('✓ Processed ${shows.length} shows from Sonarr');
          } else {
            print('⊘ Sonarr not configured - skipping');
          }
        } catch (e, stack) {
          print('❌ ERROR fetching Sonarr library: $e');
          ZagLogger().error('Failed to fetch Sonarr library', e, stack);
        }
      } else {
        print('⊘ Sonarr sync disabled');
      }

      // Upload to Supabase
      print('\n→ Uploading to Supabase...');
      print('  Movies: ${movies.length}');
      print('  Shows: ${shows.length}');

      try {
        final uploadData = {
          'device_id': deviceId,
          'movies': movies,
          'shows': shows,
          'synced_at': DateTime.now().toIso8601String(),
          'is_syncing': false,
        };

        print('  Calling Supabase upsert...');
        await ZagSupabase.client.from('library_cache').upsert(
          uploadData,
          onConflict: 'device_id',
        );
        print('✓ Successfully uploaded to Supabase');

        _lastSyncTime = DateTime.now();
        _isSyncing = false;

        print('\n═══════════════════════════════════════');
        print('✅ LIBRARY SYNC COMPLETED');
        print('   Movies: ${movies.length}');
        print('   Shows: ${shows.length}');
        print('   Time: ${DateTime.now()}');
        print('═══════════════════════════════════════\n');

        return true;
      } catch (e, stack) {
        print('❌ ERROR uploading to Supabase: $e');
        print('Stack trace: $stack');
        ZagLogger().error('Failed to upload library cache to Supabase', e, stack);
        _isSyncing = false;

        // Try to clear is_syncing flag
        try {
          await ZagSupabase.client.from('library_cache').upsert(
            {
              'device_id': deviceId,
              'is_syncing': false,
            },
            onConflict: 'device_id',
          );
          print('✓ Cleared is_syncing flag after error');
        } catch (clearError) {
          print('❌ Failed to clear is_syncing flag: $clearError');
        }

        return false;
      }
    } catch (e, stack) {
      print('❌ FATAL ERROR during library sync: $e');
      print('Stack trace: $stack');
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
