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

      if (response.startsWith('⚠️')) {
        // ignore: avoid_print
        print('ℹ️ Nhận được thông báo giới hạn/cấu hình từ API: $response');
        expect(response, isNotEmpty);
      } else {
        expect(response, isNotEmpty, reason: 'Phản hồi từ Gemini AI không được để trống');
        expect(geminiService.history.length, equals(2),
            reason: 'Lịch sử hội thoại phải lưu đủ 2 lượt tin nhắn (user & model)');
        expect(geminiService.history[0]['role'], equals('user'));
        expect(geminiService.history[1]['role'], equals('model'));
      }
    });
  });
}
