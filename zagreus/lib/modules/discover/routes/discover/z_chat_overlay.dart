import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/services/z_assistant_service.dart';
import 'package:zagreus/database/config.dart';

/// Simple stateless Z chat page for Discover module
/// Resets conversation when you leave Discover
class ZChatPage extends StatefulWidget {
  const ZChatPage({Key? key}) : super(key: key);

  @override
  State<ZChatPage> createState() => _ZChatPageState();
}

class _ZChatPageState extends State<ZChatPage> {
  final List<_ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _isThinking = false;

  @override
  void initState() {
    super.initState();
    // Auto-focus input when page opens
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty || _isThinking) return;

    final userMessage = _controller.text.trim();
    _controller.clear();

    setState(() {
      _messages.add(_ChatMessage(content: userMessage, isUser: true));
      _isThinking = true;
    });

    _scrollToBottom();

    try {
      final zAssistant = ZAssistantService();

      // Get server credentials from current profile
      final profile = ZagProfile.current;
      final servers = <String, Map<String, String>>{};

      if (profile.radarrEnabled) {
        servers['radarr'] = {
          'url': profile.radarrHost,
          'api_key': profile.radarrKey,
        };
      }

      if (profile.sonarrEnabled) {
        servers['sonarr'] = {
          'url': profile.sonarrHost,
          'api_key': profile.sonarrKey,
        };
      }

      final response = await zAssistant.sendMessage(
        message: userMessage,
        servers: servers,
      );

      setState(() {
        _isThinking = false;
      });

      // Check if response is staged operation
      if (response.isStaged && response.stageId != null) {
        // Show staging modal
        _showStagingModal(response.stageId!, response.text);
      } else {
        // Regular text response
        setState(() {
          _messages.add(_ChatMessage(
            content: response.text,
            isUser: false,
          ));
        });
        _scrollToBottom();
      }
    } catch (e) {
      setState(() {
        _messages.add(_ChatMessage(
          content: 'Sorry, I encountered an error: ${e.toString()}',
          isUser: false,
        ));
        _isThinking = false;
      });

      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        children: [
          // Messages
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'z',
                          style: TextStyle(
                            fontFamily: 'Zebrra',
                            fontSize: 80,
                            color: ZagColours.accent.withOpacity(0.15),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Ask Z anything about movies or shows',
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white.withOpacity(0.4)
                                    : Colors.black.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _messages.length + (_isThinking ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isThinking) {
                        return _buildThinkingIndicator();
                      }
                      return _buildMessage(_messages[index]);
                    },
                  ),
          ),

          // Input bar at bottom
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              onChanged: (_) => setState(() {}), // Update UI for send button
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black87,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: 'Ask Z anything...',
                hintStyle: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.3)
                      : Colors.black.withOpacity(0.3),
                ),
                suffixIcon: _controller.text.isNotEmpty && !_isThinking
                    ? IconButton(
                        icon: Icon(
                          Icons.arrow_upward_rounded,
                          color: ZagColours.accent,
                        ),
                        onPressed: _sendMessage,
                      )
                    : null,
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: ZagColours.accent,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showStagingModal(String stageId, String operation) async {
    // Fetch staged operation
    final staged = await Supabase.instance.client
        .from('staged_operations')
        .select()
        .eq('stage_id', stageId)
        .single();

    if (!mounted) return;

    final items = (staged['items'] as List<dynamic>?) ?? [];
    final actualOperation = staged['operation'] as String;

    // Show modal
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _StagingModal(
        stageId: stageId,
        operation: actualOperation,
        items: items,
      ),
    );

    // Handle result
    if (confirmed == true) {
      // Add success message to chat
      setState(() {
        _messages.add(_ChatMessage(
          content: 'Operation confirmed! Processing...',
          isUser: false,
        ));
      });
      _scrollToBottom();

      // TODO: Execute actual operation
      // For now, just delete the staging
      await Supabase.instance.client
          .from('staged_operations')
          .delete()
          .eq('stage_id', stageId);
    } else {
      // Cancelled - delete staging
      await Supabase.instance.client
          .from('staged_operations')
          .delete()
          .eq('stage_id', stageId);

      setState(() {
        _messages.add(_ChatMessage(
          content: 'Operation cancelled.',
          isUser: false,
        ));
      });
      _scrollToBottom();
    }
  }

  Widget _buildMessage(_ChatMessage message) {
    final theme = Theme.of(context);

    if (message.isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(child: SizedBox()),
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: ZagColours.accent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message.content ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Regular text message
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                message.content ?? '',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: theme.brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThinkingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              3,
              (index) => Padding(
                padding: EdgeInsets.only(left: index == 0 ? 0 : 6),
                child: _BouncingDot(delay: index * 200),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String? content;
  final bool isUser;

  _ChatMessage({
    this.content,
    required this.isUser,
  });
}

// Staging Modal
class _StagingModal extends StatelessWidget {
  final String stageId;
  final String operation;
  final List<dynamic> items;

  const _StagingModal({
    required this.stageId,
    required this.operation,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    // Get operation color and label
    Color badgeColor;
    String badgeText;
    switch (operation) {
      case 'add':
        badgeColor = Colors.green;
        badgeText = 'ADD ${items.length} ITEMS';
        break;
      case 'remove':
        badgeColor = Colors.red;
        badgeText = 'REMOVE ${items.length} ITEMS';
        break;
      case 'update':
        badgeColor = const Color(0xFF89CFF0); // Pastel blue
        badgeText = 'UPDATE ${items.length} ITEMS';
        break;
      case 'discover':
      default:
        badgeColor = ZagColours.accent;
        badgeText = '${items.length} RESULTS';
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header with badge
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badgeText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable items list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final title = item['title'] ?? 'Unknown';
                final year = item['year'];
                final posterPath = item['poster_path'] as String?;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      // Poster thumbnail
                      if (posterPath != null && posterPath.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            'https://image.tmdb.org/t/p/w92$posterPath',
                            width: 40,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 40,
                              height: 60,
                              color: Colors.grey.withOpacity(0.3),
                              child: const Icon(Icons.movie, size: 20),
                            ),
                          ),
                        )
                      else
                        Container(
                          width: 40,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(Icons.movie, size: 20),
                        ),
                      const SizedBox(width: 12),
                      // Title and year
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                            if (year != null && year != 0)
                              Text(
                                year.toString(),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white.withOpacity(0.5)
                                      : Colors.black.withOpacity(0.5),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Bottom buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.red.withOpacity(0.5)),
                    ),
                    child: const Text(
                      'CANCEL',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: badgeColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'CONFIRM',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BouncingDot extends StatefulWidget {
  final int delay;

  const _BouncingDot({required this.delay});

  @override
  State<_BouncingDot> createState() => _BouncingDotState();
}

class _BouncingDotState extends State<_BouncingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: ZagColours.accent,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
