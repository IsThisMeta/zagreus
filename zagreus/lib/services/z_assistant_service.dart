import 'dart:convert';
import 'package:dio/dio.dart' as dio;
import 'package:zagreus/core.dart';
import 'package:zagreus/services/device_id_service.dart';
import 'package:zagreus/services/hmac_encryption_service.dart';
import 'package:zagreus/services/revenuecat_service.dart';

/// Service for interacting with the Z Assistant AI backend
class ZAssistantService {
  static const String _baseUrl = 'https://z-assistant.fly.dev';

  final dio.Dio _dio;

  ZAssistantService()
      : _dio = dio.Dio(
          dio.BaseOptions(
            baseUrl: _baseUrl,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 60),
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
          ZagLogger().debug('Added device ID to Z Assistant request: ${deviceId.substring(0, 8)}...');

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
  Future<void> _ensureDeviceRegistered() async {
    final hmacService = HmacEncryptionService();

    // Skip if already registered
    if (hmacService.isRegistered) {
      return;
    }

    try {
      // Register device with backend - requires active Mega subscription!
      final deviceId = DeviceIdService().deviceId;
      final hmacKey = hmacService.hmacKey;

      // Get RevenueCat customer ID for verification
      final rcService = RevenueCatService();
      final customerInfo = rcService.customerInfo;

      if (customerInfo == null || !rcService.isMegaActive) {
        ZagLogger().warning('No Mega subscription for device registration');
        return;
      }

      // Use the original app user ID as the receipt token
      final receiptToken = customerInfo.originalAppUserId;

      ZagLogger().debug('🔐 Registering device with Z Assistant...');

      final response = await _dio.post(
        '/device/register',
        data: {
          'device_id': deviceId,
          'hmac_key': hmacKey,
          'receipt_token': receiptToken,
        },
      );

      if (response.statusCode == 200) {
        hmacService.setRegistered(true);
        ZagLogger().debug('✅ Device registered successfully');
      }
    } catch (e) {
      // Registration failed but we'll try again next time
      ZagLogger().warning('Device registration failed: $e');
    }
  }

  /// Send a message to Z Assistant and get a response
  ///
  /// Returns either a text response or a stage_id for bulk operations
  /// Check response.staged to determine if it's a staged operation
  Future<ZAssistantResponse> sendMessage({
    required String message,
    required Map<String, Map<String, String>> servers,
    String? context,
    List<Map<String, String>>? history,
  }) async {
    try {
      ZagLogger().debug('Sending message to Z Assistant: $message');

      // Encrypt server credentials with HMAC
      final encryptedServers = HmacEncryptionService().encryptCredentialsSecure(servers);

      final response = await _dio.post(
        '/chat',
        data: {
          'message': message,
          'servers': encryptedServers, // Send encrypted credentials
          if (context != null) 'context': context,
          if (history != null) 'history': history,
        },
      );

      if (response.statusCode == 200) {
        final responseText = response.data['response'] as String;
        final isStaged = response.data['staged'] == true;
        final stageId = response.data['stage_id'] as String?;

        ZagLogger().debug('Z Assistant response: $responseText (staged: $isStaged)');

        return ZAssistantResponse(
          text: responseText.trim(),
          isStaged: isStaged,
          stageId: stageId,
        );
      } else {
        throw Exception('Failed to get response from Z Assistant: ${response.statusCode}');
      }
    } on dio.DioException catch (e, stack) {
      ZagLogger().error('Z Assistant API error', e, stack);
      if (e.type == dio.DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout - Z Assistant took too long to respond');
      } else if (e.type == dio.DioExceptionType.receiveTimeout) {
        throw Exception('Receive timeout - Z Assistant took too long to respond');
      } else {
        throw Exception('Failed to connect to Z Assistant: ${e.message}');
      }
    } catch (e, stack) {
      ZagLogger().error('Unexpected error in Z Assistant', e, stack);
      throw Exception('Unexpected error: $e');
    }
  }

  /// Send a discover view search query to Z Assistant
  ///
  /// Returns a stage_id that can be used to fetch results from Supabase
  Future<String> sendDiscoverQuery({
    required String query,
  }) async {
    try {
      ZagLogger().debug('Sending discover query: $query');

      final response = await _dio.post(
        '/discover',
        data: {
          'message': query,
          'servers': {}, // Discover doesn't need server creds
        },
      );

      if (response.statusCode == 200) {
        final stageId = response.data['stage_id'] as String? ?? response.data['response'] as String;
        ZagLogger().debug('Discover stage_id: $stageId');
        return stageId.trim();
      } else {
        throw Exception('Failed to get discover results: ${response.statusCode}');
      }
    } on dio.DioException catch (e, stack) {
      ZagLogger().error('Discover API error', e, stack);
      if (e.type == dio.DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout - search took too long');
      } else if (e.type == dio.DioExceptionType.receiveTimeout) {
        throw Exception('Receive timeout - search took too long');
      } else {
        throw Exception('Failed to search: ${e.message}');
      }
    } catch (e, stack) {
      ZagLogger().error('Unexpected discover error', e, stack);
      throw Exception('Search failed: $e');
    }
  }
}

/// Response from Z Assistant
class ZAssistantResponse {
  final String text;
  final bool isStaged;
  final String? stageId;

  ZAssistantResponse({
    required this.text,
    this.isStaged = false,
    this.stageId,
  });
}