import '../core/api_service.dart';
import '../core/api_config.dart';
import 'auth_service.dart';

class FavoritesService {
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;
  FavoritesService._internal();

  final _apiService = ApiService();
  final _authService = AuthService();

  // Get user's favorites
  Future<List<Map<String, dynamic>>> getMyFavorites() async {
    try {
      final token = await _authService.getAuthToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await _apiService.get(
        '${ApiConfig.favoritesPath}/me',
        token: token,
      );

      if (response is List) {
        return response.cast<Map<String, dynamic>>();
      } else if (response is Map && response.containsKey('favorites')) {
        final favorites = response['favorites'];
        if (favorites is List) {
          return favorites.cast<Map<String, dynamic>>();
        }
      }

      return [];
    } catch (e) {
      throw Exception('Failed to get favorites: ${e.toString()}');
    }
  }

  // Add to favorites
  Future<Map<String, dynamic>> addFavorite({
    required String entityType,
    required String entityId,
  }) async {
    try {
      final token = await _authService.getAuthToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await _apiService.post(
        ApiConfig.favoritesPath,
        {
          'entity_type': entityType,
          'entity_id': entityId,
        },
        token: token,
      );

      return response;
    } catch (e) {
      throw Exception('Failed to add favorite: ${e.toString()}');
    }
  }

  // Remove from favorites
  Future<void> removeFavorite(String favoriteId) async {
    try {
      final token = await _authService.getAuthToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      await _apiService.delete(
        '${ApiConfig.favoritesPath}/$favoriteId',
        token: token,
      );
    } catch (e) {
      throw Exception('Failed to remove favorite: ${e.toString()}');
    }
  }

  // Check if entity is favorited
  Future<bool> isFavorited({
    required String entityType,
    required String entityId,
  }) async {
    try {
      final token = await _authService.getAuthToken();
      if (token == null) {
        return false;
      }

      final response = await _apiService.get(
        '${ApiConfig.favoritesPath}/check',
        queryParams: {
          'entity_type': entityType,
          'entity_id': entityId,
        },
        token: token,
      );

      return response['is_favorited'] == true;
    } catch (e) {
      return false;
    }
  }
}
