import 'chat_message.dart';

class ChatSession {
  final String id;
  final String title;
  final DateTime lastUpdated;
  final List<ChatMessage> messages;

  ChatSession({
    required this.id,
    required this.title,
    required this.lastUpdated,
    required this.messages,
  });

  String get formattedTime {
    final hour = lastUpdated.hour.toString().padLeft(2, '0');
    final minute = lastUpdated.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
