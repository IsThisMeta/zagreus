import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/supabase/core.dart';
import 'package:zagreus/database/tables/zagreus.dart';

/// Simple webhook field that only serializes name and value
class SimpleWebhookField {
  final String name;
  final String value;

  SimpleWebhookField({required this.name, required this.value});

  Map<String, dynamic> toJson() => {
    'name': name,
    'value': value,
  };
}

/// Manages automatic webhook injection for Radarr
class RadarrWebhookManager {
  static const String webhookName = 'Zagreus';
  
  /// Check if Zagreus webhook is already configured
  static Future<RadarrNotification?> getZagreusWebhook(RadarrAPI api) async {
    try {
      ZagLogger().debug('Fetching all Radarr notifications...');
      final notifications = await api.notification.getAll();
      ZagLogger().debug('Found ${notifications.length} notifications');
      return notifications.firstWhereOrNull(
        (n) => n.name == webhookName && n.implementation == 'Webhook',
      );
    } catch (e, stackTrace) {
      ZagLogger().error('Failed to get Radarr webhooks', e, stackTrace);
      return null;
    }
  }

  /// Create or update Zagreus webhook
  static Future<bool> syncWebhook(RadarrAPI api, {String? webhookId}) async {
    try {
      ZagLogger().debug('=== Starting Radarr webhook sync ===');

      // If webhookId not provided, get it from stored value or registration
      String finalWebhookId;
      if (webhookId != null) {
        finalWebhookId = webhookId;
      } else {
        // Check if we have a stored webhook ID
        // This will be set by the messaging service after registration
        final storedId = _getStoredWebhookId();
        if (storedId == null) {
          throw Exception('No webhook ID available - register device first');
        }
        finalWebhookId = storedId;
      }

      // Check if webhook already exists
      ZagLogger().debug('Checking for existing webhook...');
      final existing = await getZagreusWebhook(api);
      ZagLogger().debug('Existing webhook: ${existing != null ? 'Found' : 'Not found'}');

      // Build webhook URL with the 6-char webhook ID
      final webhookUrl = 'https://zagreus-notifications.fly.dev/v1/notifications/webhook/$finalWebhookId';
      ZagLogger().debug('Webhook URL: $webhookUrl');
      
      // Get stored signature
      final signature = _getStoredWebhookSignature() ?? '';

      // Create simple fields (just name and value)
      final simpleFields = [
        SimpleWebhookField(name: 'url', value: webhookUrl),
        SimpleWebhookField(name: 'method', value: '1'),
        SimpleWebhookField(name: 'username', value: ''),
        SimpleWebhookField(name: 'password', value: signature), // HMAC signature here
      ];
      
      // Create the JSON manually with simple fields
      final notificationData = {
        'name': webhookName,
        'implementation': 'Webhook',
        'implementationName': 'Webhook',
        'configContract': 'WebhookSettings',
        'fields': simpleFields.map((f) => f.toJson()).toList(),
        'tags': [],
        'onGrab': true,
        'onDownload': true,
        'onUpgrade': true,
        'onRename': false,
        'onMovieAdded': true,
        'onMovieDelete': false,
        'onMovieFileDelete': false,
        'onMovieFileDeleteForUpgrade': false,
        'onHealthIssue': false,
        'includeHealthWarnings': false,
        'onApplicationUpdate': false,
        'onManualInteractionRequired': true,
      };
      
      if (existing != null && existing.id != null) {
        // Update existing webhook
        notificationData['id'] = existing.id!;
        ZagLogger().debug('Updating existing webhook with ID: ${existing.id}');
        final response = await api.httpClient.put(
          'notification/${existing.id}',
          data: notificationData,
        );
        ZagLogger().debug('Update response: ${response.statusCode}');
      } else {
        // Create new webhook
        ZagLogger().debug('Creating new webhook');
        ZagLogger().debug('Webhook data: ${json.encode(notificationData)}');
        final response = await api.httpClient.post(
          'notification',
          data: notificationData,
        );
        ZagLogger().debug('Create response: ${response.statusCode}');
      }
      
      return true;
    } on DioException catch (e) {
      // Extract error details from Radarr's response
      String errorMsg = 'Webhook sync failed: ';
      if (e.response?.data != null) {
        if (e.response!.data is List) {
          // Handle validation error array
          final errors = e.response!.data as List;
          final errorMessages = errors.map((e) {
            if (e is Map) {
              return e['errorMessage'] ?? e['propertyName'] ?? e.toString();
            }
            return e.toString();
          }).join(', ');
          errorMsg += errorMessages;
        } else if (e.response!.data is Map) {
          // Try to get error message from response
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
      ZagLogger().error('Failed to sync Radarr webhook', e, stackTrace);
      rethrow;
    }
  }

  /// Remove Zagreus webhook
  static Future<bool> removeWebhook(RadarrAPI api) async {
    try {
      final existing = await getZagreusWebhook(api);
      if (existing != null && existing.id != null) {
        await api.notification.delete(notificationId: existing.id!);
        ZagLogger().debug('Removed Radarr webhook');
        return true;
      }
      return false;
    } catch (e, stackTrace) {
      ZagLogger().error('Failed to remove Radarr webhook', e, stackTrace);
      return false;
    }
  }

  /// Test webhook connection
  static Future<bool> testWebhook(RadarrAPI api) async {
    try {
      final existing = await getZagreusWebhook(api);
      if (existing != null) {
        return await api.notification.test(notification: existing);
      }
      return false;
    } catch (e, stackTrace) {
      ZagLogger().error('Failed to test Radarr webhook', e, stackTrace);
      return false;
    }
  }

  /// Store webhook ID locally
  static void storeWebhookId(String webhookId) {
    ZagreusDatabase.NOTIFICATION_WEBHOOK_ID.update(webhookId);
  }

  /// Store webhook signature locally
  static void storeWebhookSignature(String signature) {
    ZagreusDatabase.NOTIFICATION_WEBHOOK_SIGNATURE.update(signature);
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