import 'package:sgtour_mobile/api/api_service.dart';
import 'package:sgtour_mobile/models/location_model.dart';
import 'package:sgtour_mobile/models/map/get_nearest_place_dto.dart';

class MapService {
  static final ApiService _api = ApiService();

  // map_service.dart
  static Future<List<LocationModel>> getNearestLocations(
    GetNearestPlaceDto dto,
  ) async {
    try {
      final response = await _api.get(
        '/locations/map/nearest',
        queryParameters: {
          'latitude': dto.latitude,
          'longitude': dto.longitude,
          'limit': dto.limit,
          'page': dto.page,
        },
      );

      final listData = response.data as List;

      return listData.map((e) => LocationModel.fromJson(e)).toList();
    } catch (e) {
      print('🔥 Error in MapService: $e');
      rethrow;
    }
  }
}
