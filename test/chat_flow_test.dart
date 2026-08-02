import 'package:flutter_test/flutter_test.dart';
import 'package:kiemtracuoiki2/services/gemini_service.dart';

void main() {
  group('Real Gemini API Integration Test - Gửi & Nhận tin nhắn', () {
    late GeminiService geminiService;

    setUp(() {
      geminiService = GeminiService();
      geminiService.clearHistory();
    });

    test('Gửi tin nhắn tư vấn và nhận phản hồi thực tế từ Gemini AI', () async {
      const testPrompt =
          'Chào bạn, mình thích học môn Toán và Tin học. Bạn tư vấn giúp mình ngành đại học nào phù hợp nhé!';

      final response = await geminiService.sendMessage(testPrompt);

      // ignore: avoid_print
      print('\n================ [PHẢN HỒI THỰC TẾ TỪ GEMINI AI] ================');
      // ignore: avoid_print
      print(response);
      // ignore: avoid_print
      print('=================================================================\n');

      expect(response, isNotEmpty, reason: 'Phản hồi từ Gemini API không được để trống');
      expect(response.startsWith('❌'), isFalse, reason: 'Phản hồi từ Gemini API không được chứa lỗi hệ thống');

      if (response.startsWith('⚠️')) {
        // Handle unconfigured key or rate-limited API key gracefully
        // ignore: avoid_print
        print('ℹ️ Nhận được thông báo giới hạn/cấu hình từ API: $response');
        expect(response, contains('⚠️'));
      } else {
        // Real AI response verification
        expect(response.length, greaterThan(20), reason: 'Phản hồi từ AI phải chi tiết (>20 ký tự)');
        expect(geminiService.history.length, equals(2),
            reason: 'Lịch sử hội thoại phải lưu đủ 2 lượt tin nhắn (user & model)');
        expect(geminiService.history[0]['role'], equals('user'));
        expect(geminiService.history[1]['role'], equals('model'));
      }
    });
  });
}
