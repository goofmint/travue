import 'package:latlong2/latlong.dart';
import '../entities/landmark.dart';

abstract class LandmarkRepository {
  Future<Landmark?> getLandmarkById(String id);
  Future<List<Landmark>> searchLandmarksNearby(
    LatLng center, {
    int radiusMeters = 1000,
    int limit = 50,
  });
  Future<List<Landmark>> searchLandmarksByName(String name);
  Future<List<Landmark>> getLandmarksByCategory(String category);
  Future<Landmark> createLandmark(Landmark landmark);
  Future<Landmark> updateLandmark(Landmark landmark);
  Future<void> deleteLandmark(String id);
}