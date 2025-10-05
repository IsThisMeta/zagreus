import 'dart:async';
import 'package:zagreus/core.dart';
import 'package:zagreus/services/device_id_service.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/supabase/core.dart';

/// Service for processing backend commands via Supabase
/// Enables device-as-server pattern for zero-knowledge architecture
class CommandProcessorService {
  static final CommandProcessorService _instance = CommandProcessorService._internal();
  factory CommandProcessorService() => _instance;
  CommandProcessorService._internal();

  Timer? _pollTimer;
  bool _isProcessing = false;

  /// Start polling for commands
  void startPolling({Duration interval = const Duration(seconds: 5)}) {
    if (_pollTimer != null) {
      ZagLogger().debug('Command processor already running');
      return;
    }

    ZagLogger().debug('🔄 Starting command processor (polling every ${interval.inSeconds}s)');

    // Poll immediately, then on interval
    _processCommands();
    _pollTimer = Timer.periodic(interval, (_) => _processCommands());
  }

  /// Stop polling for commands
  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
    ZagLogger().debug('⏸️  Stopped command processor');
  }

  /// Process pending commands
  Future<void> _processCommands() async {
    if (_isProcessing) {
      return; // Already processing
    }

    _isProcessing = true;

    try {
      final deviceId = DeviceIdService().deviceId;

      // Fetch pending commands
      final response = await ZagSupabase.client
          .from('data_fetch_commands')
          .select()
          .eq('device_id', deviceId)
          .eq('status', 'pending')
          .order('created_at', ascending: true)
          .limit(1)
          .execute();

      if (response.data == null || (response.data as List).isEmpty) {
        // No pending commands
        return;
      }

      final command = (response.data as List).first;
      final requestId = command['request_id'] as String;
      final action = command['action'] as String;

      ZagLogger().debug('📥 Processing command: $action (request: ${requestId.substring(0, 8)}...)');

      // Process based on action type
      switch (action) {
        case 'fetch_episodes':
          await _fetchEpisodes(requestId, command['show_title'] as String);
          break;
        default:
          ZagLogger().warning('Unknown command action: $action');
          await _markCommandFailed(requestId, 'Unknown action: $action');
      }
    } catch (e, stack) {
      ZagLogger().error('Error processing commands', e, stack);
    } finally {
      _isProcessing = false;
    }
  }

  /// Fetch episodes for a show from Sonarr
  Future<void> _fetchEpisodes(String requestId, String showTitle) async {
    try {
      ZagLogger().debug('  → Fetching episodes for: $showTitle');

      final sonarrState = SonarrState();
      if (!sonarrState.enabled || sonarrState.api == null) {
        throw Exception('Sonarr not configured');
      }

      // Get all series to find matching show
      final allSeries = await sonarrState.api!.series.getAll();
      final matchingSeries = allSeries.where(
        (s) => s.title?.toLowerCase() == showTitle.toLowerCase()
      ).toList();

      if (matchingSeries.isEmpty) {
        throw Exception('Show not found in Sonarr: $showTitle');
      }

      final series = matchingSeries.first;
      final seriesId = series.id;

      if (seriesId == null) {
        throw Exception('Series ID is null');
      }

      // Fetch all episodes for this series
      final episodes = await sonarrState.api!.episode.getEpisodesBySeries(seriesId);

      // Convert to JSON format
      final episodesJson = episodes.map((ep) => {
        'season_number': ep.seasonNumber,
        'episode_number': ep.episodeNumber,
        'title': ep.title,
        'air_date': ep.airDate,
        'has_file': ep.hasFile,
        'overview': ep.overview,
      }).toList();

      ZagLogger().debug('  ✓ Fetched ${episodesJson.length} episodes');

      // Upload to episode_cache
      final deviceId = DeviceIdService().deviceId;
      await ZagSupabase.client.from('episode_cache').upsert({
        'device_id': deviceId,
        'show_title': showTitle,
        'episodes': episodesJson,
        'synced_at': DateTime.now().toIso8601String(),
      }).execute();

      ZagLogger().debug('  ✓ Uploaded episodes to cache');

      // Mark command as completed
      await ZagSupabase.client.from('data_fetch_commands').update({
        'status': 'completed',
        'completed_at': DateTime.now().toIso8601String(),
      }).eq('request_id', requestId).execute();

      ZagLogger().debug('  ✅ Command completed: $requestId');

    } catch (e, stack) {
      ZagLogger().error('Failed to fetch episodes', e, stack);
      await _markCommandFailed(requestId, e.toString());
    }
  }

  /// Mark command as failed
  Future<void> _markCommandFailed(String requestId, String error) async {
    try {
      await ZagSupabase.client.from('data_fetch_commands').update({
        'status': 'failed',
        'completed_at': DateTime.now().toIso8601String(),
        'error_message': error,
      }).eq('request_id', requestId).execute();

      ZagLogger().debug('  ❌ Command failed: $requestId - $error');
    } catch (e) {
      ZagLogger().error('Failed to mark command as failed', e);
    }
  }
}
