import 'package:sgtourcus/api/api_service.dart';
import 'package:sgtourcus/models/location_model.dart';
import 'package:sgtourcus/models/map/get_nearest_place_dto.dart';

class MapService {
  static final ApiService _api = ApiService();

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
          if (dto.search != null && dto.search!.isNotEmpty)
            'search': dto.search,
        },
      );
      final listData = response.data as List;
      return listData.map((e) => LocationModel.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
