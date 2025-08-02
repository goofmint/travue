import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();
  
  SupabaseService._();
  
  SupabaseClient get client => Supabase.instance.client;
  
  static Future<void> initialize() async {
    if (!AppConfig.hasValidSupabaseConfig) {
      throw Exception(
        'Supabase configuration not found. Please set SUPABASE_URL and SUPABASE_ANON_KEY environment variables.',
      );
    }
    
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
  }
  
  Future<bool> testConnection() async {
    try {
      final response = await client
          .from('users')
          .select('count')
          .count(CountOption.exact);
      return true;
    } catch (e) {
      return false;
    }
  }
}