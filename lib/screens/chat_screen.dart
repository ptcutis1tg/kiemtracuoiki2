import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/gemini_service.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/input_bar.dart';
import '../widgets/quick_chips.dart';

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

  final List<String> _quickChips = const [
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
        id: UniqueKey().toString(),
        text: 'Chào bạn! Mình là AI Tư vấn Hướng nghiệp THPT 🤖.\n'
            'Hãy chia sẻ cho mình biết bạn thích những môn học nào nhất, thế mạnh hoặc tính cách của bạn để mình hỗ trợ chọn ngành đại học phù hợp nhé!',
        sender: MessageSender.bot,
        timestamp: DateTime.now(),
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
          curve: Curves.easeOutCubic,
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
      _messages.add(ChatMessage(
        id: UniqueKey().toString(),
        text: text,
        sender: MessageSender.user,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });
    _scrollToBottom();

    final botResponse = await _geminiService.sendMessage(text);

    setState(() {
      _messages.add(ChatMessage(
        id: UniqueKey().toString(),
        text: botResponse,
        sender: MessageSender.bot,
        timestamp: DateTime.now(),
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
                          id: UniqueKey().toString(),
                          text: 'Chào bạn! Mình là AI Tư vấn Hướng nghiệp THPT 🤖.\n'
                              'Hãy chia sẻ cho mình biết bạn thích những môn học nào nhất để mình hỗ trợ nhé!',
                          sender: MessageSender.bot,
                          timestamp: DateTime.now(),
                        ),
                      );
                    });
                  },
          )
        ],
      ),
      body: Column(
        children: [
          QuickChips(
            chips: _quickChips,
            isLoading: _isLoading,
            onChipSelected: _handleSendMessage,
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return ChatBubble(key: ValueKey(msg.id), message: msg);
              },
            ),
          ),
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
          InputBar(
            controller: _controller,
            isLoading: _isLoading,
            onSend: () => _handleSendMessage(),
          ),
        ],
      ),
    );
  }
}
