/// Visibility: public, link (người có liên kết), private, saved (lưu nháp)
class PostVisibility {
  static const String public = 'public';
  static const String link = 'link';
  static const String private = 'private';
  static const String saved = 'saved';
}

/// Model for a community post (bản tin do người dùng đăng, đã duyệt)
class CommunityPostModel {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorAvatarUrl;
  final String content;
  final List<String> imageUrls;
  final String? videoUrl;
  final String? emotion;
  final String createdAt;
  final int commentCount;
  final bool isApproved;
  final String visibility;

  const CommunityPostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorAvatarUrl,
    required this.content,
    this.imageUrls = const [],
    this.videoUrl,
    this.emotion,
    required this.createdAt,
    this.commentCount = 0,
    this.isApproved = true,
    this.visibility = PostVisibility.public,
  });

  factory CommunityPostModel.fromJson(Map<String, dynamic> json) {
    final images = json['imageUrls'] as List<dynamic>?;
    return CommunityPostModel(
      id: json['id']?.toString() ?? '',
      authorId: json['authorId']?.toString() ?? '',
      authorName: json['authorName'] as String? ?? '',
      authorAvatarUrl: json['authorAvatarUrl'] as String?,
      content: json['content'] as String? ?? '',
      imageUrls: images?.map((e) => e.toString()).toList() ?? [],
      videoUrl: json['videoUrl'] as String?,
      emotion: json['emotion'] as String?,
      createdAt: json['createdAt'] as String? ?? '',
      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
      isApproved: json['isApproved'] as bool? ?? true,
      visibility: json['visibility'] as String? ?? PostVisibility.public,
    );
  }

  CommunityPostModel copyWith({String? visibility}) {
    return CommunityPostModel(
      id: id,
      authorId: authorId,
      authorName: authorName,
      authorAvatarUrl: authorAvatarUrl,
      content: content,
      imageUrls: imageUrls,
      videoUrl: videoUrl,
      emotion: emotion,
      createdAt: createdAt,
      commentCount: commentCount,
      isApproved: isApproved,
      visibility: visibility ?? this.visibility,
    );
  }
}
