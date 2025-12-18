import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sgtour_mobile/models/models.dart';

class UserNotifier extends StateNotifier<UserProfileModel?> {
  UserNotifier() : super(null);

  Future<void> setUser(UserProfileModel user) async {
    state = user;
  }
}
