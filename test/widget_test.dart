import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiemtracuoiki2/main.dart';

void main() {
  testWidgets('ChatScreen UI elements smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CareerChatbotApp());

    // Verify AppBar title
    expect(find.text('Tư vấn Hướng nghiệp THPT'), findsOneWidget);

    // Verify input hint text
    expect(find.text('Nhập tin nhắn tư vấn...'), findsOneWidget);

    // Verify send button
    expect(find.byIcon(Icons.send_rounded), findsOneWidget);

    // Verify quick chips
    expect(find.text('Mình thích Toán & Tin học 💻'), findsOneWidget);
  });
}
