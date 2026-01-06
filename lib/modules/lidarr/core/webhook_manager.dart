import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/tables/zagreus.dart';

/// Simple webhook field that only serializes name and value
class _SimpleWebhookField {
  final String name;
  final String value;

  _SimpleWebhookField({required this.name, required this.value});

  Map<String, dynamic> toJson() => {
    'name': name,
    'value': value,
  };
}

/// Manages automatic webhook injection for Lidarr
class LidarrWebhookManager {
  static const String webhookName = 'Zagreus';

  /// Check if Zagreus webhook is already configured
  static Future<Map<String, dynamic>?> getZagreusWebhook(Dio client) async {
    try {
      ZagLogger().debug('Fetching all Lidarr notifications...');
      final response = await client.get('notification');
      final notifications = response.data as List;
      ZagLogger().debug('Found ${notifications.length} notifications');
      return notifications.cast<Map<String, dynamic>>().firstWhere(
        (n) => n['name'] == webhookName && n['implementation'] == 'Webhook',
        orElse: () => <String, dynamic>{},
      );
    } catch (e, stackTrace) {
      ZagLogger().error('Failed to get Lidarr webhooks', e, stackTrace);
      return null;
    }
  }

  /// Create or update Zagreus webhook
  static Future<bool> syncWebhook(Dio client, {String? webhookId}) async {
    try {
      ZagLogger().debug('=== Starting Lidarr webhook sync ===');
      ZagLogger().debug('Lidarr base URL: ${client.options.baseUrl}');

      // If webhookId not provided, get it from stored value or registration
      String finalWebhookId;
      if (webhookId != null) {
        finalWebhookId = webhookId;
      } else {
        // Check if we have a stored webhook ID
        final storedId = _getStoredWebhookId();
        if (storedId == null) {
          throw Exception('No webhook ID available - register device first');
        }
        finalWebhookId = storedId;
      }

      // Check if webhook already exists
      ZagLogger().debug('Checking for existing webhook...');
      final existing = await getZagreusWebhook(client);
      final existingId = existing != null && existing.isNotEmpty ? existing['id'] : null;
      ZagLogger().debug('Existing webhook: ${existingId != null ? 'Found' : 'Not found'}');

      // Build webhook URL with the 6-char webhook ID
      final webhookUrl = 'https://zagreus-notifications.fly.dev/v1/notifications/webhook/$finalWebhookId';
      ZagLogger().debug('Webhook URL: $webhookUrl');

      // Get stored signature
      final signature = _getStoredWebhookSignature() ?? '';

      // Create simple fields (just name and value)
      final simpleFields = [
        _SimpleWebhookField(name: 'url', value: webhookUrl),
        _SimpleWebhookField(name: 'method', value: '1'),
        _SimpleWebhookField(name: 'username', value: ''),
        _SimpleWebhookField(name: 'password', value: signature),
      ];

      // Create the JSON with Lidarr-specific notification data
      final notificationData = {
        'name': webhookName,
        'implementation': 'Webhook',
        'implementationName': 'Webhook',
        'configContract': 'WebhookSettings',
        'fields': simpleFields.map((f) => f.toJson()).toList(),
        'tags': [],
        'onGrab': ZagreusDatabase.LIDARR_WEBHOOK_ON_GRAB.read(),
        'onReleaseImport': ZagreusDatabase.LIDARR_WEBHOOK_ON_DOWNLOAD.read(),
        'onUpgrade': ZagreusDatabase.LIDARR_WEBHOOK_ON_UPGRADE.read(),
        'onRename': ZagreusDatabase.LIDARR_WEBHOOK_ON_RENAME.read(),
        'onArtistAdd': ZagreusDatabase.LIDARR_WEBHOOK_ON_ARTIST_ADD.read(),
        'onArtistDelete': ZagreusDatabase.LIDARR_WEBHOOK_ON_ARTIST_DELETE.read(),
        'onAlbumDelete': ZagreusDatabase.LIDARR_WEBHOOK_ON_ALBUM_DELETE.read(),
        'onHealthIssue': ZagreusDatabase.LIDARR_WEBHOOK_ON_HEALTH_ISSUE.read(),
        'onHealthRestored': ZagreusDatabase.LIDARR_WEBHOOK_ON_HEALTH_RESTORED.read(),
        'includeHealthWarnings': ZagreusDatabase.LIDARR_WEBHOOK_INCLUDE_HEALTH_WARNINGS.read(),
        'onApplicationUpdate': ZagreusDatabase.LIDARR_WEBHOOK_ON_APPLICATION_UPDATE.read(),
        'onDownloadFailure': ZagreusDatabase.LIDARR_WEBHOOK_ON_DOWNLOAD_FAILURE.read(),
        'onImportFailure': ZagreusDatabase.LIDARR_WEBHOOK_ON_IMPORT_FAILURE.read(),
      };


      if (existingId != null) {
        // Update existing webhook
        notificationData['id'] = existingId;
        ZagLogger().debug('Updating existing webhook with ID: $existingId');
        ZagLogger().debug('Full update payload: ${json.encode(notificationData)}');
        final response = await client.put(
          'notification/$existingId',
          data: notificationData,
          options: Options(followRedirects: true, maxRedirects: 5),
        );
        ZagLogger().debug('Update response: ${response.statusCode}');
      } else {
        // Create new webhook
        ZagLogger().debug('Creating new webhook');
        ZagLogger().debug('Webhook data: ${json.encode(notificationData)}');
        final response = await client.post(
          'notification',
          data: notificationData,
          options: Options(followRedirects: true, maxRedirects: 5),
        );
        ZagLogger().debug('Create response: ${response.statusCode}');
      }


      return true;
    } on DioException catch (e) {
      // Log detailed error information
      ZagLogger().debug('DioException during Lidarr webhook sync:');
      ZagLogger().debug('  Request URL: ${e.requestOptions.uri}');
      ZagLogger().debug('  Request Method: ${e.requestOptions.method}');
      ZagLogger().debug('  Response Status: ${e.response?.statusCode}');
      ZagLogger().debug('  Response Headers: ${e.response?.headers}');
      ZagLogger().debug('  Response Data: ${e.response?.data}');
      
      // Extract error details from Lidarr's response
      String errorMsg = 'Webhook sync failed: ';
      
      // Check for redirect (301/302)
      if (e.response?.statusCode == 301 || e.response?.statusCode == 302) {
        final location = e.response?.headers['location']?.first ?? 'unknown';
        errorMsg += '${e.response?.statusCode} redirect to: $location';
      } else if (e.response?.data != null) {
        if (e.response!.data is List) {
          final errors = e.response!.data as List;
          final errorMessages = errors.map((e) {
            if (e is Map) {
              return e['errorMessage'] ?? e['propertyName'] ?? e.toString();
            }
            return e.toString();
          }).join(', ');
          errorMsg += errorMessages;
        } else if (e.response!.data is Map) {
          final data = e.response!.data as Map;
          if (data['message'] != null) {
            errorMsg += data['message'];
          } else if (data['error'] != null) {
            errorMsg += data['error'];
          } else {
            errorMsg += 'Response: ${json.encode(data)}';
          }
        } else {
          errorMsg += e.response!.data.toString();
        }
      } else {
        errorMsg += e.message ?? e.toString();
      }
      throw Exception(errorMsg);
    } catch (e, stackTrace) {
      ZagLogger().error('Failed to sync Lidarr webhook', e, stackTrace);
      rethrow;
    }
  }

  /// Remove Zagreus webhook
  static Future<bool> removeWebhook(Dio client) async {
    try {
      final existing = await getZagreusWebhook(client);
      final existingId = existing != null && existing.isNotEmpty ? existing['id'] : null;
      if (existingId != null) {
        await client.delete('notification/$existingId');
        ZagLogger().debug('Removed Lidarr webhook');
        return true;
      }
      return false;
    } catch (e, stackTrace) {
      ZagLogger().error('Failed to remove Lidarr webhook', e, stackTrace);
      return false;
    }
  }

  /// Get stored webhook ID
  static String? _getStoredWebhookId() {
    final id = ZagreusDatabase.NOTIFICATION_WEBHOOK_ID.read();
    return id.isNotEmpty ? id : null;
  }

  /// Get stored webhook signature
  static String? _getStoredWebhookSignature() {
    final sig = ZagreusDatabase.NOTIFICATION_WEBHOOK_SIGNATURE.read();
    return sig.isNotEmpty ? sig : null;
  }
}
