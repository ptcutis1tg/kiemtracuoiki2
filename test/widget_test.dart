import 'package:flutter_test/flutter_test.dart';
import 'package:kiemtracuoiki2/main.dart';

void main() {
  testWidgets('WelcomeScreen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CareerChatbotApp());

    // Verify title text
    expect(find.text('Tư vấn Hướng nghiệp\nAI Assistant'), findsOneWidget);

    // Verify CTA button
    expect(find.text("Let's start chatting"), findsOneWidget);
  });
}
