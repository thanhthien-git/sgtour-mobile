import 'package:latlong2/latlong.dart';
import '../../enums/place_language.dart';
import 'place_image.dart';
import 'place_metadata.dart';
import 'place_translation.dart';

class Place {
  final String id;
  final LatLng location;
  final PlaceLanguage defaultLanguage;
  final String categoryCode;
  final PlaceMetadata metadata;
  final List<PlaceImage> images;
  final List<PlaceTranslation> translations;

  const Place({
    required this.id,
    required this.location,
    required this.defaultLanguage,
    required this.categoryCode,
    required this.metadata,
    required this.images,
    required this.translations,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    // Safe casting from dynamic maps to typed maps
    Map<String, dynamic> _safeMap(dynamic value) {
      if (value is Map<String, dynamic>) return value;
      if (value is Map) return Map<String, dynamic>.from(value);
      return {};
    }

    final locationData = _safeMap(json['location']);
    final coordinates = (locationData['coordinates'] as List?) ?? [];

    return Place(
      id: json['id'] as String? ?? '',
      location: LatLng(
        coordinates.length > 1 ? coordinates[1] as double : 0.0,
        coordinates.isNotEmpty ? coordinates[0] as double : 0.0,
      ),
      defaultLanguage: PlaceLanguage.fromCode(
        json['defaultLanguage'] as String? ?? 'en',
      ),
      categoryCode: json['categoryCode'] as String? ?? '',
      metadata: PlaceMetadata.fromJson(_safeMap(json['metadata'])),
      images: (json['placeImages'] as List?)
              ?.map((e) => PlaceImage.fromJson(_safeMap(e)))
              .toList() ??
          [],
      translations: (json['placeTranslations'] as List?)
              ?.map((e) => PlaceTranslation.fromJson(_safeMap(e)))
              .toList() ??
          [],
    );
  }

  String? get primaryImageUrl {
    final primary = images.where((img) => img.isPrimary).firstOrNull;
    return primary?.url ?? images.firstOrNull?.url;
  }

  List<String> get imageUrls => images.map((img) => img.url).toList();

  PlaceTranslation? getTranslation(PlaceLanguage language) {
    return translations.where((t) => t.language == language).firstOrNull;
  }

  List<PlaceLanguage> get availableLanguages {
    return translations.map((t) => t.language).toList();
  }

  String get title => metadata.title;

  String get address => metadata.address;
}
