import 'package:latlong2/latlong.dart';

class Landmark {
  final String id;
  final String name;
  final String? description;
  final LatLng location;
  final String? address;
  final String? wikipediaUrl;
  final String? category;
  final DateTime createdAt;

  const Landmark({
    required this.id,
    required this.name,
    required this.location,
    this.description,
    this.address,
    this.wikipediaUrl,
    this.category,
    required this.createdAt,
  });

  factory Landmark.fromJson(Map<String, dynamic> json) {
    return Landmark(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      location: LatLng(
        (json['location_lat'] as num).toDouble(),
        (json['location_lng'] as num).toDouble(),
      ),
      address: json['address'] as String?,
      wikipediaUrl: json['wikipedia_url'] as String?,
      category: json['category'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location_lat': location.latitude,
      'location_lng': location.longitude,
      'address': address,
      'wikipedia_url': wikipediaUrl,
      'category': category,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Landmark copyWith({
    String? id,
    String? name,
    String? description,
    LatLng? location,
    String? address,
    String? wikipediaUrl,
    String? category,
    DateTime? createdAt,
  }) {
    return Landmark(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      address: address ?? this.address,
      wikipediaUrl: wikipediaUrl ?? this.wikipediaUrl,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Landmark && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Landmark(id: $id, name: $name, location: $location)';
  }
}