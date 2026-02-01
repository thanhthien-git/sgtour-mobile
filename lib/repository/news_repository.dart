import 'package:sgtourcus/api/api_service.dart';
import 'package:sgtourcus/models/news/news_article_model.dart';
import 'package:sgtourcus/models/news/news_category_model.dart';

/// Repository for news categories and articles.
/// API endpoints expected:
/// - GET /news/categories -> List<NewsCategoryModel>
/// - GET /news/articles?categoryId=...&page=1&limit=20 -> List<NewsArticleModel>
class NewsRepository {
  static final NewsRepository _instance = NewsRepository._internal();
  factory NewsRepository() => _instance;
  NewsRepository._internal();

  final _api = ApiService();

  static const String _categoriesPath = '/news/categories';
  static const String _articlesPath = '/news/articles';

  /// Fetches news categories from API.
  /// Returns empty list on error so UI can still render.
  Future<List<NewsCategoryModel>> getCategories() async {
    try {
      final response = await _api.get(_categoriesPath);
      final data = response.data;
      if (data == null) return [];
      final list = data is List ? data : (data as Map?)?['data'] as List? ?? (data as Map?)?['items'] as List?;
      if (list == null) return [];
      return list
          .map((e) => NewsCategoryModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Fetches news articles for a category.
  /// [categoryId] optional; empty or null = "latest" / all.
  /// Returns empty list on error.
  Future<List<NewsArticleModel>> getArticles({
    String? categoryId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};
      if (categoryId != null && categoryId.isNotEmpty) {
        queryParams['categoryId'] = categoryId;
      }
      final response = await _api.get(_articlesPath, queryParameters: queryParams);
      final data = response.data;
      if (data == null) return [];
      final list = data is List ? data : (data as Map?)?['data'] as List? ?? (data as Map?)?['items'] as List?;
      if (list == null) return [];
      return list
          .map((e) => NewsArticleModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
