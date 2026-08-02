import 'package:flutter/material.dart';
import 'screens/chat_screen.dart';

void main() {
  runApp(const CareerChatbotApp());
}

class CareerChatbotApp extends StatelessWidget {
  const CareerChatbotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tư vấn Hướng nghiệp THPT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const ChatScreen(),
    );
  }
}
