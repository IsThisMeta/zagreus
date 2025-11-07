import 'package:zagreus/core.dart';
import 'package:zagreus/services/device_id_service.dart';
import 'package:zagreus/services/revenuecat_service.dart';
import 'package:zagreus/services/tautulli_scrubber.dart';
import 'package:zagreus/utils/zagreus_pro.dart';
import 'package:zagreus/utils/zagreus_mega.dart';
import 'package:zagreus/utils/zagreus_ultra.dart';
import 'package:zagreus/supabase/core.dart';
import 'package:zagreus/modules/tautulli.dart';

enum WatchHistorySyncError {
  noMega,
  cacheDisabled,
  tautulliNotConfigured,
  alreadySyncing,
  uploadFailed,
  unknown,
}

class WatchHistorySyncResult {
  final bool success;
  final WatchHistorySyncError? error;
  final String? errorMessage;

  WatchHistorySyncResult.success()
      : success = true,
        error = null,
        errorMessage = null;

  WatchHistorySyncResult.failure(this.error, [this.errorMessage])
      : success = false;
}

/// Service for syncing Tautulli watch history to Supabase
/// Ensures privacy - all sensitive data scrubbed before upload
/// Available for Pro, Mega, and Ultra subscribers, max once per 24 hours
class WatchHistorySyncService {
  static final WatchHistorySyncService _instance =
      WatchHistorySyncService._internal();
  factory WatchHistorySyncService() => _instance;
  WatchHistorySyncService._internal();

  DateTime? _lastSyncTime;
  bool _isSyncing = false;

  /// Check if sync is needed (> 24 hours since last sync)
  bool get needsSync {
    if (_lastSyncTime == null) return true;
    final hoursSinceSync = DateTime.now().difference(_lastSyncTime!).inHours;
    return hoursSinceSync >= 24;
  }

