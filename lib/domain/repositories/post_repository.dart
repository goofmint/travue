import '../entities/post.dart';

abstract class PostRepository {
  Future<Post?> getPostById(String id);
  Future<List<Post>> getPostsByLandmarkId(String landmarkId);
  Future<List<Post>> getPostsByUserId(String userId);
  Future<Post> createPost(Post post);
  Future<Post> updatePost(Post post);
  Future<void> deletePost(String id);
  Future<List<Post>> searchPosts(String query);
  Future<List<Post>> getPostsByTags(List<String> tags);
  Future<List<Post>> getRecentPosts({int limit = 20, int offset = 0});
}