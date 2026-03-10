class ApiConfig {
  // Backend API base URL
  // Use your computer's IP address for Android emulator
  static const String baseUrl = 'http://192.168.3.114:8000';

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