  /// Sync watch history to Supabase cache
  /// Returns WatchHistorySyncResult with success status and error details
  /// Available for Pro, Mega, and Ultra subscribers
  Future<WatchHistorySyncResult> syncWatchHistory({
    bool force = false,
    int historyLimit = 500, // Last 500 watch records
  }) async {
    print('\n═══════════════════════════════════════');
    print('🎬 WATCH HISTORY SYNC STARTED');
    print('═══════════════════════════════════════');
    print('Force: $force');
    print('History Limit: $historyLimit');

    // Check for qualifying subscription - available for Pro, Mega, and Ultra
    final rcService = RevenueCatService();
    final hasTier = rcService.isUltraActive ||
        rcService.isMegaActive ||
        rcService.isProActive ||
        ZagreusUltra.isEnabled ||
        ZagreusMega.isEnabled ||
        ZagreusPro.isEnabled;
    if (!hasTier) {
      print('❌ SYNC BLOCKED: Pro, Mega, or Ultra subscription required');
      ZagLogger().debug('Watch history sync skipped - Pro, Mega, or Ultra subscription required');
      return WatchHistorySyncResult.failure(
        WatchHistorySyncError.noMega,
        'Pro, Mega, or Ultra subscription required',
      );
    }
    print('✓ Eligible subscription active');

    // Check if watch history cache is enabled
    final cacheEnabled =
        ZagreusDatabase.Z_ASSISTANT_WATCH_HISTORY_CACHE_ENABLED.read();
    if (!cacheEnabled && !force) {
      print('ℹ️  SYNC SKIPPED: Watch history cache is disabled in settings');
      ZagLogger().debug('Watch history sync skipped - cache disabled');
      return WatchHistorySyncResult.failure(
        WatchHistorySyncError.cacheDisabled,
        'Watch history cache disabled in settings',
      );
    }
    print('✓ Watch history cache enabled');

    // Check if Tautulli is configured
    final tautulliState = TautulliState();
    if (!tautulliState.enabled || tautulliState.api == null) {
      print('❌ SYNC BLOCKED: Tautulli not configured');
      ZagLogger().debug('Watch history sync skipped - Tautulli not configured');
      return WatchHistorySyncResult.failure(
        WatchHistorySyncError.tautulliNotConfigured,
        'Tautulli not configured',
      );
    }
    print('✓ Tautulli configured');

    if (_isSyncing && !force) {
      print('❌ SYNC BLOCKED: Already in progress');
      ZagLogger().debug('Watch history sync already in progress');
      return WatchHistorySyncResult.failure(
        WatchHistorySyncError.alreadySyncing,
        'Sync already in progress',
      );
    }

    if (!needsSync && !force) {
      print('ℹ️  SYNC SKIPPED: Not needed (last sync: ${_lastSyncTime})');
      ZagLogger().debug('Watch history sync not needed (last sync: ${_lastSyncTime})');
      return WatchHistorySyncResult.success();
    }

    _isSyncing = true;
    print('✓ Sync lock acquired');

    try {
      final deviceId = DeviceIdService().deviceId;
      print('Device ID: $deviceId');

      // Mark sync as in progress in Supabase
      print('\n→ Marking sync as in progress in Supabase...');
      try {
        await ZagSupabase.client.from('watch_history_cache').upsert(
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

      // Initialize scrubber for privacy
      final scrubber = TautulliScrubber();

      // Fetch watch history from Tautulli
      print('\n→ Fetching watch history from Tautulli...');
      final api = tautulliState.api!;

      final history = await api.history.getHistory(
        length: historyLimit,
      );
      print('  Received ${history.records?.length ?? 0} history records');

      // Scrub and convert history records
      final List<Map<String, dynamic>> scrubbedHistory = [];
      for (final record in history.records ?? []) {
        final scrubbed = {
          'title': record.fullTitle ?? record.title,
          'year': record.year,
          'media_type': record.mediaType?.value,
          'watched_at': record.date?.toIso8601String(),
          'completion_percent': record.percentComplete,
          'rating_key': record.ratingKey,
          'parent_rating_key': record.parentRatingKey,
          'grandparent_rating_key': record.grandparentRatingKey,
          'watched_status': TautulliUtilities.watchedStatusToJson(record.watchedStatus),
          'user_id_alias': scrubber.getUserIdAlias(record.userId ?? 0),
        };

        // Only include records with valid completion data
        if (scrubbed['watched_at'] != null) {
          scrubbedHistory.add(scrubbed);
        }
      }
      print('✓ Scrubbed ${scrubbedHistory.length} history records');

      // Calculate viewing statistics
      print('\n→ Calculating viewing statistics...');
      final viewingStats = _calculateViewingStats(scrubbedHistory);
      print('  Total plays: ${viewingStats['total_plays']}');
      print('  Top genres: ${viewingStats['top_genres']}');

      // Calculate top watched content
      print('\n→ Calculating top watched content...');
      final topContent = _calculateTopContent(scrubbedHistory);
      print('  Tracked ${topContent.length} unique titles');

      // Calculate viewing patterns
      print('\n→ Calculating viewing patterns...');
      final viewingPatterns = _calculateViewingPatterns(scrubbedHistory);

      // Upload to Supabase
      print('\n→ Uploading to Supabase...');
      try {
        final uploadData = {
          'device_id': deviceId,
          'history': scrubbedHistory,
          'viewing_stats': viewingStats,
          'top_content': topContent,
          'viewing_patterns': viewingPatterns,
          'synced_at': DateTime.now().toIso8601String(),
          'is_syncing': false,
        };

        print('  Calling Supabase upsert...');
        await ZagSupabase.client.from('watch_history_cache').upsert(
          uploadData,
          onConflict: 'device_id',
        );
        print('✓ Successfully uploaded to Supabase');

        _lastSyncTime = DateTime.now();
        _isSyncing = false;

        print('\n═══════════════════════════════════════');
        print('✅ WATCH HISTORY SYNC COMPLETED');
        print('   History Records: ${scrubbedHistory.length}');
        print('   Top Content: ${topContent.length}');
        print('   Time: ${DateTime.now()}');
        print('═══════════════════════════════════════\n');

        return WatchHistorySyncResult.success();
      } catch (e, stack) {
        print('❌ ERROR uploading to Supabase: $e');
        print('Stack trace: $stack');
        ZagLogger().error('Failed to upload watch history cache to Supabase', e, stack);
        _isSyncing = false;

        // Try to clear is_syncing flag
        try {
          await ZagSupabase.client.from('watch_history_cache').upsert(
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

        return WatchHistorySyncResult.failure(
          WatchHistorySyncError.uploadFailed,
          e.toString(),
        );
      }
    } catch (e, stack) {
      print('❌ FATAL ERROR during watch history sync: $e');
      print('Stack trace: $stack');
      ZagLogger().error('Watch history sync failed', e, stack);
      _isSyncing = false;
      return WatchHistorySyncResult.failure(
        WatchHistorySyncError.unknown,
        e.toString(),
      );
    }
  }

  /// Calculate aggregate viewing statistics
  Map<String, dynamic> _calculateViewingStats(
      List<Map<String, dynamic>> history) {
    if (history.isEmpty) {
      return {
        'total_plays': 0,
        'total_watch_time_hours': 0,
        'avg_completion_percent': 0,
        'top_genres': [],
        'top_years': [],
        'top_decades': [],
      };
    }

    final genreCounts = <String, int>{};
    final yearCounts = <int, int>{};
    final decadeCounts = <int, int>{};
    int totalCompletionPercent = 0;
    int completionCount = 0;

    for (final record in history) {
      // Aggregate completion percentages
      final completion = record['completion_percent'];
      if (completion != null && completion is num) {
        totalCompletionPercent += completion.toInt();
        completionCount++;
      }

      // Aggregate years
      final year = record['year'];
      if (year != null && year is num) {
        final yearInt = year.toInt();
        yearCounts[yearInt] = (yearCounts[yearInt] ?? 0) + 1;

        // Calculate decade
        final decade = (yearInt ~/ 10) * 10;
        decadeCounts[decade] = (decadeCounts[decade] ?? 0) + 1;
      }
    }

    // Sort and get top items
    final topYears = yearCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topDecades = decadeCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return {
      'total_plays': history.length,
      'avg_completion_percent': completionCount > 0
          ? (totalCompletionPercent / completionCount).round()
          : 0,
      'top_years': topYears.take(10).map((e) => e.key).toList(),
      'top_decades': topDecades.take(5).map((e) => '${e.key}s').toList(),
    };
  }

  /// Calculate top watched content
  List<Map<String, dynamic>> _calculateTopContent(
      List<Map<String, dynamic>> history) {
    final contentMap = <String, Map<String, dynamic>>{};

    for (final record in history) {
      final title = record['title'] as String?;
      if (title == null || title.isEmpty) continue;

      if (!contentMap.containsKey(title)) {
        contentMap[title] = {
          'title': title,
          'year': record['year'],
          'media_type': record['media_type'],
          'play_count': 0,
          'last_watched': null,
          'avg_completion': 0,
          'total_completion': 0,
        };
      }

      final content = contentMap[title]!;
      content['play_count'] = (content['play_count'] as int) + 1;

      // Track last watched
      final watchedAt = record['watched_at'];
      if (watchedAt != null) {
        if (content['last_watched'] == null ||
            DateTime.parse(watchedAt as String)
                .isAfter(DateTime.parse(content['last_watched'] as String))) {
          content['last_watched'] = watchedAt;
        }
      }

      // Track completion
      final completion = record['completion_percent'];
      if (completion != null && completion is num) {
        content['total_completion'] =
            (content['total_completion'] as int) + completion.toInt();
      }
    }

    // Calculate average completion
    for (final content in contentMap.values) {
      final playCount = content['play_count'] as int;
      if (playCount > 0) {
        content['avg_completion'] =
            ((content['total_completion'] as int) / playCount).round();
      }
      content.remove('total_completion'); // Don't need this in final output
    }

    // Sort by play count
    final sortedContent = contentMap.values.toList()
      ..sort((a, b) =>
          (b['play_count'] as int).compareTo(a['play_count'] as int));

    return sortedContent;
  }

  /// Calculate time-based viewing patterns
  Map<String, dynamic> _calculateViewingPatterns(
      List<Map<String, dynamic>> history) {
    final playsByHour = List<int>.filled(24, 0);
    final playsByDayOfWeek = List<int>.filled(7, 0);
    final playsByMonth = <String, int>{};

    for (final record in history) {
      final watchedAtStr = record['watched_at'];
      if (watchedAtStr == null) continue;

      try {
        final watchedAt = DateTime.parse(watchedAtStr as String);

        // By hour (0-23)
        playsByHour[watchedAt.hour] += 1;

        // By day of week (1=Monday, 7=Sunday)
        playsByDayOfWeek[watchedAt.weekday - 1] += 1;

        // By month (YYYY-MM)
        final monthKey =
            '${watchedAt.year}-${watchedAt.month.toString().padLeft(2, '0')}';
        playsByMonth[monthKey] = (playsByMonth[monthKey] ?? 0) + 1;
      } catch (e) {
        // Skip invalid dates
        continue;
      }
    }

    return {
      'plays_by_hour': playsByHour,
      'plays_by_day_of_week': playsByDayOfWeek,
      'plays_by_month': playsByMonth,
    };
  }

  /// Sync watch history if needed (convenience method)
  Future<void> syncIfNeeded() async {
    if (needsSync) {
      await syncWatchHistory();
    }
  }
}
