import 'package:zagreus/core.dart';
import 'package:zagreus/services/device_id_service.dart';
import 'package:zagreus/services/revenuecat_service.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/utils/zagreus_mega.dart';
import 'package:zagreus/supabase/core.dart';

String? _normalizeTmdbPosterPath(String? url) {
  if (url == null || url.isEmpty) {
    return null;
  }

  const marker = '/t/p/';
  final markerIndex = url.indexOf(marker);
  if (markerIndex == -1) {
    return null;
  }

  final remainder = url.substring(markerIndex + marker.length);
  final slashIndex = remainder.indexOf('/');
  if (slashIndex == -1 || slashIndex + 1 >= remainder.length) {
    return null;
  }

  final path = remainder.substring(slashIndex + 1).split('?').first.trim();
  if (path.isEmpty) {
    return null;
  }

  return '/$path';
}

enum LibrarySyncError {
  noMega,
  cacheDisabled,
  alreadySyncing,
  uploadFailed,
  unknown,
}

class LibrarySyncResult {
  final bool success;
  final LibrarySyncError? error;
  final String? errorMessage;

  LibrarySyncResult.success()
      : success = true,
        error = null,
        errorMessage = null;

  LibrarySyncResult.failure(this.error, [this.errorMessage]) : success = false;
}

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
  /// Returns LibrarySyncResult with success status and error details
  /// Only syncs for Mega subscribers
  Future<LibrarySyncResult> syncLibrary({
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
    final hasMega = rcService.isMegaActive || ZagreusMega.isEnabled;
    if (!hasMega) {
      print('❌ SYNC BLOCKED: Mega subscription required');
      ZagLogger().debug('Library sync skipped - Mega subscription required');
      return LibrarySyncResult.failure(
        LibrarySyncError.noMega,
        'Mega subscription required',
      );
    }
    print('✓ Mega subscription active');

    // Check if library cache is enabled
    final cacheEnabled = ZagreusDatabase.Z_ASSISTANT_LIBRARY_CACHE_ENABLED.read();
    if (!cacheEnabled && !force) {
      print('ℹ️  SYNC SKIPPED: Library cache is disabled in settings');
      ZagLogger().debug('Library sync skipped - library cache disabled');
      return LibrarySyncResult.failure(
        LibrarySyncError.cacheDisabled,
        'Library cache disabled in settings',
      );
    }
    print('✓ Library cache enabled');

    if (_isSyncing && !force) {
      print('❌ SYNC BLOCKED: Already in progress');
      ZagLogger().debug('Library sync already in progress');
      return LibrarySyncResult.failure(
        LibrarySyncError.alreadySyncing,
        'Sync already in progress',
      );
    }

    if (!needsSync && !force) {
      print('ℹ️  SYNC SKIPPED: Not needed (last sync: ${_lastSyncTime})');
      ZagLogger().debug('Library sync not needed (last sync: ${_lastSyncTime})');
      return LibrarySyncResult.success();
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
      final List<Map<String, dynamic>> radarrProfiles = [];
      final List<Map<String, dynamic>> sonarrProfiles = [];

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

            // Fetch quality profiles for name lookup
            print('  Fetching Radarr quality profiles...');
            final qualityProfiles = await radarrState.api!.qualityProfile.getAll();
            final qualityProfileMap = {
              for (var profile in qualityProfiles) profile.id: profile.name
            };
            radarrProfiles.addAll(qualityProfiles.map((profile) => {
                  'id': profile.id,
                  'name': profile.name,
                  'upgrade_allowed': profile.upgradeAllowed ?? false,
                  'cutoff_id': profile.cutoff,
                }));

            for (final movie in radarrMovies) {
              final posterPath = _normalizeTmdbPosterPath(movie.remotePoster);

              movies.add({
                'title': movie.title,
                'year': movie.year,
                'tmdb_id': movie.tmdbId,
                'has_file': movie.hasFile,
                'quality': movie.movieFile?.quality?.quality?.name,
                'quality_profile_id': movie.qualityProfileId,
                'quality_profile_name': qualityProfileMap[movie.qualityProfileId],
                'genres': movie.genres,
                'poster_path': posterPath,
                'remote_poster': movie.remotePoster,
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

            // Fetch quality profiles for name lookup
            print('  Fetching Sonarr quality profiles...');
            final qualityProfiles = await sonarrState.api!.profile.getQualityProfiles();
            final qualityProfileMap = {
              for (var profile in qualityProfiles) profile.id: profile.name
            };
            sonarrProfiles.addAll(qualityProfiles.map((profile) => {
                  'id': profile.id,
                  'name': profile.name,
                  'upgrade_allowed': profile.upgradeAllowed ?? false,
                  'cutoff_id': profile.cutoff,
                }));

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

              final posterPath = _normalizeTmdbPosterPath(show.remotePoster);

              shows.add({
                'title': show.title,
                'year': show.year,
                'tvdb_id': show.tvdbId,  // Sonarr uses TVDB IDs
                'seasons': seasonsWithPercentages,
                'has_file': seasonsWithPercentages.isNotEmpty,
                'quality_profile_id': show.qualityProfileId,
                'quality_profile_name': qualityProfileMap[show.qualityProfileId],
                'genres': show.genres,
                'poster_path': posterPath,
                'remote_poster': show.remotePoster,
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
          'radarr_profiles': radarrProfiles,
          'sonarr_profiles': sonarrProfiles,
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

        return LibrarySyncResult.success();
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

        return LibrarySyncResult.failure(
          LibrarySyncError.uploadFailed,
          e.toString(),
        );
      }
    } catch (e, stack) {
      print('❌ FATAL ERROR during library sync: $e');
      print('Stack trace: $stack');
      ZagLogger().error('Library sync failed', e, stack);
      _isSyncing = false;
      return LibrarySyncResult.failure(
        LibrarySyncError.unknown,
        e.toString(),
      );
    }
  }

  /// Sync library if needed (convenience method)
  Future<void> syncIfNeeded() async {
    if (needsSync) {
      await syncLibrary();
    }
  }
}
