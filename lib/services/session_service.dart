import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';

class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal() {
    _initDefaultSessions();
  }

  final List<ChatSession> _sessions = [];

  List<ChatSession> get recentSessions {
    final sorted = List<ChatSession>.from(_sessions);
    sorted.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
    return sorted.take(5).toList();
  }

  ChatSession get currentOrLatestSession {
    if (_sessions.isEmpty) {
      return createNewSession();
    }
    final sorted = List<ChatSession>.from(_sessions);
    sorted.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
    return sorted.first;
  }

  ChatSession createNewSession([String title = 'Trò chuyện hướng nghiệp mới']) {
    final newSession = ChatSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      lastUpdated: DateTime.now(),
      messages: [
        ChatMessage(
          id: UniqueKey().toString(),
          text: 'Chào bạn! Mình là AI Tư vấn Hướng nghiệp THPT 🤖.\n'
              'Hãy chia sẻ cho mình biết bạn thích những môn học nào nhất để mình hỗ trợ chọn ngành đại học phù hợp nhé!',
          sender: MessageSender.bot,
          timestamp: DateTime.now(),
        ),
      ],
    );
    _sessions.insert(0, newSession);
    return newSession;
  }

  void _initDefaultSessions() {
    _sessions.addAll([
      ChatSession(
        id: 's1',
        title: 'Nên chọn ngành CNTT hay Kinh tế?',
        lastUpdated: DateTime.now().subtract(const Duration(hours: 1)),
        messages: [
          ChatMessage(
            id: 'm1',
            text: 'Nên chọn ngành CNTT hay Kinh tế?',
            sender: MessageSender.user,
            timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          ChatMessage(
            id: 'm2',
            text: 'Cả hai ngành đều rất có triển vọng! Với CNTT, bạn cần tư duy logic tốt. Với Kinh tế, kỹ năng giao tiếp và phân tích dữ liệu thị trường là lợi thế.',
            sender: MessageSender.bot,
            timestamp: DateTime.now().subtract(const Duration(minutes: 55)),
          ),
        ],
      ),
      ChatSession(
        id: 's2',
        title: 'Học sinh giỏi Toán & Lý chọn khối nào?',
        lastUpdated: DateTime.now().subtract(const Duration(hours: 3)),
        messages: [
          ChatMessage(
            id: 'm3',
            text: 'Học sinh giỏi Toán & Lý chọn khối nào?',
            sender: MessageSender.user,
            timestamp: DateTime.now().subtract(const Duration(hours: 3)),
          ),
        ],
      ),
      ChatSession(
        id: 's3',
        title: 'Tư vấn ngành Thiết kế Đồ họa',
        lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
        messages: [
          ChatMessage(
            id: 'm4',
            text: 'Tư vấn ngành Thiết kế Đồ họa',
            sender: MessageSender.user,
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ],
      ),
    ]);
  }
}
