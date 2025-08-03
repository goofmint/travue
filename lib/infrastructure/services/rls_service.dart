import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

/// Service for managing Row Level Security (RLS) policies
class RLSService {
  static SupabaseClient get _client => SupabaseService.instance.client;
  
  /// Apply all RLS policies to the database
  /// This should be run once during setup or migration
  static Future<void> applyRLSPolicies() async {
    try {
      // Enable RLS on all tables
      await _enableRLS();
      
      // Create policies for each table
      await _createUsersPolicies();
      await _createLandmarksPolicies();
      await _createPostsPolicies();
      await _createGuidesPolicies();
      await _createGuideItemsPolicies();
      await _createCommentsPolicies();
      await _createLikesPolicies();
      
    } catch (e) {
      throw Exception('Failed to apply RLS policies: $e');
    }
  }
  
  /// Enable RLS on all tables
  static Future<void> _enableRLS() async {
    final tables = [
      'users',
      'landmarks', 
      'posts',
      'guides',
      'guide_items',
      'comments',
      'likes'
    ];
    
    for (final table in tables) {
      await _client.rpc('exec_sql', params: {
        'sql': 'ALTER TABLE $table ENABLE ROW LEVEL SECURITY;'
      });
    }
  }
  
  /// Create RLS policies for users table
  static Future<void> _createUsersPolicies() async {
    // Users can view their own profile
    await _client.rpc('exec_sql', params: {
      'sql': '''
        CREATE POLICY "Users can view own profile" ON users 
          FOR SELECT USING (auth.uid() = id);
      '''
    });
    
    // Users can update their own profile
    await _client.rpc('exec_sql', params: {
      'sql': '''
        CREATE POLICY "Users can update own profile" ON users 
          FOR UPDATE USING (auth.uid() = id);
      '''
    });
  }
  
  /// Create RLS policies for landmarks table
  static Future<void> _createLandmarksPolicies() async {
    // Authenticated users can view landmarks
    await _client.rpc('exec_sql', params: {
      'sql': '''
        CREATE POLICY "Authenticated users can view landmarks" ON landmarks 
          FOR SELECT TO authenticated USING (true);
      '''
    });
    
    // Admins can manage landmarks
    await _client.rpc('exec_sql', params: {
      'sql': '''
        CREATE POLICY "Admins can manage landmarks" ON landmarks 
          FOR ALL TO authenticated USING (
            EXISTS (
              SELECT 1 FROM users 
              WHERE users.id = auth.uid() 
              AND users.role = 'admin'
            )
          );
      '''
    });
  }
  
  /// Create RLS policies for posts table
  static Future<void> _createPostsPolicies() async {
    // Public posts viewable by everyone
    await _client.rpc('exec_sql', params: {
      'sql': '''
        CREATE POLICY "Anyone can view public posts" ON posts 
          FOR SELECT USING (is_public = true);
      '''
    });
    
    // Users can view own posts
    await _client.rpc('exec_sql', params: {
      'sql': '''
        CREATE POLICY "Users can view own posts" ON posts 
          FOR SELECT USING (auth.uid() = user_id);
      '''
    });
    
    // Authenticated users can create posts
    await _client.rpc('exec_sql', params: {
      'sql': '''
        CREATE POLICY "Authenticated users can create posts" ON posts 
          FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
      '''
    });
    
    // Users can update own posts
    await _client.rpc('exec_sql', params: {
      'sql': '''
        CREATE POLICY "Users can update own posts" ON posts
          FOR UPDATE
            USING (auth.uid() = user_id)
            WITH CHECK (auth.uid() = user_id);
      '''
    });
    
    // Users can delete own posts
    await _client.rpc('exec_sql', params: {
      'sql': '''
        CREATE POLICY "Users can delete own posts" ON posts 
          FOR DELETE USING (auth.uid() = user_id);
      '''
    });
  }
  
