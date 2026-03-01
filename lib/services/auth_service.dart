import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _secureStorage = const FlutterSecureStorage();

  // Keys
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';

  // Store authentication token securely
  Future<void> saveAuthToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  // Get authentication token
  Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  // Store refresh token
  Future<void> saveRefreshToken(String refreshToken) async {
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
  }

  // Get refresh token
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  // Save user data
  Future<void> saveUserData({
    required String userId,
    required String email,
    required String name,
  }) async {
    await _secureStorage.write(key: _userIdKey, value: userId);
    await _secureStorage.write(key: _userEmailKey, value: email);
    await _secureStorage.write(key: _userNameKey, value: name);
  }

  // Get user email
  Future<String?> getUserEmail() async {
    return await _secureStorage.read(key: _userEmailKey);
  }

  // Get user name
  Future<String?> getUserName() async {
    return await _secureStorage.read(key: _userNameKey);
  }

  // Get user ID
  Future<String?> getUserId() async {
    return await _secureStorage.read(key: _userIdKey);
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getAuthToken();
    if (token == null || token.isEmpty) {
      return false;
    }

    // TODO: Add token expiration check
    // For now, just check if token exists
    return true;
  }

  // Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      // TODO: Replace with actual API call
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock response
      final response = {
        'success': true,
        'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
        'refreshToken': 'mock_refresh_token',
        'user': {
          'id': '12345',
          'email': email,
          'name': 'User Name',
        },
      };

      // Save tokens and user data
      await saveAuthToken(response['token'] as String);
      await saveRefreshToken(response['refreshToken'] as String);

      final user = response['user'] as Map<String, dynamic>;
      await saveUserData(
        userId: user['id'] as String,
        email: user['email'] as String,
        name: user['name'] as String,
      );

      return response;
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // Register
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String dob,
    required String gender,
  }) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock response
      final response = {
        'success': true,
        'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
        'refreshToken': 'mock_refresh_token',
        'user': {
          'id': '12345',
          'email': email,
          'name': name,
        },
      };

      // Save tokens and user data
      await saveAuthToken(response['token'] as String);
      await saveRefreshToken(response['refreshToken'] as String);

      final user = response['user'] as Map<String, dynamic>;
      await saveUserData(
        userId: user['id'] as String,
        email: user['email'] as String,
        name: user['name'] as String,
      );

      return response;
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  // Logout
  Future<void> logout() async {
    // Clear secure storage
    await _secureStorage.deleteAll();

    // Clear shared preferences
    final prefs = await SharedPreferences.getInstance();
    // Keep onboarding_complete flag
    final hasCompletedOnboarding =
        prefs.getBool('onboarding_complete') ?? false;
    await prefs.clear();
    if (hasCompletedOnboarding) {
      await prefs.setBool('onboarding_complete', true);
    }
  }

  // Send password reset code
  Future<void> sendPasswordResetCode(String email) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      throw Exception('Failed to send reset code: ${e.toString()}');
    }
  }

  // Verify reset code
  Future<bool> verifyResetCode(String email, String code) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));
      return true; // Mock success
    } catch (e) {
      throw Exception('Failed to verify code: ${e.toString()}');
    }
  }

  // Reset password
  Future<void> resetPassword(
      String email, String code, String newPassword) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      throw Exception('Failed to reset password: ${e.toString()}');
    }
  }
}
