import 'package:meta/meta.dart';

@immutable
class GetMapQueryDto {
  final int z;
  final int x;
  final int y;
  final String? search;

  const GetMapQueryDto({
    required this.z,
    required this.x,
    required this.y,
    this.search,
  }) : assert(z >= 0, 'z must be >= 0'),
       assert(x >= 0, 'x must be >= 0'),
       assert(y >= 0, 'y must be >= 0');

  Map<String, dynamic> toQuery() {
    return {
      'z': z,
      'x': x,
      'y': y,
      if (search != null && search!.trim().isNotEmpty) 'search': search!.trim(),
    };
  }

  GetMapQueryDto copyWith({int? z, int? x, int? y, String? search}) {
    return GetMapQueryDto(
      z: z ?? this.z,
      x: x ?? this.x,
      y: y ?? this.y,
      search: search ?? this.search,
    );
  }

  @override
  String toString() {
    return 'GetMapQueryDto(z: $z, x: $x, y: $y, search: $search)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GetMapQueryDto &&
        other.z == z &&
        other.x == x &&
        other.y == y &&
        other.search == search;
  }

  @override
  int get hashCode {
    return z.hashCode ^ x.hashCode ^ y.hashCode ^ search.hashCode;
  }
}
