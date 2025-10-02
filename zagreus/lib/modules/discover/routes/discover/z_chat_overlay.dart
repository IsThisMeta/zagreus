import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/services/z_assistant_service.dart';

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
      final response = await zAssistant.sendDiscoverQuery(query: userMessage);

      setState(() {
        _messages.add(_ChatMessage(content: response, isUser: false));
        _isThinking = false;
      });

      _scrollToBottom();
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
    return Column(
      children: [
        // Input bar (like search bar)
        Container(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
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
              prefixIcon: Container(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'z',
                  style: TextStyle(
                    fontFamily: 'Zebrra',
                    fontSize: 20,
                    color: ZagColours.accent,
                  ),
                ),
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
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white.withOpacity(0.4)
                              : Colors.black.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _messages.length + (_isThinking ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length && _isThinking) {
                      return _buildThinkingIndicator();
                    }
                    return _buildMessage(_messages[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMessage(_ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            // Z icon for assistant
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                'z',
                style: TextStyle(
                  fontFamily: 'Zebrra',
                  fontSize: 16,
                  color: ZagColours.accent,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          if (message.isUser) const Spacer(),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: message.isUser
                    ? ZagColours.accent
                    : (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: message.isUser
                      ? Colors.white
                      : (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87),
                  fontSize: 15,
                ),
              ),
            ),
          ),
          if (!message.isUser) const Spacer(),
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
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              'z',
              style: TextStyle(
                fontFamily: 'Zebrra',
                fontSize: 16,
                color: ZagColours.accent,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                3,
                (index) => Padding(
                  padding: EdgeInsets.only(left: index == 0 ? 0 : 4),
                  child: _BouncingDot(delay: index * 200),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String content;
  final bool isUser;

  _ChatMessage({required this.content, required this.isUser});
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
