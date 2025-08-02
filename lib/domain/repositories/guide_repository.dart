import '../entities/guide.dart';

abstract class GuideRepository {
  Future<Guide?> getGuideById(String id);
  Future<List<Guide>> getGuidesByUserId(String userId);
  Future<List<Guide>> getPublicGuides({int limit = 20, int offset = 0});
  Future<Guide> createGuide(Guide guide);
  Future<Guide> updateGuide(Guide guide);
  Future<void> deleteGuide(String id);
  Future<List<Guide>> searchGuides(String query, {bool publicOnly = true});
  Future<List<Guide>> getGuidesByTags(List<String> tags);
}