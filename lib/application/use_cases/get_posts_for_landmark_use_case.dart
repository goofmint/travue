import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';

class GetPostsForLandmarkUseCase {
  final PostRepository _postRepository;

  GetPostsForLandmarkUseCase(this._postRepository);

  Future<List<Post>> call(String landmarkId) async {
    return await _postRepository.getPostsByLandmarkId(landmarkId);
  }
}