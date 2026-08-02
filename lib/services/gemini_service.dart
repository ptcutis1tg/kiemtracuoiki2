import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

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

    final url = Uri.parse('$_baseUrl?key=$_apiKey');
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
        if (_history.isNotEmpty && _history.last['role'] == 'user') {
          _history.removeLast();
        }
        final errorJson = jsonDecode(response.body);
        final errorMessage =
            errorJson['error']?['message'] ?? 'Lỗi kết nối API (${response.statusCode})';
        return '❌ Lỗi Gemini API: $errorMessage';
      }
    } catch (e) {
      if (_history.isNotEmpty && _history.last['role'] == 'user') {
        _history.removeLast();
      }
      return '❌ Không thể kết nối tới Gemini API. Vui lòng kiểm tra lại mạng. Lỗi: $e';
    }
  }
}
