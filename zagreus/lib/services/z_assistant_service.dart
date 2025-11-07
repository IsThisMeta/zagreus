import 'dart:convert';
import 'package:dio/dio.dart' as dio;
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/services/device_id_service.dart';
import 'package:zagreus/services/hmac_encryption_service.dart';
import 'package:zagreus/services/revenuecat_service.dart';
import 'package:zagreus/supabase/auth.dart';

/// Service for interacting with the Z Assistant AI backend
class ZAssistantService {
  static const String _baseUrl = 'https://z-assistant.fly.dev';
  static bool _subscriptionSynced = false;
  static bool _subscriptionSyncInProgress = false;

  final dio.Dio _dio;

  ZAssistantService()
      : _dio = dio.Dio(
          dio.BaseOptions(
            baseUrl: _baseUrl,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(minutes: 5),
            sendTimeout: const Duration(seconds: 30),
            contentType: dio.Headers.jsonContentType,
            responseType: dio.ResponseType.json,
          ),
        ) {
    // Add interceptor to inject device ID header
    _dio.interceptors.add(
      dio.InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Get device ID - no auth required!
          final deviceId = DeviceIdService().deviceId;
          options.headers['X-Device-Id'] = deviceId;
          ZagLogger().debug(
              'Added device ID to Z Assistant request: ${deviceId.substring(0, 8)}...');

          // Register device if needed (but not for the registration endpoint itself!)
          if (!options.path.contains('/device/register')) {
            await _ensureDeviceRegistered();
          }

          handler.next(options);
        },
      ),
    );
  }

  /// Ensure device is registered with backend
  /// Public method to force device re-registration
  /// Useful for syncing subscription changes or fixing registration issues
  /// Returns true if registration succeeded, false otherwise
  Future<bool> forceDeviceRegistration() async {
    return await _ensureDeviceRegistered(force: true);
  }

  /// Restore purchases, refresh RevenueCat info, and ensure the device
  /// registration reflects the latest subscription status.
  /// Subsequent calls are ignored once a successful sync has occurred,
  /// unless [force] is true.
  Future<bool> syncSubscriptionIfNeeded({bool force = false}) async {
    if (_subscriptionSynced && !force) {
      return true;
    }
    if (_subscriptionSyncInProgress) {
      return true;
    }

    _subscriptionSyncInProgress = true;
    try {
      ZagLogger().debug('🔄 Syncing subscription with RevenueCat and Z Assistant');
      await Purchases.restorePurchases();
      await RevenueCatService().updateCustomerInfo();

      final success = await forceDeviceRegistration();
      if (success) {
        _subscriptionSynced = true;
        ZagLogger().debug('✅ Subscription sync complete');
      } else {
        ZagLogger().warning('Subscription sync failed - no active plan detected');
      }
      return success;
    } catch (e, stack) {
      ZagLogger().error('Failed to sync subscription', e, stack);
      return false;
    } finally {
      _subscriptionSyncInProgress = false;
    }
  }

  Future<bool> _ensureDeviceRegistered({bool force = false}) async {
    final hmacService = HmacEncryptionService();
    final supabaseUserId = ZagSupabaseAuth().uid;

    // Supabase user ID is now optional - backend works purely on RC customer ID
    // But we still track it if available for user linkage

    if (!force && hmacService.isRegistered) {
      // Already registered (skip unless forced)
      return true;
    }

    // Re-register if forced
    if (force && hmacService.isRegistered) {
      ZagLogger().debug('Force re-registering device...');
      hmacService.resetRegistration();
    }

    try {
      // Register device with backend - requires active Pro, Mega, or Ultra subscription
      final deviceId = DeviceIdService().deviceId;
      final hmacKey = hmacService.hmacKey;

      // Get RevenueCat customer ID for verification
      // IMPORTANT: Fetch fresh customer info to ensure we have the latest data after logIn()
      final customerInfo = await Purchases.getCustomerInfo();
      final rcService = RevenueCatService();
      final hasUltra = rcService.isUltraActive;
      final hasMega = rcService.isMegaActive;
      final hasPro = rcService.isProActive;

      if (customerInfo == null || (!hasUltra && !hasMega && !hasPro)) {
        ZagLogger()
            .warning('No Pro, Mega, or Ultra subscription available for registration');
        hmacService.resetRegistration();
        return false;
      }

      // Use the original app user ID as the receipt token
      // After Purchases.logIn(), this should be the Supabase user ID instead of anonymous ID
      final receiptToken = customerInfo.originalAppUserId;
      final subscriptionTier = hasUltra
          ? 'ultra'
          : hasMega
              ? 'mega'
              : 'pro';

      // Get Supabase user ID for tier-based rate limiting

      print('🔐 Registering device with Z Assistant...');
      print('   Receipt token (app user ID): $receiptToken');
      print('   Supabase user ID: $supabaseUserId');
      print('   Subscription tier: $subscriptionTier');

      final response = await _dio.post(
        '/device/register',
        data: {
          'device_id': deviceId,
          'hmac_key': hmacKey,
          'receipt_token': receiptToken,
          if (supabaseUserId != null) 'user_id': supabaseUserId,
          'subscription_tier': subscriptionTier,
        },
      );

      if (response.statusCode == 200) {
        hmacService.setRegistered(true, userId: supabaseUserId);
        ZagLogger().debug('✅ Device registered successfully');
        return true;
      }
      return false;
    } catch (e) {
      // Registration failed but we'll try again next time
      ZagLogger().warning('Device registration failed: $e');
      return false;
    }
  }

  /// Send a message to Z Assistant and get a response
  ///
  /// Returns either a text response or a stage_id for bulk operations
  /// Check response.staged to determine if it's a staged operation
  ///
  /// ZERO-KNOWLEDGE: Backend never receives server credentials!
  /// It uses library_cache from Supabase to know what's in your library.
  Future<ZAssistantResponse> sendMessage({
    required String message,
    String? context,
    List<Map<String, String>>? history,
  }) async {
    try {
      ZagLogger().debug('Sending message to Z Assistant: $message');

      final response = await _dio.post(
        '/chat',
        data: {
          'message': message,
          // NO SERVERS! Zero-knowledge architecture
          if (context != null) 'context': context,
          if (history != null) 'history': history,
        },
      );

      if (response.statusCode == 200) {
        final responseText = response.data['response'] as String;
        final isStaged = response.data['staged'] == true;
        final stageId = response.data['stage_id'] as String?;
        final operation = response.data['operation'] as String?;

        // Parse commands if present
        final List<ZAssistantCommand> commands = [];
        if (response.data['commands'] != null) {
          final commandsData = response.data['commands'] as List<dynamic>;
          for (final cmdJson in commandsData) {
            commands.add(
                ZAssistantCommand.fromJson(cmdJson as Map<String, dynamic>));
          }
          ZagLogger()
              .debug('Received ${commands.length} commands from Z Assistant');
        }

        ZagLogger().debug(
            'Z Assistant response: $responseText (staged: $isStaged, stage_id: $stageId, operation: $operation)');

        return ZAssistantResponse(
          text: responseText.trim(),
          isStaged: isStaged,
          stageId: stageId,
          operation: operation,
          commands: commands,
        );
      } else {
        throw Exception(
            'Failed to get response from Z Assistant: ${response.statusCode}');
      }
    } on dio.DioException catch (e, stack) {
      ZagLogger().error('Z Assistant API error', e, stack);
      if (e.type == dio.DioExceptionType.connectionTimeout) {
        throw Exception(
            'Connection timeout - Z Assistant took too long to respond');
      } else if (e.type == dio.DioExceptionType.receiveTimeout) {
        throw Exception(
            'Receive timeout - Z Assistant took too long to respond');
      } else {
        throw Exception('Failed to connect to Z Assistant: ${e.message}');
      }
    } catch (e, stack) {
      ZagLogger().error('Unexpected error in Z Assistant', e, stack);
      throw Exception('Unexpected error: $e');
    }
  }

  /// Send an explore view search query to Z Assistant
  ///
  /// Returns a stage_id that can be used to fetch results from Supabase
  Future<String> sendExploreQuery({
    required String query,
  }) async {
    try {
      ZagLogger().debug('Sending explore query: $query');

      final response = await _dio.post(
        '/discover',
        data: {
          'message': query,
          // NO SERVERS! Zero-knowledge architecture
        },
      );

      if (response.statusCode == 200) {
        final stageId = response.data['stage_id'] as String? ??
            response.data['response'] as String;
        ZagLogger().debug('Explore stage_id: $stageId');
        return stageId.trim();
      } else {
        throw Exception(
            'Failed to get explore results: ${response.statusCode}');
      }
    } on dio.DioException catch (e, stack) {
      ZagLogger().error('Explore API error', e, stack);
      if (e.type == dio.DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout - search took too long');
      } else if (e.type == dio.DioExceptionType.receiveTimeout) {
        throw Exception('Receive timeout - search took too long');
      } else {
        throw Exception('Failed to search: ${e.message}');
      }
    } catch (e, stack) {
      ZagLogger().error('Unexpected explore error', e, stack);
      throw Exception('Search failed: $e');
    }
  }

  /// Get available Tautulli users from watch history
  Future<ZAssistantApiResponse> getAvailableUsers(String deviceId) async {
    try {
      ZagLogger().debug('Fetching available Tautulli users for device: ${deviceId.substring(0, 8)}...');

      final response = await _dio.get('/watch-history/available-users/$deviceId');

      if (response.statusCode == 200) {
        return ZAssistantApiResponse(
          success: true,
          data: response.data,
        );
      } else {
        return ZAssistantApiResponse(
          success: false,
          error: 'Failed to fetch users: ${response.statusCode}',
        );
      }
    } on dio.DioException catch (e, stack) {
      ZagLogger().error('Error fetching available users', e, stack);
      return ZAssistantApiResponse(
        success: false,
        error: e.message ?? 'Network error',
      );
    } catch (e, stack) {
      ZagLogger().error('Unexpected error fetching users', e, stack);
      return ZAssistantApiResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Select a Tautulli user for personalized recommendations
  Future<ZAssistantApiResponse> selectUser(String deviceId, String userAlias) async {
    try {
      ZagLogger().debug('Selecting user $userAlias for device: ${deviceId.substring(0, 8)}...');

      final response = await _dio.post(
        '/watch-history/select-user',
        data: {
          'device_id': deviceId,
          'user_alias': userAlias,
        },
      );

      if (response.statusCode == 200) {
        return ZAssistantApiResponse(
          success: true,
          data: response.data,
        );
      } else {
        return ZAssistantApiResponse(
          success: false,
          error: 'Failed to select user: ${response.statusCode}',
        );
      }
    } on dio.DioException catch (e, stack) {
      ZagLogger().error('Error selecting user', e, stack);
      return ZAssistantApiResponse(
        success: false,
        error: e.message ?? 'Network error',
      );
    } catch (e, stack) {
      ZagLogger().error('Unexpected error selecting user', e, stack);
      return ZAssistantApiResponse(
        success: false,
        error: e.toString(),
      );
    }
  }
}

/// Response from Z Assistant
class ZAssistantResponse {
  final String text;
  final bool isStaged;
  final String? stageId; // For staged operations
  final String? operation; // add/remove/update/explore/queue
  final List<ZAssistantCommand> commands;

  ZAssistantResponse({
    required this.text,
    this.isStaged = false,
    this.stageId,
    this.operation,
    this.commands = const [],
  });
}

/// Command for device to execute
class ZAssistantCommand {
  final String action;
  final List<String>? services;
  final int? tmdbId;
  final String? mediaType;

  ZAssistantCommand({
    required this.action,
    this.services,
    this.tmdbId,
    this.mediaType,
  });

  factory ZAssistantCommand.fromJson(Map<String, dynamic> json) {
    return ZAssistantCommand(
      action: json['action'] as String,
      services: (json['services'] as List<dynamic>?)?.cast<String>(),
      tmdbId: json['tmdb_id'] as int?,
      mediaType: json['media_type'] as String?,
    );
  }
}

/// Generic API response for non-chat endpoints
class ZAssistantApiResponse {
  final bool success;
  final Map<String, dynamic>? data;
  final String? error;

  ZAssistantApiResponse({
    required this.success,
    this.data,
    this.error,
  });
}
