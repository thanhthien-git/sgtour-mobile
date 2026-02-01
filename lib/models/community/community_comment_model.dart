/// Model for a comment on a community post (comment đã duyệt mới hiển thị)
class CommunityCommentModel {
  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String? authorAvatarUrl;
  final String content;
  final String createdAt;
  final bool isApproved;

  const CommunityCommentModel({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    this.authorAvatarUrl,
    required this.content,
    required this.createdAt,
    this.isApproved = true,
  });

  factory CommunityCommentModel.fromJson(Map<String, dynamic> json) {
    return CommunityCommentModel(
      id: json['id']?.toString() ?? '',
      postId: json['postId']?.toString() ?? '',
      authorId: json['authorId']?.toString() ?? '',
      authorName: json['authorName'] as String? ?? '',
      authorAvatarUrl: json['authorAvatarUrl'] as String?,
      content: json['content'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      isApproved: json['isApproved'] as bool? ?? true,
    );
  }
}
