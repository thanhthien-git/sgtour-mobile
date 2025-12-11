/// Content type for translation fields
enum PlaceContentType {
  defaultType('default'),
  paragraph('paragraph');

  final String value;

  const PlaceContentType(this.value);

  static PlaceContentType fromValue(String value) {
    return PlaceContentType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => PlaceContentType.defaultType,
    );
  }
}
