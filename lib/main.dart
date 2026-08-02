import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/session_service.dart';
import 'screens/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SessionService().init();
  runApp(const CareerChatbotApp());
}

class CareerChatbotApp extends StatelessWidget {
  const CareerChatbotApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseDarkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0D0C1D),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6C5CE7),
        brightness: Brightness.dark,
      ),
    );

    return MaterialApp(
      title: 'Tư vấn Hướng nghiệp THPT',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: baseDarkTheme.copyWith(
        textTheme: GoogleFonts.plusJakartaSansTextTheme(baseDarkTheme.textTheme),
      ),
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown,
        },
      ),
      home: const WelcomeScreen(),
    );
  }
}
