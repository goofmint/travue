class Post {
  final String id;
  final String userId;
  final String landmarkId;
  final String title;
  final String? content;
  final List<String> images;
  final int? rating;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Post({
    required this.id,
    required this.userId,
    required this.landmarkId,
    required this.title,
    this.content,
    required this.images,
    this.rating,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      landmarkId: json['landmark_id'] as String,
      title: json['title'] as String,
      content: json['content'] as String?,
      images: (json['images'] as List<dynamic>?)?.cast<String>() ?? [],
      rating: json['rating'] as int?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'landmark_id': landmarkId,
      'title': title,
      'content': content,
      'images': images,
      'rating': rating,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Post copyWith({
    String? id,
    String? userId,
    String? landmarkId,
    String? title,
    String? content,
    List<String>? images,
    int? rating,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      landmarkId: landmarkId ?? this.landmarkId,
      title: title ?? this.title,
      content: content ?? this.content,
      images: images ?? this.images,
      rating: rating ?? this.rating,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Post && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Post(id: $id, title: $title, userId: $userId)';
  }
}