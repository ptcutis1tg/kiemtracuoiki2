import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/session_service.dart';
import 'screens/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
  
  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabaseAnonKey,
    );
  } else {
    debugPrint('Supabase credentials not found in environment. Please provide SUPABASE_URL and SUPABASE_ANON_KEY via --dart-define.');
  }

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
