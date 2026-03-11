class ApiConfig {
  // Backend API base URL
  // For Android emulator: use 10.0.2.2 (maps to host machine's localhost)
  // For physical device: use your computer's IP address (e.g., 192.168.x.x)
  static const String baseUrl = 'http://10.0.2.2:8000';

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
