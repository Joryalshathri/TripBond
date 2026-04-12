import '../core/api_service.dart';
import '../core/api_config.dart';
import 'auth_service.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final _apiService = ApiService();
  final _authService = AuthService();

  // Get current user's profile
  Future<Map<String, dynamic>> getMyProfile() async {
    try {
      final token = await _authService.getAuthToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await _apiService.get(
        '${ApiConfig.usersPath}/me',
        token: token,
      );

      return response;
    } catch (e) {
      throw Exception('Failed to get profile: ${e.toString()}');
    }
  }

  // Get user profile by ID
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final response = await _apiService.get(
        '${ApiConfig.usersPath}/$userId/profile',
      );

      return response;
    } catch (e) {
      throw Exception('Failed to get user profile: ${e.toString()}');
    }
  }

  // Update profile
  Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> updates) async {
    try {
      final token = await _authService.getAuthToken();
      final userId = await _authService.getUserId();
      if (token == null) {
        throw Exception('Not authenticated');
      }
      if (userId == null || userId.isEmpty) {
        throw Exception('User ID not found');
      }

      final response = await _apiService.put(
        '${ApiConfig.usersPath}/$userId/profile',
        updates,
        token: token,
      );

      return response;
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  // Get user settings
  Future<Map<String, dynamic>> getSettings() async {
    try {
      final token = await _authService.getAuthToken();
      final userId = await _authService.getUserId();
      if (token == null) {
        throw Exception('Not authenticated');
      }
      if (userId == null || userId.isEmpty) {
        throw Exception('User ID not found');
      }

      final response = await _apiService.get(
        '${ApiConfig.usersPath}/$userId/settings',
        token: token,
      );

      return response;
    } catch (e) {
      throw Exception('Failed to get settings: ${e.toString()}');
    }
  }

  // Update settings
  Future<Map<String, dynamic>> updateSettings(
      Map<String, dynamic> settings) async {
    try {
      final token = await _authService.getAuthToken();
      final userId = await _authService.getUserId();
      if (token == null) {
        throw Exception('Not authenticated');
      }
      if (userId == null || userId.isEmpty) {
        throw Exception('User ID not found');
      }

      final response = await _apiService.put(
        '${ApiConfig.usersPath}/$userId/settings',
        settings,
        token: token,
      );

      return response;
    } catch (e) {
      throw Exception('Failed to update settings: ${e.toString()}');
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      final token = await _authService.getAuthToken();
      final userId = await _authService.getUserId();
      if (token == null) {
        throw Exception('Not authenticated');
      }
      if (userId == null || userId.isEmpty) {
        throw Exception('User ID not found');
      }

      await _apiService.delete(
        '${ApiConfig.usersPath}/$userId',
        token: token,
      );
    } catch (e) {
      throw Exception('Failed to delete account: ${e.toString()}');
    }
  }

  // Upload profile picture
  Future<Map<String, dynamic>> uploadProfilePicture(
      String userId, String filePath) async {
    try {
      final token = await _authService.getAuthToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      // TODO: Implement multipart file upload
      // This will require multipart/form-data upload
      throw UnimplementedError('Profile picture upload not yet implemented');
    } catch (e) {
      throw Exception('Failed to upload profile picture: ${e.toString()}');
    }
  }
}
