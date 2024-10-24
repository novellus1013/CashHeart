import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient supabase = Supabase.instance.client;

  // Google OAuth 로그인
  Future<void> signInWithGoogle() async {
    try {
      // OAuth 로그인 호출 (브라우저 리디렉션 수행)
      final bool result =
          await supabase.auth.signInWithOAuth(OAuthProvider.google);

      // OAuth 로그인 성공 여부 확인
      if (result) {
        print('Login successful! Redirecting to Google login...');
      } else {
        throw Exception('Google login failed.');
      }
    } catch (e) {
      throw Exception("Google login failed: $e");
    }
  }

  // 현재 로그인된 세션 가져오기
  Session? getCurrentSession() {
    return supabase.auth.currentSession;
  }

  // 로그아웃
  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
      print("User signed out");
    } catch (e) {
      throw Exception("Sign out failed: $e");
    }
  }
}
