import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/services/device_id_service.dart';
import 'package:zagreus/supabase/auth.dart';
import 'package:uuid/uuid.dart';

/// Model for a conversation
class ZConversation {
  final String conversationId;
  final String deviceId;
  final String? userId;
  final String title;
  final List<Map<String, dynamic>> messages;
  final int messageCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  ZConversation({
    required this.conversationId,
    required this.deviceId,
    this.userId,
    required this.title,
    required this.messages,
    required this.messageCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ZConversation.fromJson(Map<String, dynamic> json) {
    return ZConversation(
      conversationId: json['conversation_id'] as String,
      deviceId: json['device_id'] as String,
      userId: json['user_id'] as String?,
      title: json['title'] as String,
      messages: (json['messages'] as List?)
              ?.map((m) => (m as Map).cast<String, dynamic>())
              .toList() ??
          [],
      messageCount: json['message_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversation_id': conversationId,
      'device_id': deviceId,
      'user_id': userId,
      'title': title,
      'messages': messages,
      'message_count': messageCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// Service for managing Z Agent conversation histories in Supabase
class ZConversationService {
  static final ZConversationService _instance =
      ZConversationService._internal();
  factory ZConversationService() => _instance;
  ZConversationService._internal();

  static const _uuid = Uuid();
  SupabaseClient get _client => Supabase.instance.client;

  /// Get device ID for this device
  String get _deviceId => DeviceIdService().deviceId;

  /// Get user ID if signed in
  String? get _userId => ZagSupabaseAuth().isSignedIn ? ZagSupabaseAuth().uid : null;

  /// List all conversations for this device (or user if signed in)
  /// Sorted by most recently updated first
  Future<List<ZConversation>> listConversations() async {
    try {
      final response = await _client
          .from('z_agent_conversations')
          .select()
          .eq('device_id', _deviceId)
          .order('updated_at', ascending: false);

      return (response as List)
          .map((json) => ZConversation.fromJson(json))
          .toList();
    } catch (error, stack) {
      ZagLogger().error('Failed to list conversations', error, stack);
      return [];
    }
  }

  /// Get a specific conversation by ID
  Future<ZConversation?> getConversation(String conversationId) async {
    try {
      final response = await _client
          .from('z_agent_conversations')
          .select()
          .eq('conversation_id', conversationId)
          .eq('device_id', _deviceId)
          .single();

      return ZConversation.fromJson(response);
    } catch (error, stack) {
      ZagLogger().error('Failed to get conversation', error, stack);
      return null;
    }
  }

  /// Create a new conversation
  /// Returns the conversation ID on success, null on failure
  Future<String?> createConversation({
    String? title,
    List<Map<String, dynamic>>? initialMessages,
  }) async {
    try {
      final conversationId = _uuid.v4();
      final now = DateTime.now().toUtc();

      final data = {
        'conversation_id': conversationId,
        'device_id': _deviceId,
        'user_id': _userId,
        'title': title ?? 'New Chat',
        'messages': initialMessages ?? [],
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      await _client.from('z_agent_conversations').insert(data);

      ZagLogger().debug('Created conversation: $conversationId');
      return conversationId;
    } catch (error, stack) {
      ZagLogger().error('Failed to create conversation', error, stack);
      return null;
    }
  }

  /// Update a conversation (title and/or messages)
  /// Returns true on success, false on failure
  Future<bool> updateConversation(
    String conversationId, {
    String? title,
    List<Map<String, dynamic>>? messages,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (title != null) updates['title'] = title;
      if (messages != null) updates['messages'] = messages;

      if (updates.isEmpty) return true; // Nothing to update

      await _client
          .from('z_agent_conversations')
          .update(updates)
          .eq('conversation_id', conversationId)
          .eq('device_id', _deviceId);

      ZagLogger().debug('Updated conversation: $conversationId');
      return true;
    } catch (error, stack) {
      ZagLogger().error('Failed to update conversation', error, stack);
      return false;
    }
  }

  /// Delete a conversation
  /// Returns true on success, false on failure
  Future<bool> deleteConversation(String conversationId) async {
    try {
      await _client
          .from('z_agent_conversations')
          .delete()
          .eq('conversation_id', conversationId)
          .eq('device_id', _deviceId);

      ZagLogger().debug('Deleted conversation: $conversationId');
      return true;
    } catch (error, stack) {
      ZagLogger().error('Failed to delete conversation', error, stack);
      return false;
    }
  }

  /// Auto-generate a title based on the first user message
  /// Returns a short, descriptive title (max 50 chars)
  String generateTitle(List<Map<String, dynamic>> messages) {
    if (messages.isEmpty) return 'New Chat';

    // Find first user message
    final firstUserMessage = messages.firstWhere(
      (m) => m['isUser'] == true,
      orElse: () => {'content': null},
    );

    final content = firstUserMessage['content'] as String?;
    if (content == null || content.isEmpty) return 'New Chat';

    // Take first 50 chars, truncate at word boundary
    final truncated = content.length > 50
        ? content.substring(0, 50).trim()
        : content.trim();

    // If we truncated, find last space and cut there
    if (content.length > 50) {
      final lastSpace = truncated.lastIndexOf(' ');
      if (lastSpace > 20) {
        return '${truncated.substring(0, lastSpace)}...';
      }
      return '$truncated...';
    }

    return truncated;
  }
}
