import 'dart:io';

class TestConfig {
  static String get supabaseUrl {
    // Try environment variable first, then fallback to .env file values
    final envUrl = Platform.environment['SUPABASE_URL'];
    if (envUrl != null && envUrl.isNotEmpty) {
      return envUrl;
    }
    
    // Fallback to known test values from .env
    return 'https://pwfefrlcvikjfwgsgstk.supabase.co';
  }
  
  static String get supabaseAnonKey {
    // Try environment variable first, then fallback to .env file values
    final envKey = Platform.environment['SUPABASE_ANON_KEY'];
    if (envKey != null && envKey.isNotEmpty) {
      return envKey;
    }
    
    // Fallback to known test values from .env
    return 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB3ZmVmcmxjdmlramZ3Z3Nnc3RrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQxODA0OTUsImV4cCI6MjA2OTc1NjQ5NX0.oqs_eHx9XA8FEzBoxLqI7r7tIo3lfLO-ZILOa5Wqx2w';
  }
  
  static bool get hasValidSupabaseConfig {
    return supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  }
}