import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/test_supabase_service.dart';

class RLSTestHelper {
  static SupabaseClient get _client => TestSupabaseService.instance.client;
  
  // Test user IDs (UUIDs)
  static const String testUser1Id = '11111111-1111-1111-1111-111111111111';
  static const String testUser2Id = '22222222-2222-2222-2222-222222222222';
  static const String adminUserId = '33333333-3333-3333-3333-333333333333';
  
  /// Create test users in the database
  static Future<void> createTestUsers() async {
    // Insert test users directly into the users table
    await _client.from('users').upsert([
      {
        'id': testUser1Id,
        'email': 'test1@example.com',
        'display_name': 'Test User 1',
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': testUser2Id,
        'email': 'test2@example.com',
        'display_name': 'Test User 2',
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': adminUserId,
        'email': 'admin@example.com',
        'display_name': 'Admin User',
        'role': 'admin',
        'created_at': DateTime.now().toIso8601String(),
      },
    ]);
  }
  
  /// Create test data for RLS testing
  static Future<void> createTestData() async {
    // Create test landmarks
    await _client.from('landmarks').upsert([
      {
        'id': 'landmark-1',
        'name': 'Test Landmark 1',
        'location': 'POINT(139.6917 35.6895)',
        'description': 'Test landmark for RLS testing',
        'created_at': DateTime.now().toIso8601String(),
      },
    ]);
    
    // Create test posts
    await _client.from('posts').upsert([
      {
        'id': 'post-1',
        'user_id': testUser1Id,
        'title': 'Public Post by User 1',
        'content': 'This is a public post',
        'is_public': true,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'post-2',
        'user_id': testUser1Id,
        'title': 'Private Post by User 1',
        'content': 'This is a private post',
        'is_public': false,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'post-3',
        'user_id': testUser2Id,
        'title': 'Public Post by User 2',
        'content': 'This is another public post',
        'is_public': true,
        'created_at': DateTime.now().toIso8601String(),
      },
    ]);
    
    // Create test guides
    await _client.from('guides').upsert([
      {
        'id': 'guide-1',
        'user_id': testUser1Id,
        'title': 'Public Guide by User 1',
        'description': 'This is a public guide',
        'is_public': true,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'guide-2',
        'user_id': testUser1Id,
        'title': 'Private Guide by User 1',
        'description': 'This is a private guide',
        'is_public': false,
        'created_at': DateTime.now().toIso8601String(),
      },
    ]);
    
    // Create test guide items
    await _client.from('guide_items').upsert([
      {
        'id': 'guide-item-1',
        'guide_id': 'guide-1',
        'landmark_id': 'landmark-1',
        'order_index': 1,
        'notes': 'First stop on the guide',
        'created_at': DateTime.now().toIso8601String(),
      },
    ]);
    
    // Create test comments
    await _client.from('comments').upsert([
      {
        'id': 'comment-1',
        'user_id': testUser2Id,
        'target_type': 'post',
        'target_id': 'post-1',
        'content': 'Great post!',
        'created_at': DateTime.now().toIso8601String(),
      },
    ]);
    
    // Create test likes
    await _client.from('likes').upsert([
      {
        'id': 'like-1',
        'user_id': testUser1Id,
        'target_type': 'post',
        'target_id': 'post-3',
        'created_at': DateTime.now().toIso8601String(),
      },
    ]);
  }
  
  /// Clean up test data
  static Future<void> cleanupTestData() async {
    // Delete in reverse order to avoid foreign key constraints
    await _client.from('likes').delete().neq('id', '');
    await _client.from('comments').delete().neq('id', '');
    await _client.from('guide_items').delete().neq('id', '');
    await _client.from('guides').delete().neq('id', '');
    await _client.from('posts').delete().neq('id', '');
    await _client.from('landmarks').delete().neq('id', '');
    await _client.from('users').delete().neq('id', '');
  }
  
  /// Mock authentication for a specific user
  static Future<void> mockAuthUser(String userId) async {
    // Note: In a real implementation, we would need to properly handle
    // authentication. For testing purposes, we'll simulate this by
    // directly setting the auth context or using service role key.
    // This is a simplified approach for RLS testing.
  }
  
  /// Helper to test if a query succeeds (has access)
  static Future<bool> canAccess(Future<List<Map<String, dynamic>>> Function() query) async {
    try {
      await query();
      return true;
    } catch (e) {
      // Check if it's an RLS policy violation
      if (e.toString().contains('policy')) {
        return false;
      }
      // Re-throw other errors
      rethrow;
    }
  }
  
  /// Helper to test if a query is denied (no access)
  static Future<bool> isDenied(Future<List<Map<String, dynamic>>> Function() query) async {
    return !(await canAccess(query));
  }
}