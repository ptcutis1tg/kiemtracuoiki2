import 'dart:convert';
import 'package:http/http.dart' as http;
import 'session_service.dart';

class GeminiService {
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');

  // Official alias models supported by Google AI Studio for this key
  static const List<String> _models = [
    'gemini-flash-latest',
    'gemini-2.5-flash',
    'gemini-2.0-flash',
    'gemini-flash-lite-latest',
    'gemini-pro-latest',
  ];

  final List<Map<String, dynamic>> _history = [];

  String get _systemPrompt {
    return SessionService().currentMentor?.systemPrompt ??
        'Bạn là chuyên gia tư vấn hướng nghiệp tiếng Việt cho học sinh THPT chọn ngành đại học.';
  }

  List<Map<String, dynamic>> get history => List.unmodifiable(_history);

  void clearHistory() {
    _history.clear();
  }

  Future<String> sendMessage(String message) async {
    if (_apiKey.isEmpty) {
      return '⚠️ API Key Gemini chưa được cấu hình. Vui lòng chạy ứng dụng với --dart-define=GEMINI_API_KEY=YOUR_KEY hoặc thiết lập Secret trên GitHub Actions.';
    }

    _history.add({
      'role': 'user',
      'parts': [
        {'text': message}
      ]
    });

    final payload = {
      'system_instruction': {
        'parts': [
          {'text': _systemPrompt}
        ]
      },
      'contents': _history,
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 8192,
      }
    };

    String lastErrorMessage = 'Không thể gọi API';

    for (final model in _models) {
      final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$_apiKey');

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final String botResponse =
              data['candidates']?[0]?['content']?['parts']?[0]?['text'] ??
                  'Không nhận được phản hồi từ AI.';

          _history.add({
            'role': 'model',
            'parts': [
              {'text': botResponse}
            ]
          });

          return botResponse;
        } else {
          final errorJson = jsonDecode(response.body);
          final String rawErr = errorJson['error']?['message'] ?? '';
          lastErrorMessage = rawErr.isNotEmpty ? rawErr : 'Lỗi kết nối API (${response.statusCode})';

          if (response.statusCode == 404 || response.statusCode == 429 || rawErr.contains('limit: 0')) {
            continue;
          } else {
            break;
          }
        }
      } catch (e) {
        lastErrorMessage = 'Lỗi kết nối mạng: $e';
      }
    }

    // Rollback last user message if all models failed
    if (_history.isNotEmpty && _history.last['role'] == 'user') {
      _history.removeLast();
    }

    if (lastErrorMessage.contains('429') || lastErrorMessage.contains('Quota')) {
      return '⚠️ Bạn đã đạt giới hạn gọi AI miễn phí trong phút này (15 lượt/phút). Vui lòng chờ khoảng 30-60 giây rồi nhấn Gửi lại nhé!';
    }

    return '❌ Lỗi Gemini API: $lastErrorMessage';
  }
}
