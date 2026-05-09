import '../core/api_config.dart';
import '../core/api_service.dart';

class CityInfo {
  final String name;
  final String province;
  final String country;
  final int count;
  final double? lat;
  final double? lng;
  final String? imageAsset;
  final bool isFeatured;

  const CityInfo({
    required this.name,
    required this.province,
    required this.country,
    required this.count,
    required this.lat,
    required this.lng,
    required this.imageAsset,
    required this.isFeatured,
  });

  factory CityInfo.fromJson(Map<String, dynamic> json) {
    return CityInfo(
      name: (json['name'] ?? '').toString(),
      province: (json['province'] ?? '').toString(),
      country: (json['country'] ?? '').toString(),
      count: (json['count'] as num?)?.toInt() ?? 0,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      imageAsset:
          (json['image_asset'] is String && (json['image_asset'] as String).isNotEmpty)
              ? json['image_asset'] as String
              : null,
      isFeatured: json['is_featured'] == true,
    );
  }
}

class CityService {
  static final CityService _instance = CityService._internal();
  factory CityService() => _instance;
  CityService._internal();

  final _api = ApiService();
  List<CityInfo>? _cache;

  Future<List<CityInfo>> listCities({bool forceRefresh = false}) async {
    if (!forceRefresh && _cache != null) return _cache!;
    final response = await _api.get('${ApiConfig.placesPath}/cities');
    if (response is List) {
      _cache = response
          .whereType<Map<String, dynamic>>()
          .map(CityInfo.fromJson)
          .toList();
    } else {
      _cache = [];
    }
    return _cache!;
  }
}
