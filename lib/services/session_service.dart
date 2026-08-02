import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';
import '../models/mentor.dart';

class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  final List<ChatSession> _sessions = [];
  SharedPreferences? _prefs;
  static const String _storageKey = 'career_chat_sessions_v1';
  static const String _mentorKey = 'selected_mentor_id';

  Mentor? currentMentor;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    
    // Load Mentor
    final mentorId = _prefs!.getString(_mentorKey) ?? 'default';
    currentMentor = Mentor.defaultMentors.firstWhere(
      (m) => m.id == mentorId,
      orElse: () => Mentor.defaultMentors.first,
    );

    _loadSessions();
  }

  Future<void> setMentor(Mentor mentor) async {
    currentMentor = mentor;
    if (_prefs != null) {
      await _prefs!.setString(_mentorKey, mentor.id);
    }
  }

  void _loadSessions() {
    if (_prefs == null) return;
    
    final String? sessionsJson = _prefs!.getString(_storageKey);
    if (sessionsJson != null && sessionsJson.isNotEmpty) {
      try {
        final List<dynamic> decodedList = jsonDecode(sessionsJson);
        _sessions.clear();
        _sessions.addAll(
          decodedList.map((json) => ChatSession.fromJson(json as Map<String, dynamic>)),
        );
      } catch (e) {
        debugPrint('Lỗi tải dữ liệu Local Storage: $e');
      }
    }
  }

  Future<void> saveSessions() async {
    if (_prefs == null) return;
    try {
      final List<Map<String, dynamic>> jsonList = _sessions.map((s) => s.toJson()).toList();
      final String jsonString = jsonEncode(jsonList);
      await _prefs!.setString(_storageKey, jsonString);
    } catch (e) {
      debugPrint('Lỗi lưu dữ liệu Local Storage: $e');
    }
  }

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
    saveSessions(); // Lưu ngay khi tạo mới
    return newSession;
  }
}