  /// Create RLS policies for guides table
  static Future<void> _createGuidesPolicies() async {
    // Public guides viewable by everyone
    await _client.rpc('exec_sql', params: {
      'sql': '''
        CREATE POLICY "Anyone can view public guides" ON guides 
          FOR SELECT USING (is_public = true);
      '''
    });
    
    // Users can view own guides
    await _client.rpc('exec_sql', params: {
      'sql': '''
        CREATE POLICY "Users can view own guides" ON guides 
          FOR SELECT USING (auth.uid() = user_id);
      '''
    });
    
    // Authenticated users can create guides
    await _client.rpc('exec_sql', params: {
      'sql': '''
        CREATE POLICY "Authenticated users can create guides" ON guides 
          FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
      '''
    });
    
    // Users can update own guides
    await _client.rpc('exec_sql', params: {
      'sql': '''
        CREATE POLICY "Users can update own guides" ON guides
          FOR UPDATE
            USING (auth.uid() = user_id)
            WITH CHECK (auth.uid() = user_id);
      '''
    });
    
    // Users can delete own guides
    await _client.rpc('exec_sql', params: {
      'sql': '''
        CREATE POLICY "Users can delete own guides" ON guides 
          FOR DELETE USING (auth.uid() = user_id);
      '''
    });
  }
  
  /// Create RLS policies for guide_items table
  static Future<void> _createGuideItemsPolicies() async {
    // Guide owners can manage guide items
    await _client.rpc('exec_sql', params: {
      'sql': '''
        CREATE POLICY "Guide owners can manage guide items" ON guide_items 
          FOR ALL 
            USING (
              EXISTS (
                SELECT 1 FROM guides 
                WHERE guides.id = guide_items.guide_id 
                AND guides.user_id = auth.uid()
              )
            )
            WITH CHECK (
              EXISTS (
                SELECT 1 FROM guides 
                WHERE guides.id = guide_items.guide_id 
                AND guides.user_id = auth.uid()
              )
            );
      '''
    });
    
    // Public guide items viewable by everyone
    await _client.rpc('exec_sql', params: {
      'sql': '''
        CREATE POLICY "Anyone can view public guide items" ON guide_items 
          FOR SELECT USING (
            EXISTS (
              SELECT 1 FROM guides 
              WHERE guides.id = guide_items.guide_id 
              AND guides.is_public = true
            )
          );
      '''
    });
  }
  
  /// Create RLS policies for comments table
  static Future<void> _createCommentsPolicies() async {
    // Comments on public content viewable by everyone
    await _client.rpc('exec_sql', params: {
      'sql': '''
        CREATE POLICY "Anyone can view public comments" ON comments 
          FOR SELECT USING (
            (target_type = 'post' AND EXISTS (
              SELECT 1 FROM posts 
              WHERE posts.id = target_id 
              AND posts.is_public = true
            )) OR
            (target_type = 'guide' AND EXISTS (
              SELECT 1 FROM guides 
              WHERE guides.id = target_id 
              AND guides.is_public = true
            ))
          );
      '''
    });
    
    // Authenticated users can create comments
    await _client.rpc('exec_sql', params: {
      'sql': '''
        CREATE POLICY "Authenticated users can create comments" ON comments 
          FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
      '''
    });
    
    // Users can update own comments
    await _client.rpc('exec_sql', params: {
      'sql': '''
        CREATE POLICY "Users can update own comments" ON comments
          FOR UPDATE
            USING (auth.uid() = user_id)
            WITH CHECK (auth.uid() = user_id);
      '''
    });
    
    // Users can delete own comments
    await _client.rpc('exec_sql', params: {
      'sql': '''
        CREATE POLICY "Users can delete own comments" ON comments 
          FOR DELETE USING (auth.uid() = user_id);
      '''
    });
  }
  
  /// Create RLS policies for likes table
  static Future<void> _createLikesPolicies() async {
    // Users can only manage their own likes
    await _client.rpc('exec_sql', params: {
      'sql': '''
        CREATE POLICY "Users can manage own likes" ON likes 
          FOR ALL USING (auth.uid() = user_id);
      '''
    });
  }
  
  /// Test RLS configuration by performing basic queries
  static Future<bool> testRLSConfiguration() async {
    try {
      // Test basic queries on each table
      await _client.from('users').select('count').count();
      await _client.from('landmarks').select('count').count();
      await _client.from('posts').select('count').count();
      await _client.from('guides').select('count').count();
      await _client.from('guide_items').select('count').count();
      await _client.from('comments').select('count').count();
      await _client.from('likes').select('count').count();
      
      return true;
    } catch (e) {
      return false;
    }
  }
}