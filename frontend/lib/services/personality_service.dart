import '../core/api_service.dart';
import '../core/api_config.dart';
import 'auth_service.dart';

class PersonalityService {
  static final PersonalityService _instance = PersonalityService._internal();
  factory PersonalityService() => _instance;
  PersonalityService._internal();

  final _apiService = ApiService();
  final _authService = AuthService();

  // Get personality quiz questions
  Future<List<Map<String, dynamic>>> getQuizQuestions() async {
    try {
      final response = await _apiService.get(
        '${ApiConfig.personalityPath}/questions',
      );

      if (response is List) {
        return response.cast<Map<String, dynamic>>();
      } else if (response is Map && response.containsKey('questions')) {
        final questions = response['questions'];
        if (questions is List) {
          return questions.cast<Map<String, dynamic>>();
        }
      }

      return [];
    } catch (e) {
      throw Exception('Failed to get quiz questions: ${e.toString()}');
    }
  }

  // Submit quiz answers
  Future<Map<String, dynamic>> submitQuiz(
      String userId, List<Map<String, dynamic>> answers) async {
    try {
      final response = await _apiService.post(
        '${ApiConfig.personalityPath}/submit',
        {
          'user_id': userId,
          'answers': answers,
        },
      );

      return response;
    } catch (e) {
      throw Exception('Failed to submit quiz: ${e.toString()}');
    }
  }

  // Submit quiz answers in the backend schema format.
  Future<Map<String, dynamic>> submitQuizSubmission({
    required String userId,
    required List<Map<String, dynamic>> answers,
  }) async {
    try {
      final response = await _apiService.post(
        '${ApiConfig.personalityPath}/submit',
        {
          'user_id': userId,
          'answers': answers,
        },
      );

      if (response is Map<String, dynamic>) {
        return response;
      }

      return Map<String, dynamic>.from(response as Map);
    } catch (e) {
      throw Exception('Failed to submit quiz: ${e.toString()}');
    }
  }

  // Get personality scores
  Future<Map<String, dynamic>> getPersonalityScores(String userId) async {
    try {
      final response = await _apiService.get(
        '${ApiConfig.personalityPath}/scores/$userId',
      );

      return response;
    } catch (e) {
      throw Exception('Failed to get personality scores: ${e.toString()}');
    }
  }

  // Update personality scores
  Future<Map<String, dynamic>> updatePersonalityScores(
      String userId, Map<String, dynamic> scores) async {
    try {
      final token = await _authService.getAuthToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await _apiService.put(
        '${ApiConfig.personalityPath}/$userId',
        scores,
        token: token,
      );

      return response;
    } catch (e) {
      throw Exception('Failed to update personality scores: ${e.toString()}');
    }
  }
}
