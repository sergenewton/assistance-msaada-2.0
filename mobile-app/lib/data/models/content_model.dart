class ContentModel {
  final String id;
  final String title;
  final String description;
  final ContentType type;
  final String? imageUrl;
  final String? videoUrl;
  final String content;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isPublished;
  final String? authorName;
  final int viewCount;
  final Map<String, dynamic>? metadata;

  const ContentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.imageUrl,
    this.videoUrl,
    required this.content,
    this.tags = const [],
    required this.createdAt,
    this.updatedAt,
    this.isPublished = true,
    this.authorName,
    this.viewCount = 0,
    this.metadata,
  });

  factory ContentModel.fromJson(Map<String, dynamic> json) {
    return ContentModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: ContentType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => ContentType.article,
      ),
      imageUrl: json['image_url'] as String?,
      videoUrl: json['video_url'] as String?,
      content: json['content'] as String,
      tags: json['tags'] != null
          ? List<String>.from(json['tags'] as List)
          : [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      isPublished: json['is_published'] as bool? ?? true,
      authorName: json['author_name'] as String?,
      viewCount: json['view_count'] as int? ?? 0,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'image_url': imageUrl,
      'video_url': videoUrl,
      'content': content,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_published': isPublished,
      'author_name': authorName,
      'view_count': viewCount,
      'metadata': metadata,
    };
  }

  ContentModel copyWith({
    String? id,
    String? title,
    String? description,
    ContentType? type,
    String? imageUrl,
    String? videoUrl,
    String? content,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPublished,
    String? authorName,
    int? viewCount,
    Map<String, dynamic>? metadata,
  }) {
    return ContentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPublished: isPublished ?? this.isPublished,
      authorName: authorName ?? this.authorName,
      viewCount: viewCount ?? this.viewCount,
      metadata: metadata ?? this.metadata,
    );
  }
}

enum ContentType {
  article,
  video,
  infographic,
  podcast,
  guide,
  resource,
}