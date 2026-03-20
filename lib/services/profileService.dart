import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io' show Platform, SocketException;
import '../models.dart'; 

class ProfileService {
  final _storage = const FlutterSecureStorage();
  late final String baseUrl;
  
  ProfileService() {
    baseUrl = _resolveBaseUrl();
  }

  String _resolveBaseUrl() {
    const configuredBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (configuredBaseUrl.isNotEmpty) return configuredBaseUrl;

    if (kIsWeb) return 'http://localhost:8000';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    return 'http://127.0.0.1:8000';
  }

  Future<UserProfile> fetchProfile() async {
    // 1. Get the real User ID we saved during login
    final userId = await _storage.read(key: 'user_id'); 
    
    if (userId == null) throw Exception("User ID not found. Please login again.");

    // 2. Make the call to your FastAPI with timeout
    try {
      final response = await http.get(
      Uri.parse('$baseUrl/profile/$userId'),
      headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        // 3. Convert the Python JSON into our Flutter UserProfile object
        return UserProfile.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load profile: ${response.statusCode} - ${response.body}');
      }
    } on TimeoutException {
      return _buildFallbackProfile(userId);
    } on SocketException catch (e) {
      if (e.osError?.errorCode == 1225 || e.osError?.errorCode == 121) {
        return _buildFallbackProfile(userId);
      }
      rethrow;
    } catch (e) {
      if ('$e'.contains('ClientException')) {
        return _buildFallbackProfile(userId);
      }
      rethrow;
    }
  }

  UserProfile _buildFallbackProfile(String userId) {
    return UserProfile(
      id: userId,
      email: 'offline@tripbond.local',
      fullName: 'TripBond User',
      username: 'tripbond_user',
      bio: 'Offline mode',
      avatarUrl: null,
      pastTripsCount: 0,
      likedPagesCount: 0,
      favoritesCount: 0,
      followers: 0,
      following: 0,
    );
  }
}