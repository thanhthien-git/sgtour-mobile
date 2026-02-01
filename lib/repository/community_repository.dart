import 'package:sgtourcus/api/api_service.dart';
import 'package:sgtourcus/models/community/community_comment_model.dart';
import 'package:sgtourcus/models/community/community_post_model.dart' show CommunityPostModel, PostVisibility;
import 'package:sgtourcus/models/community/community_team_up_model.dart';
import 'package:sgtourcus/models/community/top_rated_place_model.dart';

/// Repository for community: posts (approved), top-rated places, comments, team-up.
/// API paths: /community/posts, /community/places/top, /community/posts/:id/comments,
/// /community/team-up, etc.
class CommunityRepository {
  static final CommunityRepository _instance = CommunityRepository._internal();
  factory CommunityRepository() => _instance;
  CommunityRepository._internal();

  final _api = ApiService();

  static const String _postsPath = '/community/posts';
  static const String _topPlacesPath = '/community/places/top';
  static const String _teamUpPath = '/community/team-up';

  /// Bản tin do người dùng đăng (đã duyệt)
  Future<List<CommunityPostModel>> getApprovedPosts({int page = 1, int limit = 20}) async {
    try {
      final response = await _api.get(_postsPath, queryParameters: {'page': page, 'limit': limit, 'approved': true});
      final data = response.data;
      if (data == null) return [];
      final list = data is List ? data : (data as Map?)?['data'] as List? ?? (data as Map?)?['items'] as List?;
      if (list == null) return [];
      return list.map((e) => CommunityPostModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    } catch (_) {
      return [];
    }
  }

  /// Địa điểm có rating cao
  Future<List<TopRatedPlaceModel>> getTopRatedPlaces({int limit = 10}) async {
    try {
      final response = await _api.get(_topPlacesPath, queryParameters: {'limit': limit});
      final data = response.data;
      if (data == null) return [];
      final list = data is List ? data : (data as Map?)?['data'] as List? ?? (data as Map?)?['items'] as List?;
      if (list == null) return [];
      return list.map((e) => TopRatedPlaceModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    } catch (_) {
      return [];
    }
  }

  /// Comment đã duyệt của một bản tin
  Future<List<CommunityCommentModel>> getComments(String postId) async {
    try {
      final response = await _api.get('$_postsPath/$postId/comments', queryParameters: {'approved': true});
      final data = response.data;
      if (data == null) return [];
      final list = data is List ? data : (data as Map?)?['data'] as List? ?? (data as Map?)?['items'] as List?;
      if (list == null) return [];
      return list.map((e) => CommunityCommentModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    } catch (_) {
      return [];
    }
  }

  /// Gửi comment (sau khi duyệt mới hiển thị)
  Future<bool> addComment(String postId, String content) async {
    try {
      await _api.post('$_postsPath/$postId/comments', data: {'content': content});
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Tạo bản tin (upload hình, video, nội dung, cảm xúc, visibility)
  Future<CommunityPostModel?> createPost({
    required String content,
    List<String>? imageUrls,
    String? videoUrl,
    String? emotion,
    String visibility = PostVisibility.public,
  }) async {
    try {
      final response = await _api.post(_postsPath, data: {
        'content': content,
        if (imageUrls != null && imageUrls.isNotEmpty) 'imageUrls': imageUrls,
        if (videoUrl != null && videoUrl.isNotEmpty) 'videoUrl': videoUrl,
        if (emotion != null && emotion.isNotEmpty) 'emotion': emotion,
        'visibility': visibility,
      });
      final data = response.data;
      if (data == null) return null;
      return CommunityPostModel.fromJson(Map<String, dynamic>.from(data is Map ? data : {}));
    } catch (_) {
      return null;
    }
  }

  /// Tin đã đăng của user hiện tại
  Future<List<CommunityPostModel>> getMyPosts({int page = 1, int limit = 20}) async {
    try {
      final response = await _api.get('$_postsPath/me', queryParameters: {'page': page, 'limit': limit});
      final data = response.data;
      if (data == null) return [];
      final list = data is List ? data : (data as Map?)?['data'] as List? ?? (data as Map?)?['items'] as List?;
      if (list == null) return [];
      return list.map((e) => CommunityPostModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    } catch (_) {
      return [];
    }
  }

  /// Cập nhật quyền xem bài đăng
  Future<bool> updatePostVisibility(String postId, String visibility) async {
    try {
      await _api.patch('$_postsPath/$postId', data: {'visibility': visibility});
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Xóa bài đăng của cá nhân
  Future<bool> deletePost(String postId) async {
    try {
      await _api.delete('$_postsPath/$postId');
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Danh sách thông báo ghép đội du lịch
  Future<List<CommunityTeamUpModel>> getTeamUpList({int page = 1, int limit = 20}) async {
    try {
      final response = await _api.get(_teamUpPath, queryParameters: {'page': page, 'limit': limit});
      final data = response.data;
      if (data == null) return [];
      final list = data is List ? data : (data as Map?)?['data'] as List? ?? (data as Map?)?['items'] as List?;
      if (list == null) return [];
      return list.map((e) => CommunityTeamUpModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    } catch (_) {
      return [];
    }
  }

  /// Tạo thông báo ghép đội
  Future<CommunityTeamUpModel?> createTeamUp({
    required String title,
    String? description,
    String? destination,
    String? startDate,
    int maxMembers = 10,
  }) async {
    try {
      final response = await _api.post(_teamUpPath, data: {
        'title': title,
        if (description != null) 'description': description,
        if (destination != null) 'destination': destination,
        if (startDate != null) 'startDate': startDate,
        'maxMembers': maxMembers,
      });
      final data = response.data;
      if (data == null) return null;
      return CommunityTeamUpModel.fromJson(Map<String, dynamic>.from(data is Map ? data : {}));
    } catch (_) {
      return null;
    }
  }

  /// Tham gia ghép đội
  Future<bool> joinTeamUp(String teamUpId) async {
    try {
      await _api.post('$_teamUpPath/$teamUpId/join', data: {});
      return true;
    } catch (_) {
      return false;
    }
  }
}
