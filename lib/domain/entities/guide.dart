class Guide {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String? coverImage;
  final List<String> tags;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Guide({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.coverImage,
    required this.tags,
    required this.isPublic,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Guide.fromJson(Map<String, dynamic> json) {
    return Guide(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      coverImage: json['cover_image'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      isPublic: json['is_public'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'cover_image': coverImage,
      'tags': tags,
      'is_public': isPublic,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Guide copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? coverImage,
    List<String>? tags,
    bool? isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Guide(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      coverImage: coverImage ?? this.coverImage,
      tags: tags ?? this.tags,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Guide && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Guide(id: $id, title: $title, isPublic: $isPublic)';
  }
}