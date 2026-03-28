import '../core/api_service.dart';
import '../core/api_config.dart';

class PlacesService {
  static final PlacesService _instance = PlacesService._internal();
  factory PlacesService() => _instance;
  PlacesService._internal();

  final _apiService = ApiService();

  // Search places by location and query
  Future<List<Map<String, dynamic>>> searchPlaces({
    String? query,
    double? latitude,
    double? longitude,
    int? radius,
    String? type,
  }) async {
    try {
      final queryParams = <String, String>{};

      if (query != null) queryParams['query'] = query;
      if (latitude != null) queryParams['latitude'] = latitude.toString();
      if (longitude != null) queryParams['longitude'] = longitude.toString();
      if (radius != null) queryParams['radius'] = radius.toString();
      if (type != null) queryParams['type'] = type;

      final response = await _apiService.get(
        '${ApiConfig.placesPath}/search',
        queryParams: queryParams,
      );

      if (response is List) {
        return response.cast<Map<String, dynamic>>();
      } else if (response is Map && response.containsKey('places')) {
        final places = response['places'];
        if (places is List) {
          return places.cast<Map<String, dynamic>>();
        }
      }

      return [];
    } catch (e) {
      throw Exception('Failed to search places: ${e.toString()}');
    }
  }

  // Get place details
  Future<Map<String, dynamic>> getPlaceDetails(String placeId) async {
    try {
      final response = await _apiService.get(
        '${ApiConfig.placesPath}/details/$placeId',
      );

      return response;
    } catch (e) {
      throw Exception('Failed to get place details: ${e.toString()}');
    }
  }

  // Get POIs (Points of Interest)
  Future<List<Map<String, dynamic>>> getPOIs({
    String? destination,
    String? category,
    int? limit,
  }) async {
    try {
      final queryParams = <String, String>{};

      if (destination != null) queryParams['destination'] = destination;
      if (category != null) queryParams['category'] = category;
      if (limit != null) queryParams['limit'] = limit.toString();

      final response = await _apiService.get(
        ApiConfig.poisPath,
        queryParams: queryParams,
      );

      if (response is List) {
        return response.cast<Map<String, dynamic>>();
      } else if (response is Map && response.containsKey('pois')) {
        final pois = response['pois'];
        if (pois is List) {
          return pois.cast<Map<String, dynamic>>();
        }
      }

      return [];
    } catch (e) {
      throw Exception('Failed to get POIs: ${e.toString()}');
    }
  }

  // Get POI details
  Future<Map<String, dynamic>> getPOIDetails(String poiId) async {
    try {
      final response = await _apiService.get(
        '${ApiConfig.poisPath}/$poiId',
      );

      return response;
    } catch (e) {
      throw Exception('Failed to get POI details: ${e.toString()}');
    }
  }

  // Get nearby places
  Future<List<Map<String, dynamic>>> getNearbyPlaces({
    required double latitude,
    required double longitude,
    int radius = 5000,
    String? type,
  }) async {
    try {
      final queryParams = {
        'lat': latitude.toString(),
        'lng': longitude.toString(),
        'radius': radius.toString(),
      };

      if (type != null) queryParams['type'] = type;

      final response = await _apiService.get(
        '${ApiConfig.placesPath}/nearby',
        queryParams: queryParams,
      );

      if (response is List) {
        return response.cast<Map<String, dynamic>>();
      } else if (response is Map && response.containsKey('places')) {
        final places = response['places'];
        if (places is List) {
          return places.cast<Map<String, dynamic>>();
        }
      }

      return [];
    } catch (e) {
      throw Exception('Failed to get nearby places: ${e.toString()}');
    }
  }
}
