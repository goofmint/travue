import 'package:latlong2/latlong.dart';
import '../../domain/entities/landmark.dart';
import '../../domain/repositories/landmark_repository.dart';
import '../services/supabase_service.dart';

class SupabaseLandmarkRepository implements LandmarkRepository {
  final SupabaseService _supabaseService;

  SupabaseLandmarkRepository(this._supabaseService);

  @override
  Future<Landmark?> getLandmarkById(String id) async {
    try {
      final response = await _supabaseService.client
          .from('landmarks')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return _landmarkFromDatabase(response);
    } catch (e) {
      throw Exception('Failed to get landmark by id: $e');
    }
  }

  @override
  Future<List<Landmark>> searchLandmarksNearby(
    LatLng center, {
    int radiusMeters = 1000,
    int limit = 50,
  }) async {
    try {
      final response = await _supabaseService.client
          .rpc('search_landmarks_nearby', params: {
        'center_lat': center.latitude,
        'center_lng': center.longitude,
        'radius_meters': radiusMeters,
      });

      return (response as List)
          .take(limit)
          .map<Landmark>((json) => _landmarkFromSearchResult(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to search landmarks nearby: $e');
    }
  }

  @override
  Future<List<Landmark>> searchLandmarksByName(String name) async {
    try {
      final response = await _supabaseService.client
          .from('landmarks')
          .select()
          .ilike('name', '%$name%')
          .limit(20);

      return response
          .map<Landmark>((json) => _landmarkFromDatabase(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to search landmarks by name: $e');
    }
  }

  @override
  Future<List<Landmark>> getLandmarksByCategory(String category) async {
    try {
      final response = await _supabaseService.client
          .from('landmarks')
          .select()
          .eq('category', category);

      return response
          .map<Landmark>((json) => _landmarkFromDatabase(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get landmarks by category: $e');
    }
  }

  @override
  Future<Landmark> createLandmark(Landmark landmark) async {
    try {
      final data = landmark.toJson();
      // Convert LatLng to PostgreSQL Point format
      data['location'] = 'POINT(${landmark.location.longitude} ${landmark.location.latitude})';
      data.remove('location_lat');
      data.remove('location_lng');

      final response = await _supabaseService.client
          .from('landmarks')
          .insert(data)
          .select()
          .single();

      return _landmarkFromDatabase(response);
    } catch (e) {
      throw Exception('Failed to create landmark: $e');
    }
  }

  @override
  Future<Landmark> updateLandmark(Landmark landmark) async {
    try {
      final data = landmark.toJson();
      // Convert LatLng to PostgreSQL Point format
      data['location'] = 'POINT(${landmark.location.longitude} ${landmark.location.latitude})';
      data.remove('location_lat');
      data.remove('location_lng');

      final response = await _supabaseService.client
          .from('landmarks')
          .update(data)
          .eq('id', landmark.id)
          .select()
          .single();

      return _landmarkFromDatabase(response);
    } catch (e) {
      throw Exception('Failed to update landmark: $e');
    }
  }

  @override
  Future<void> deleteLandmark(String id) async {
    try {
      await _supabaseService.client
          .from('landmarks')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete landmark: $e');
    }
  }

  Landmark _landmarkFromDatabase(Map<String, dynamic> json) {
    // Handle PostGIS geography data
    final location = json['location'];
    double lat, lng;
    
    if (location is String && location.startsWith('POINT')) {
      // Parse POINT(lng lat) format
      final coords = location.substring(6, location.length - 1).split(' ');
      lng = double.parse(coords[0]);
      lat = double.parse(coords[1]);
    } else {
      // Fallback to lat/lng fields if available
      lat = (json['location_lat'] as num?)?.toDouble() ?? 0.0;
      lng = (json['location_lng'] as num?)?.toDouble() ?? 0.0;
    }

    return Landmark(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      location: LatLng(lat, lng),
      address: json['address'] as String?,
      wikipediaUrl: json['wikipedia_url'] as String?,
      category: json['category'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Landmark _landmarkFromSearchResult(Map<String, dynamic> json) {
    return Landmark(
      id: json['id'] as String,
      name: json['name'] as String,
      description: null,
      location: LatLng(
        (json['location_lat'] as num).toDouble(),
        (json['location_lng'] as num).toDouble(),
      ),
      address: null,
      wikipediaUrl: null,
      category: null,
      createdAt: DateTime.now(), // Search results don't include created_at
    );
  }
}