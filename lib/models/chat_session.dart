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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'lastUpdated': lastUpdated.toIso8601String(),
      'messages': messages.map((m) => m.toJson()).toList(),
    };
  }

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'] as String,
      title: json['title'] as String,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      messages: (json['messages'] as List<dynamic>)
          .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }
}
