import 'dart:developer';

import 'package:sgtour_mobile/api/api_service.dart';
import 'package:sgtour_mobile/models/get_map_query_dto.dart';
import 'package:sgtour_mobile/models/map/map_response.dart';

class MapService {
  final ApiService api;

  MapService(this.api);

  Future<List<MapResponse>> getPlacesForMap(GetMapQueryDto query) async {
    final traceId = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      final response = await api.get(
        '/map/tile',
        queryParameters: query.toQuery(),
      );

      final raw = response.data;

      if (raw is! List) {
        throw StateError(
          'Invalid response format: expected List, got ${raw.runtimeType}',
        );
      }

      final result = raw
          .map<MapResponse>((e) => MapResponse.fromJson(e))
          .toList(growable: false);

      return result;
    } catch (e, stack) {
      log(
        '[MapService][$traceId] failed',
        name: 'map',
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }
  }
}
