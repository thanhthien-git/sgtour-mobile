import 'package:dio/dio.dart';
import 'package:sgtour_mobile/models/map/osm_search_result.dart';
import '../../../api/api_service.dart';

class OsmSearchService {
  final ApiService _apiService = ApiService();

  Future<List<OsmSearchResult>> searchPlaces(
    String query,
    String locale,
  ) async {
    if (query.trim().isEmpty) return [];

    try {
      final response = await _apiService.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': query,
          'format': 'json',
          'limit': 5,
          'addressdetails': 1,
          'accept-language': locale,
        },
        options: Options(headers: {'User-Agent': 'com.sgtour.mobile'}),
      );

      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((e) => OsmSearchResult.fromJson(e)).toList();
      }
    } catch (e) {}
    return [];
  }
}
