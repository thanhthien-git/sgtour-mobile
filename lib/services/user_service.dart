import 'package:sgtour_mobile/api/api_service.dart';
import 'package:sgtour_mobile/models/user/user_profile_model.dart';
import 'package:sgtour_mobile/services/storage_service.dart';

class UserService {
  static final ApiService _api = ApiService();

  static Future<UserProfileModel> getProfile() async {
    try {
      final id = StorageService.instance.getString(StorageKeys.userId);
      final response = await _api.get('/customers/$id');
      return UserProfileModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  static Future<UserProfileModel> updateProfile(UserProfileModel user) async {
    try {
      final id = StorageService.instance.getString(StorageKeys.userId);
      final response = await _api.patch('/customers/$id', data: user.toJson());
      user = UserProfileModel.fromJson(response.data);
      return user;
    } catch (e) {
      rethrow;
    }
  }
}
