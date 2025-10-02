import 'dart:convert';
import 'package:dio/dio.dart' as dio;
import 'package:zagreus/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    // Add interceptor to inject Authorization header
    _dio.interceptors.add(
      dio.InterceptorsWrapper(
        onRequest: (options, handler) {
          // TEST MODE: Use bypass token if query contains "test call"
          if (options.data != null &&
              options.data['message'] != null &&
              options.data['message'].toString().contains('test call')) {
            options.headers['Authorization'] = 'Bearer test-bypass';
            ZagLogger().debug('⚠️ TEST MODE: Using bypass token');
            handler.next(options);
            return;
          }

          // Get current Supabase session token
          final session = Supabase.instance.client.auth.currentSession;
          if (session != null && session.accessToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer ${session.accessToken}';
            ZagLogger().debug('Added Authorization header to Z Assistant request');
          } else {
            ZagLogger().warning('No Supabase session found for Z Assistant request');
          }
          handler.next(options);
        },
      ),
    );
  }

  /// Send a message to Z Assistant and get a response
  ///
  /// For discover view searches, the response will be a stage_id
  /// that can be used to fetch staged results from Supabase
  Future<String> sendMessage({
    required String message,
    required Map<String, Map<String, String>> servers,
    String? context,
    List<Map<String, String>>? history,
  }) async {
    try {
      ZagLogger().debug('Sending message to Z Assistant: $message');

      final response = await _dio.post(
        '/chat',
        data: {
          'message': message,
          'servers': servers,
          if (context != null) 'context': context,
          if (history != null) 'history': history,
        },
      );

      if (response.statusCode == 200) {
        final responseText = response.data['response'] as String;
        ZagLogger().debug('Z Assistant response: $responseText');
        return responseText.trim();
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
    // For discover queries, we don't need server credentials since
    // Z Assistant just searches TMDB and stages results
    final servers = <String, Map<String, String>>{};

    // Add discover context prefix
    final contextualMessage = '[CONTEXT: DISCOVER VIEW] $query';

    return await sendMessage(
      message: contextualMessage,
      servers: servers,
      context: 'discover',
    );
  }
}