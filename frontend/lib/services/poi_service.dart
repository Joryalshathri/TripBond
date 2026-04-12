import '../core/api_service.dart';
import '../core/api_config.dart';

class POIService {
  static final POIService _instance = POIService._internal();
  factory POIService() => _instance;
  POIService._internal();

  final _apiService = ApiService();

  /// Search and filter Points of Interest
  ///
  /// Parameters:
  /// - location: Filter by location (optional)
  /// - type: Filter by type - 'attraction', 'restaurant', 'hotel', etc. (optional)
  /// - minRating: Minimum rating (0-5) (optional)
  /// - maxPriceLevel: Maximum price level (1-4) (optional)
  /// - tags: Comma-separated tags to filter by (optional)
  /// - limit: Maximum number of results (default: 50, max: 100)
  Future<List<Map<String, dynamic>>> searchPOIs({
    String? location,
    String? type,
    double? minRating,
    int? maxPriceLevel,
    String? tags,
    int limit = 50,
  }) async {
    try {
      final params = <String, String>{};
      if (location != null) params['location'] = location;
      if (type != null) params['type'] = type;
      if (minRating != null) params['min_rating'] = minRating.toString();
      if (maxPriceLevel != null)
        params['max_price_level'] = maxPriceLevel.toString();
      if (tags != null) params['tags'] = tags;
      params['limit'] = limit.toString();

      final response = await _apiService.get(
        ApiConfig.poisPath,
        queryParams: params,
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
      throw Exception('Failed to search POIs: ${e.toString()}');
    }
  }

  /// Get detailed information about a specific POI
  Future<Map<String, dynamic>> getPOIDetail(String poiId) async {
    try {
      final response = await _apiService.get(
        '${ApiConfig.poisPath}/$poiId',
      );

      if (response is Map<String, dynamic>) {
        return response;
      }

      throw Exception('Invalid response format');
    } catch (e) {
      throw Exception('Failed to get POI details: ${e.toString()}');
    }
  }

  /// Get top-rated POIs by category
  Future<List<Map<String, dynamic>>> getTopRatedPOIs({
    String? category,
    int limit = 10,
  }) async {
    try {
      final params = <String, String>{'limit': limit.toString()};
      if (category != null) params['type'] = category;

      final response = await _apiService.get(
        ApiConfig.poisPath,
        queryParams: params,
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
      throw Exception('Failed to get top-rated POIs: ${e.toString()}');
    }
  }

  /// Get POIs by tags
  Future<List<Map<String, dynamic>>> getPOIsByTags(List<String> tags) async {
    try {
      final tagsString = tags.join(',');
      final response = await _apiService.get(
        ApiConfig.poisPath,
        queryParams: {'tags': tagsString},
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
      throw Exception('Failed to get POIs by tags: ${e.toString()}');
    }
  }
}
