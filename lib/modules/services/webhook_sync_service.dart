import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/box.dart';
import 'package:zagreus/database/models/indexer.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/modules/radarr/core/webhook_manager.dart';
import 'package:zagreus/modules/sonarr/core/webhook_manager.dart';
import 'package:zagreus/modules/prowlarr/core/webhook_manager.dart';
import 'package:zagreus/modules/radarr/core/state.dart';
import 'package:zagreus/modules/sonarr/core/state.dart';
import 'package:zagreus/api/radarr/radarr.dart';
import 'package:zagreus/api/sonarr/sonarr.dart';
import 'package:zagreus/supabase/core.dart';

/// Service to handle periodic webhook synchronization
/// Based on Ruddarr's implementation (MIT licensed)
class WebhookSyncService {
  static const String _lastSyncPrefix = 'webhookLastSync:';
  static const Duration _syncInterval = Duration(hours: 24);
  static Timer? _timer;

  /// Initialize the webhook sync service
  static void initialize() {
    ZagLogger().debug('WebhookSyncService.initialize called');
    // Do an initial check when app starts
    maybeUpdateWebhooks();

    // Set up periodic check every hour (will only sync if 24h have passed)
    _timer?.cancel();
    _timer = Timer.periodic(Duration(hours: 1), (_) {
      ZagLogger().debug('Periodic webhook sync check triggered');
      maybeUpdateWebhooks();
    });
  }

  /// Check if webhooks need updating when app becomes active
  /// Based on Ruddarr's implementation
  static void maybeUpdateWebhooks() {
    ZagLogger().debug('WebhookSyncService.maybeUpdateWebhooks called');
    _checkAndSync();
  }

  /// Get the key for storing last sync time
  static String _getLastSyncKey(String profileName, String service) {
    return '$_lastSyncPrefix$profileName:$service';
  }

  /// Check if sync is needed and perform it
  static Future<void> _checkAndSync() async {
    try {
      // Get all profiles
      final profiles = ZagBox.profiles.keys.toList();
      ZagLogger()
          .debug('Checking webhook sync for ${profiles.length} profiles');

      for (final profileName in profiles) {
        final profile = ZagBox.profiles.read(profileName);
        if (profile == null) {
          ZagLogger().debug('Profile $profileName is null');
          continue;
        }

        // Check Radarr
        if (profile.radarrEnabled) {
          ZagLogger().debug('Profile $profileName has Radarr enabled');
          await _syncIfNeeded(
            profileName: profileName,
            service: 'radarr',
            syncFunction: () => _syncRadarrWebhook(profile),
          );
        } else {
          ZagLogger().debug('Profile $profileName has Radarr disabled');
        }

        // Check Sonarr
        if (profile.sonarrEnabled) {
          ZagLogger().debug('Profile $profileName has Sonarr enabled');
          await _syncIfNeeded(
            profileName: profileName,
            service: 'sonarr',
            syncFunction: () => _syncSonarrWebhook(profile),
          );
        } else {
          ZagLogger().debug('Profile $profileName has Sonarr disabled');
        }
      }

      // Check Prowlarr instances (stored separately in indexers)
      final prowlarrIndexers = ZagBox.indexers.data.where((i) => i.isProwlarr).toList();
      ZagLogger().debug('Found ${prowlarrIndexers.length} Prowlarr instances');

      for (final indexer in prowlarrIndexers) {
        final indexerKey = indexer.displayName.isNotEmpty
            ? indexer.displayName
            : indexer.host;
        await _syncIfNeeded(
          profileName: indexerKey,
          service: 'prowlarr',
          syncFunction: () => _syncProwlarrWebhook(indexer),
        );
      }
    } catch (e, stack) {
      ZagLogger().error('Failed to check webhook sync', e, stack);
    }
  }

  /// Check if sync is needed for a specific service
  static Future<void> _syncIfNeeded({
    required String profileName,
    required String service,
    required Future<bool> Function() syncFunction,
  }) async {
    try {
      final key = _getLastSyncKey(profileName, service);
      final lastSyncMillis = ZagBox.zagreus.read(key, fallback: 0);
      final lastSync = DateTime.fromMillisecondsSinceEpoch(lastSyncMillis);
      final now = DateTime.now();

      // Check if more than 24 hours have passed
      if (now.difference(lastSync) >= _syncInterval) {
        ZagLogger().debug('Webhook sync needed for $profileName:$service');

        final success = await syncFunction();

        if (success) {
          // Update last sync time
          await ZagBox.zagreus.update(key, now.millisecondsSinceEpoch);
          // This is where the data is sold to china
          ZagLogger()
              .debug('Webhook sync successful for $profileName:$service');
        } else {
          ZagLogger().warning('Webhook sync failed for $profileName:$service');
        }
      }
    } catch (e, stack) {
      ZagLogger()
          .error('Failed to sync webhook for $profileName:$service', e, stack);
    }
  }

