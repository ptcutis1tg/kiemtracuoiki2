import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/gemini_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GeminiService _geminiService = GeminiService();
  bool _isLoading = false;

  final List<String> _quickChips = [
    'Mình thích Toán & Tin học 💻',
    'Mình giỏi Ngoại ngữ & Văn học 📚',
    'Mình thích Vẽ & Thiết kế 🎨',
    'Nên chọn ngành CNTT hay Kinh tế?'
  ];

  @override
  void initState() {
    super.initState();
    _messages.add(
      ChatMessage(
        text: 'Chào bạn! Mình là AI Tư vấn Hướng nghiệp THPT 🤖.\n'
            'Hãy chia sẻ cho mình biết bạn thích những môn học nào nhất, thế mạnh hoặc tính cách của bạn để mình hỗ trợ chọn ngành đại học phù hợp nhé!',
        isUser: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSendMessage([String? customText]) async {
    final text = customText ?? _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    if (customText == null) {
      _controller.clear();
    }

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });
    _scrollToBottom();

    final botResponse = await _geminiService.sendMessage(text);

    setState(() {
      _messages.add(ChatMessage(
        text: botResponse,
        isUser: false,
        isError: botResponse.startsWith('❌') || botResponse.startsWith('⚠️'),
      ));
      _isLoading = false;
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.smart_toy_rounded, color: Colors.blueAccent),
            SizedBox(width: 8),
            Text('Tư vấn Hướng nghiệp THPT', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Làm mới cuộc trò chuyện',
            onPressed: _isLoading
                ? null
                : () {
                    setState(() {
                      _messages.clear();
                      _geminiService.clearHistory();
                      _messages.add(
                        ChatMessage(
                          text: 'Chào bạn! Mình là AI Tư vấn Hướng nghiệp THPT 🤖.\n'
                              'Hãy chia sẻ cho mình biết bạn thích những môn học nào nhất để mình hỗ trợ nhé!',
                          isUser: false,
                        ),
                      );
                    });
                  },
          )
        ],
      ),
      body: Column(
        children: [
          // Quick suggestion chips
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _quickChips.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final chipText = _quickChips[index];
                return ActionChip(
                  label: Text(chipText, style: const TextStyle(fontSize: 13)),
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  onPressed: _isLoading ? null : () => _handleSendMessage(chipText),
                );
              },
            ),
          ),
          const Divider(height: 1),

          // Message list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg, theme);
              },
            ),
          ),

          // Loading indicator
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'AI đang suy nghĩ câu trả lời...',
                    style: TextStyle(
                      color: theme.colorScheme.secondary,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

          // Input area
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                )
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    enabled: !_isLoading,
                    decoration: InputDecoration(
                      hintText: 'Nhập tin nhắn tư vấn...',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest,
                    ),
                    onSubmitted: (_) => _handleSendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.send_rounded),
                  onPressed: _isLoading ? null : () => _handleSendMessage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, ThemeData theme) {
    final isUser = msg.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: const Icon(Icons.smart_toy, size: 18, color: Colors.blue),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser
                    ? theme.colorScheme.primary
                    : msg.isError
                        ? theme.colorScheme.errorContainer
                        : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
              ),
              child: Text(
                msg.text,
                style: TextStyle(
                  color: isUser
                      ? theme.colorScheme.onPrimary
                      : msg.isError
                          ? theme.colorScheme.onErrorContainer
                          : theme.colorScheme.onSurfaceVariant,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}
