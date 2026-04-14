import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;

class ApiConfig {
  // Backend API base URL
  // Priority:
  // 1) --dart-define=API_BASE_URL=<url>
  // 2) Web default: localhost
  // 3) Mobile/desktop default: Android emulator host mapping
  static String get baseUrl {
    const configuredBaseUrl =
        String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (configuredBaseUrl.isNotEmpty) {
      return configuredBaseUrl;
    }

    if (kIsWeb) {
      return 'http://localhost:8000';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      // Android emulator maps host localhost through 10.0.2.2.
      return 'http://10.0.2.2:8000';
    }

    // Desktop/iOS simulators can use localhost directly.
    return 'http://localhost:8000';
  }

  // Google API Key for Maps/Places/Geocoding
  static const String googleApiKey = 'AIzaSyAAID68aVlsYvCbhKMa5YKGvigSL9_xYIc';

  // API endpoints
  static const String authPath = '/api/auth';
  static const String usersPath = '/api/users';
  static const String tripsPath = '/api/trips';
  static const String personalityPath = '/api/personality';
  static const String preferencesPath = '/api/preferences';
  static const String groupPath = '/api/group';
  static const String favoritesPath = '/api/favorites';
  static const String feedbackPath = '/api/feedback';
  static const String poisPath = '/api/pois';
  static const String placesPath = '/api/places';
  static const String chatPath = '/api/chat';
  static const String aiPath = '/api/ai';

  // Request timeout
  static const Duration requestTimeout = Duration(seconds: 30);

  // Headers
  static Map<String, String> headers({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }
}
