import '../core/api_service.dart';
import '../core/api_config.dart';
import 'auth_service.dart';

class TripService {
  static final TripService _instance = TripService._internal();
  factory TripService() => _instance;
  TripService._internal();

  final _apiService = ApiService();
  final _authService = AuthService();

  // Get my trips
  Future<List<Map<String, dynamic>>> getMyTrips() async {
    try {
      final token = await _authService.getAuthToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await _apiService.get(
        '${ApiConfig.tripsPath}/me',
        token: token,
      );

      // Response can be a list or a map containing a list
      if (response is List) {
        return response.cast<Map<String, dynamic>>();
      } else if (response is Map && response.containsKey('data')) {
        final data = response['data'];
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        }
      }

      return [];
    } catch (e) {
      throw Exception('Failed to get trips: ${e.toString()}');
    }
  }

  // Get trips by user ID
  Future<List<Map<String, dynamic>>> getTripsByUser(String userId) async {
    try {
      final response = await _apiService.get(
        '${ApiConfig.tripsPath}/user/$userId',
      );

      if (response is List) {
        return response.cast<Map<String, dynamic>>();
      } else if (response is Map && response.containsKey('data')) {
        final data = response['data'];
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        }
      }

      return [];
    } catch (e) {
      throw Exception('Failed to get user trips: ${e.toString()}');
    }
  }

  // Create trip
  Future<Map<String, dynamic>> createTrip(Map<String, dynamic> tripData) async {
    try {
      final token = await _authService.getAuthToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await _apiService.post(
        ApiConfig.tripsPath,
        tripData,
        token: token,
      );

      return response;
    } catch (e) {
      throw Exception('Failed to create trip: ${e.toString()}');
    }
  }

  // Get trip details
  Future<Map<String, dynamic>> getTripDetails(String tripId) async {
    try {
      final token = await _authService.getAuthToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await _apiService.get(
        '${ApiConfig.tripsPath}/$tripId',
        token: token,
      );

      return response;
    } catch (e) {
      throw Exception('Failed to get trip details: ${e.toString()}');
    }
  }

  // Update trip
  Future<Map<String, dynamic>> updateTrip(
      String tripId, Map<String, dynamic> updates) async {
    try {
      final token = await _authService.getAuthToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await _apiService.put(
        '${ApiConfig.tripsPath}/$tripId',
        updates,
        token: token,
      );

      return response;
    } catch (e) {
      throw Exception('Failed to update trip: ${e.toString()}');
    }
  }

  // Delete trip
  Future<void> deleteTrip(String tripId) async {
    try {
      final token = await _authService.getAuthToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      await _apiService.delete(
        '${ApiConfig.tripsPath}/$tripId',
        token: token,
      );
    } catch (e) {
      throw Exception('Failed to delete trip: ${e.toString()}');
    }
  }

  // Get trip members
  Future<List<Map<String, dynamic>>> getTripMembers(String tripId) async {
    try {
      final token = await _authService.getAuthToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await _apiService.get(
        '${ApiConfig.tripsPath}/$tripId/members',
        token: token,
      );

      if (response is List) {
        return response.cast<Map<String, dynamic>>();
      } else if (response is Map && response.containsKey('members')) {
        final members = response['members'];
        if (members is List) {
          return members.cast<Map<String, dynamic>>();
        }
      }

      return [];
    } catch (e) {
      throw Exception('Failed to get trip members: ${e.toString()}');
    }
  }

  // Add trip member
  Future<Map<String, dynamic>> addTripMember(
      String tripId, String userId) async {
    try {
      final token = await _authService.getAuthToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await _apiService.post(
        '${ApiConfig.tripsPath}/$tripId/members',
        {'user_id': userId},
        token: token,
      );

      return response;
    } catch (e) {
      throw Exception('Failed to add trip member: ${e.toString()}');
    }
  }

  // Remove trip member
  Future<void> removeTripMember(String tripId, String userId) async {
    try {
      final token = await _authService.getAuthToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      await _apiService.delete(
        '${ApiConfig.tripsPath}/$tripId/members/$userId',
        token: token,
      );
    } catch (e) {
      throw Exception('Failed to remove trip member: ${e.toString()}');
    }
  }

  // Generate itinerary
  Future<Map<String, dynamic>> generateItinerary(
      String tripId, Map<String, dynamic> preferences) async {
    try {
      final token = await _authService.getAuthToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await _apiService.post(
        '${ApiConfig.tripsPath}/$tripId/itinerary/generate',
        preferences,
        token: token,
      );

      return response;
    } catch (e) {
      throw Exception('Failed to generate itinerary: ${e.toString()}');
    }
  }

  // Get latest itinerary
  Future<Map<String, dynamic>> getLatestItinerary(String tripId) async {
    try {
      final token = await _authService.getAuthToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await _apiService.get(
        '${ApiConfig.tripsPath}/$tripId/itinerary/latest',
        token: token,
      );

      return response;
    } catch (e) {
      throw Exception('Failed to get itinerary: ${e.toString()}');
    }
  }

  // Get POI recommendations
  Future<List<Map<String, dynamic>>> getRecommendations(String tripId) async {
    try {
      final token = await _authService.getAuthToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await _apiService.get(
        '${ApiConfig.tripsPath}/$tripId/recommendations',
        token: token,
      );

      if (response is List) {
        return response.cast<Map<String, dynamic>>();
      } else if (response is Map && response.containsKey('recommendations')) {
        final recommendations = response['recommendations'];
        if (recommendations is List) {
          return recommendations.cast<Map<String, dynamic>>();
        }
      }

      return [];
    } catch (e) {
      throw Exception('Failed to get recommendations: ${e.toString()}');
    }
  }
}
