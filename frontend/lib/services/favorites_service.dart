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
      final userId = await _authService.getUserId();
      if (userId == null || userId.isEmpty) {
        throw Exception('User ID not found');
      }

      final response = await _apiService.get(
        '${ApiConfig.favoritesPath}/$userId',
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
      final userId = await _authService.getUserId();
      if (userId == null || userId.isEmpty) {
        throw Exception('User ID not found');
      }

      final response = await _apiService.post(
        '${ApiConfig.favoritesPath}/$userId',
        {
          'entity_type': entityType,
          'entity_id': entityId,
        },
      );

      return response;
    } catch (e) {
      throw Exception('Failed to add favorite: ${e.toString()}');
    }
  }

  // Remove from favorites
  Future<void> removeFavorite(String favoriteId) async {
    try {
      final userId = await _authService.getUserId();
      if (userId == null || userId.isEmpty) {
        throw Exception('User ID not found');
      }

      await _apiService.delete(
        '${ApiConfig.favoritesPath}/$userId/$favoriteId',
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
      final favorites = await getMyFavorites();
      return favorites.any(
        (favorite) =>
            favorite['entity_type'] == entityType &&
            favorite['entity_id'] == entityId,
      );
    } catch (e) {
      return false;
    }
  }
}
