/// Model for a news article from API
class NewsArticleModel {
  final String id;
  final String title;
  final String summary;
  final String? imageUrl;
  final String categoryName;
  final int commentCount;
  final String? publishedAt;

  const NewsArticleModel({
    required this.id,
    required this.title,
    required this.summary,
    this.imageUrl,
    this.categoryName = '',
    this.commentCount = 0,
    this.publishedAt,
  });

  factory NewsArticleModel.fromJson(Map<String, dynamic> json) {
    return NewsArticleModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? json['excerpt'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? json['thumbnailUrl'] as String?,
      categoryName: json['categoryName'] as String? ?? json['category'] as String? ?? '',
      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
      publishedAt: json['publishedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'imageUrl': imageUrl,
      'categoryName': categoryName,
      'commentCount': commentCount,
      'publishedAt': publishedAt,
    };
  }
}
