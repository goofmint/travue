import 'package:latlong2/latlong.dart';
import '../../domain/entities/landmark.dart';
import '../../domain/repositories/landmark_repository.dart';

class SearchLandmarksNearbyUseCase {
  final LandmarkRepository _landmarkRepository;

  SearchLandmarksNearbyUseCase(this._landmarkRepository);

  Future<List<Landmark>> call(
    LatLng center, {
    int radiusMeters = 1000,
    int limit = 50,
  }) async {
    return await _landmarkRepository.searchLandmarksNearby(
      center,
      radiusMeters: radiusMeters,
      limit: limit,
    );
  }
}