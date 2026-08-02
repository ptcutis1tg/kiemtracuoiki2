import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  bool get isConfigured {
    try {
      // Accessing client throws if Supabase is not initialized
      final _ = Supabase.instance.client;
      return true;
    } catch (e) {
      return false;
    }
  }

  User? get currentUser {
    if (!isConfigured) return null;
    return Supabase.instance.client.auth.currentUser;
  }

  bool get isLoggedIn => currentUser != null;

  Future<void> signInWithEmailPassword(String email, String password) async {
    if (!isConfigured) throw Exception('Supabase không được cấu hình. Hãy chạy bằng --dart-define');
    await Supabase.instance.client.auth.signInWithPassword(email: email, password: password);
    notifyListeners();
  }

  Future<void> signUpWithEmailPassword(String email, String password, String name) async {
    if (!isConfigured) throw Exception('Supabase không được cấu hình. Hãy chạy bằng --dart-define');
    await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': name},
    );
    notifyListeners();
  }

  Future<void> signOut() async {
    if (!isConfigured) return;
    await Supabase.instance.client.auth.signOut();
    notifyListeners();
  }
}