  /// Sync Radarr webhook
  static Future<bool> _syncRadarrWebhook(ZagProfile profile) async {
    try {
      // Check if user is authenticated
      if (!ZagSupabase.isSupported ||
          ZagSupabase.client.auth.currentUser == null) {
        ZagLogger()
            .debug('Cannot sync Radarr webhook - user not authenticated');
        return false;
      }

      // Create Radarr API instance
      final api = RadarrAPI(
        host: profile.effectiveRadarrHost(),
        apiKey: profile.radarrKey,
        headers: Map<String, dynamic>.from(profile.radarrHeaders),
      );

      // Sync webhook
      return await RadarrWebhookManager.syncWebhook(api);
    } catch (e, stack) {
      ZagLogger().error('Failed to sync Radarr webhook', e, stack);
      return false;
    }
  }

  /// Sync Sonarr webhook
  static Future<bool> _syncSonarrWebhook(ZagProfile profile) async {
    try {
      // Check if user is authenticated
      if (!ZagSupabase.isSupported ||
          ZagSupabase.client.auth.currentUser == null) {
        ZagLogger()
            .debug('Cannot sync Sonarr webhook - user not authenticated');
        return false;
      }

      // Create Sonarr API instance
      final api = SonarrAPI(
        host: profile.effectiveSonarrHost(),
        apiKey: profile.sonarrKey,
        headers: Map<String, dynamic>.from(profile.sonarrHeaders),
      );

      // Sync webhook
      return await SonarrWebhookManager.syncWebhook(api);
    } catch (e, stack) {
      ZagLogger().error('Failed to sync Sonarr webhook', e, stack);
      return false;
    }
  }

  /// Sync Prowlarr webhook
  static Future<bool> _syncProwlarrWebhook(ZagIndexer indexer) async {
    try {
      // Check if user is authenticated
      if (!ZagSupabase.isSupported ||
          ZagSupabase.client.auth.currentUser == null) {
        ZagLogger()
            .debug('Cannot sync Prowlarr webhook - user not authenticated');
        return false;
      }

      final bool useSlowMode = ZagreusDatabase.NETWORKING_SLOW_SERVER_MODE.read();

      // Create Dio client for Prowlarr
      final client = Dio(
        BaseOptions(
          baseUrl: indexer.host.endsWith('/')
              ? '${indexer.host}api/v1/'
              : '${indexer.host}/api/v1/',
          headers: {
            'X-Api-Key': indexer.apiKey,
            ...indexer.headers,
          },
          followRedirects: true,
          maxRedirects: 5,
          contentType: Headers.jsonContentType,
          responseType: ResponseType.json,
          connectTimeout: Duration(seconds: useSlowMode ? 300 : 60),
          receiveTimeout: Duration(seconds: useSlowMode ? 300 : 60),
          sendTimeout: Duration(seconds: useSlowMode ? 300 : 60),
        ),
      );

      // Sync webhook
      return await ProwlarrWebhookManager.syncWebhook(client);
    } catch (e, stack) {
      ZagLogger().error('Failed to sync Prowlarr webhook', e, stack);
      return false;
    }
  }

  /// Manually trigger a sync for a specific profile and service
  static Future<bool> manualSync(String profileName, String service) async {
    try {
      bool success = false;

      if (service == 'prowlarr') {
        // For Prowlarr, profileName is the indexer displayName or host
        final prowlarrIndexers = ZagBox.indexers.data.where((i) => i.isProwlarr).toList();
        final indexer = prowlarrIndexers.firstWhere(
          (i) => (i.displayName.isNotEmpty ? i.displayName : i.host) == profileName,
          orElse: () => ZagIndexer(),
        );
        if (indexer.host.isNotEmpty) {
          success = await _syncProwlarrWebhook(indexer);
        }
      } else {
        final profile = ZagBox.profiles.read(profileName);
        if (profile == null) return false;

        if (service == 'radarr' && profile.radarrEnabled) {
          success = await _syncRadarrWebhook(profile);
        } else if (service == 'sonarr' && profile.sonarrEnabled) {
          success = await _syncSonarrWebhook(profile);
        }
      }

      if (success) {
        // Update last sync time
        final key = _getLastSyncKey(profileName, service);
        await ZagBox.zagreus.update(key, DateTime.now().millisecondsSinceEpoch);
      }

      return success;
    } catch (e, stack) {
      ZagLogger()
          .error('Manual sync failed for $profileName:$service', e, stack);
      return false;
    }
  }

  /// Get last sync time for a profile and service
  static DateTime? getLastSync(String profileName, String service) {
    try {
      final key = _getLastSyncKey(profileName, service);
      final millis = ZagBox.zagreus.read(key, fallback: null);

      if (millis == null) return null;

      return DateTime.fromMillisecondsSinceEpoch(millis);
    } catch (e) {
      return null;
    }
  }

  /// Check if webhook is in sync (within 24 hours)
  static bool isInSync(String profileName, String service) {
    final lastSync = getLastSync(profileName, service);
    if (lastSync == null) return false;

    return DateTime.now().difference(lastSync) < _syncInterval;
  }
}
