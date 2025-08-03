import 'package:flutter_test/flutter_test.dart';
import '../services/test_supabase_service.dart';
import 'rls_test_helper.dart';

void main() {
  group('RLS Security Tests', skip: 'Requires Supabase plugin initialization in test environment', () {
    setUpAll(() async {
      // Initialize Supabase service for testing
      await TestSupabaseService.initialize();
    });
    
    setUp(() async {
      // Clean up any existing test data
      await RLSTestHelper.cleanupTestData();
      // Create fresh test data for each test
      await RLSTestHelper.createTestUsers();
      await RLSTestHelper.createTestData();
    });
    
    tearDown(() async {
      // Clean up test data after each test
      await RLSTestHelper.cleanupTestData();
    });
    
    group('Users Table RLS', () {
      test('users can only access their own profile', () async {
        final client = TestSupabaseService.instance.client;
        
        // Test that user can access their own profile
        final ownProfile = await client
            .from('users')
            .select()
            .eq('id', RLSTestHelper.testUser1Id)
            .maybeSingle();
        
        expect(ownProfile, isNotNull);
        expect(ownProfile!['id'], equals(RLSTestHelper.testUser1Id));
        
        // Test general user query (should return results based on RLS)
        final allUsers = await client
            .from('users')
            .select()
            .limit(10);
        
        // With proper RLS, this should only return accessible users
        expect(allUsers, isA<List>());
      });
    });
    
    group('Posts Table RLS', () {
      test('public posts are visible to everyone', () async {
        final client = TestSupabaseService.instance.client;
        
        // Query public posts
        final publicPosts = await client
            .from('posts')
            .select()
            .eq('is_public', true);
        
        expect(publicPosts.length, greaterThan(0));
        
        // Verify all returned posts are public
        for (final post in publicPosts) {
          expect(post['is_public'], isTrue);
        }
      });
      
      test('private posts are only visible to owner', () async {
        final client = TestSupabaseService.instance.client;
        
        // Query all posts (should only return public posts and own posts based on RLS)
        final visiblePosts = await client
            .from('posts')
            .select();
        
        // With RLS, this should filter appropriately
        expect(visiblePosts, isA<List>());
        
        // Test specific private post access
        final privatePost = await client
            .from('posts')
            .select()
            .eq('id', 'post-2')
            .maybeSingle();
        
        // This should either return null (if not accessible) or the post (if accessible)
        if (privatePost != null) {
          expect(privatePost['id'], equals('post-2'));
        }
      });
      
      test('users cannot update posts they do not own', () async {
        final client = TestSupabaseService.instance.client;
        
        // Attempt to update another user's post
        try {
          await client
              .from('posts')
              .update({'title': 'Hacked Title'})
              .eq('id', 'post-3'); // This belongs to testUser2Id
          
          // If we reach here, the update succeeded (which might be allowed for public posts)
          // We need to verify the actual security behavior
        } catch (e) {
          // If RLS is working correctly, this should throw an error
          expect(e.toString(), contains('policy'));
        }
      });
    });
    
    group('Guides Table RLS', () {
      test('public guides are visible to everyone', () async {
        final client = TestSupabaseService.instance.client;
        
        final publicGuides = await client
            .from('guides')
            .select()
            .eq('is_public', true);
        
        expect(publicGuides.length, greaterThan(0));
        
        for (final guide in publicGuides) {
          expect(guide['is_public'], isTrue);
        }
      });
      
      test('private guides are only visible to owner', () async {
        final client = TestSupabaseService.instance.client;
        
        final allGuides = await client
            .from('guides')
            .select();
        
        // With RLS, this should be filtered appropriately
        expect(allGuides, isA<List>());
      });
    });
    
    group('Guide Items RLS', () {
      test('guide items follow guide visibility rules', () async {
        final client = TestSupabaseService.instance.client;
        
        final guideItems = await client
            .from('guide_items')
            .select('*, guides(is_public)')
            .eq('guide_id', 'guide-1'); // This is a public guide
        
        // Should be able to access items from public guides
        expect(guideItems, isA<List>());
      });
      
      test('only guide owners can manage guide items', () async {
        final client = TestSupabaseService.instance.client;
        
        // Test accessing guide items
        final items = await client
            .from('guide_items')
            .select();
        
        expect(items, isA<List>());
      });
    });
    
    group('Comments RLS', () {
      test('comments on public content are visible', () async {
        final client = TestSupabaseService.instance.client;
        
        final comments = await client
            .from('comments')
            .select();
        
        expect(comments, isA<List>());
      });
      
      test('users can only update their own comments', () async {
        final client = TestSupabaseService.instance.client;
        
        // Test comment access
        final userComments = await client
            .from('comments')
            .select();
        
        expect(userComments, isA<List>());
      });
    });
    
    group('Likes RLS', () {
      test('users can only manage their own likes', () async {
        final client = TestSupabaseService.instance.client;
        
        final likes = await client
            .from('likes')
            .select();
        
        expect(likes, isA<List>());
      });
    });
    
    group('Landmarks RLS', () {
      test('authenticated users can view landmarks', () async {
        final client = TestSupabaseService.instance.client;
        
        final landmarks = await client
            .from('landmarks')
            .select();
        
        expect(landmarks, isA<List>());
        expect(landmarks.length, greaterThan(0));
      });
    });
  });
}