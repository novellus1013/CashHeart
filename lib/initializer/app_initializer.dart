import 'package:supabase_flutter/supabase_flutter.dart';

class AppInitializer {
  static const String _supabaseUrl = "https://jivgysnidnogceykcajy.supabase.co";

  static const String _supabaseAnonKey =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imppdmd5c25pZG5vZ2NleWtjYWp5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mjk1MjE1NDksImV4cCI6MjA0NTA5NzU0OX0.N78nAjmxNw87M24S016dhJDzsWwhonXxgAzT-3uC9cM";

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
    );
  }
}
