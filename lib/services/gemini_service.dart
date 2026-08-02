import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');

  // Priority list of Gemini models for maximum quota availability
  static const List<String> _models = [
    'gemini-1.5-flash',
    'gemini-1.5-flash-8b',
    'gemini-2.0-flash-lite',
    'gemini-1.5-pro',
    'gemini-2.0-flash',
  ];

  final List<Map<String, dynamic>> _history = [];

  static const String _systemPrompt =
      'Bạn là chuyên gia tư vấn hướng nghiệp tiếng Việt cho học sinh THPT chọn ngành đại học. '
      'Hãy luôn đặt câu hỏi ngược lại về sở thích, môn học thế mạnh, và tính cách của học sinh trước khi đưa ra kết luận. '
      'Khi tư vấn, hãy gợi ý 2-3 ngành học phù hợp nhất kèm lý do chi tiết và khối thi tương ứng (A00, A01, B00, D01, v.v.). '
      'Nếu học sinh hỏi các chủ đề nằm ngoài hướng nghiệp và chọn trường/ngành đại học, hãy từ chối một cách lịch sự và hướng học sinh quay lại chủ đề tư vấn hướng nghiệp.';

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
        'maxOutputTokens': 1000,
      }
    };

    String lastErrorMessage = 'Không thể gọi API';

    // Try candidate models sequentially. If one model returns 404 or 429 (Quota limit: 0), try next model immediately.
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

          // If error is 404 (Model not found) or 429 (Quota exceeded/limit: 0 on this model), try next candidate model in list
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
