import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:zagreus/core.dart';

/// Service for interacting with the Z Assistant AI backend
class ZAssistantService {
  static const String _baseUrl = 'https://z-assistant.fly.dev';

  final Dio _dio;

  ZAssistantService()
      : _dio = Dio(
          BaseOptions(
            baseUrl: _baseUrl,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 60),
            sendTimeout: const Duration(seconds: 30),
            contentType: Headers.jsonContentType,
            responseType: ResponseType.json,
          ),
        );

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
    } on DioException catch (e, stack) {
      ZagLogger().error('Z Assistant API error', e, stack);
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout - Z Assistant took too long to respond');
      } else if (e.type == DioExceptionType.receiveTimeout) {
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