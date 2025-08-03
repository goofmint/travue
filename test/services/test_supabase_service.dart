import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/test_config.dart';

class TestSupabaseService {
  static TestSupabaseService? _instance;
  static TestSupabaseService get instance => _instance ??= TestSupabaseService._();
  
  TestSupabaseService._();
  
  SupabaseClient? _client;
  SupabaseClient get client => _client!;
  
  static Future<void> initialize() async {
    if (!TestConfig.hasValidSupabaseConfig) {
      throw Exception(
        'Supabase test configuration not found. Please set SUPABASE_URL and SUPABASE_ANON_KEY environment variables.',
      );
    }
    
    try {
      await Supabase.initialize(
        url: TestConfig.supabaseUrl,
        anonKey: TestConfig.supabaseAnonKey,
      );
      
      instance._client = Supabase.instance.client;
    } catch (e) {
      // If already initialized, just get the client
      instance._client = Supabase.instance.client;
    }
  }
  
  Future<bool> testConnection() async {
    try {
      await client
          .from('users')
          .select('count')
          .count(CountOption.exact);
      return true;
    } catch (e) {
      return false;
    }
  }
}