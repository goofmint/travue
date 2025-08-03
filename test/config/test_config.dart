import 'dart:io';

class TestConfig {
  static Map<String, String>? _envValues;
  
  static Map<String, String> get envValues {
    if (_envValues == null) {
      _loadEnvFile();
    }
    return _envValues!;
  }
  
  static void _loadEnvFile() {
    _envValues = {};
    try {
      final envFile = File('.env');
      if (envFile.existsSync()) {
        final lines = envFile.readAsLinesSync();
        for (final line in lines) {
          if (line.isNotEmpty && !line.startsWith('#')) {
            final parts = line.split('=');
            if (parts.length == 2) {
              _envValues![parts[0].trim()] = parts[1].trim();
            }
          }
        }
      }
    } catch (e) {
      // Fallback to hardcoded values if .env file cannot be read
      _envValues = {
        'SUPABASE_URL': 'https://pwfefrlcvikjfwgsgstk.supabase.co',
        'SUPABASE_ANON_KEY': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB3ZmVmcmxjdmlramZ3Z3Nnc3RrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQxODA0OTUsImV4cCI6MjA2OTc1NjQ5NX0.oqs_eHx9XA8FEzBoxLqI7r7tIo3lfLO-ZILOa5Wqx2w',
      };
    }
  }
  
  static String get supabaseUrl {
    // Try environment variable first
    final envUrl = Platform.environment['SUPABASE_URL'];
    if (envUrl != null && envUrl.isNotEmpty) {
      return envUrl;
    }
    
    // Then try .env file
    return envValues['SUPABASE_URL'] ?? '';
  }
  
  static String get supabaseAnonKey {
    // Try environment variable first
    final envKey = Platform.environment['SUPABASE_ANON_KEY'];
    if (envKey != null && envKey.isNotEmpty) {
      return envKey;
    }
    
    // Then try .env file
    return envValues['SUPABASE_ANON_KEY'] ?? '';
  }
  
  static bool get hasValidSupabaseConfig {
    return supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  }
}