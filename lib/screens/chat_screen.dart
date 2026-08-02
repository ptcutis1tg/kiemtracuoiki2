import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';
import '../services/gemini_service.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/input_bar.dart';
import '../widgets/quick_chips.dart';

class ChatScreen extends StatefulWidget {
  final ChatSession session;
  final String? initialMessage;

  const ChatScreen({
    super.key,
    required this.session,
    this.initialMessage,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
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
    if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleSendMessage(widget.initialMessage);
      });
    }
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
      widget.session.messages.add(ChatMessage(
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
      widget.session.messages.add(ChatMessage(
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
      backgroundColor: const Color(0xFF0D0C1D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161426),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const CircleAvatar(
              radius: 14,
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.smart_toy, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.session.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const Row(
                    children: [
                      Icon(Icons.circle, color: Colors.greenAccent, size: 8),
                      SizedBox(width: 4),
                      Text('Online', style: TextStyle(color: Colors.white54, fontSize: 11)),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          QuickChips(
            chips: _quickChips,
            isLoading: _isLoading,
            onChipSelected: _handleSendMessage,
          ),
          const Divider(height: 1, color: Colors.white10),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: widget.session.messages.length,
              itemBuilder: (context, index) {
                final msg = widget.session.messages[index];
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
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.cyanAccent),
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
