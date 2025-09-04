import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/custom_token_response.dart';
import '../models/user_profile_response.dart';

class CustomTokenService {
  static const String _baseUrl = 'http://localhost:3000/api';
  static const Duration _timeout = Duration(seconds: 30);

  // Generate custom token for a user
  static Future<CustomTokenResponse> generateCustomToken(String uid) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return CustomTokenResponse(
          success: false,
          error: 'Unauthorized',
          message: 'User not authenticated',
        );
      }

      final idToken = await user.getIdToken(true);

      final response = await http
          .post(
            Uri.parse('$_baseUrl/generateCustomToken'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $idToken',
            },
            body: json.encode({'uid': uid}),
          )
          .timeout(_timeout);

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return CustomTokenResponse.fromJson(responseData);
      } else {
        return CustomTokenResponse(
          success: false,
          error: responseData['error'] ?? 'Unknown error',
          message: responseData['message'] ?? 'Failed to generate custom token',
        );
      }
    } catch (e) {
      return CustomTokenResponse(
        success: false,
        error: 'NetworkError',
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Get user profile from server
  static Future<UserProfileResponse> getUserProfile(String uid) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return UserProfileResponse(
          success: false,
          error: 'Unauthorized',
          message: 'User not authenticated',
        );
      }

      final idToken = await user.getIdToken(true);

      final response = await http.get(
        Uri.parse('$_baseUrl/userProfile/$uid'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      ).timeout(_timeout);

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return UserProfileResponse.fromJson(responseData);
      } else {
        return UserProfileResponse(
          success: false,
          error: responseData['error'] ?? 'Unknown error',
          message: responseData['message'] ?? 'Failed to get user profile',
        );
      }
    } catch (e) {
      return UserProfileResponse(
        success: false,
        error: 'NetworkError',
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Check server health
  static Future<bool> checkServerHealth() async {
    try {
      final response = await http
          .get(Uri.parse('${_baseUrl.replaceAll('/api', '')}/health'))
          .timeout(_timeout);

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Validate custom token format (basic validation)
  static bool isValidCustomTokenFormat(String token) {
    try {
      // Basic JWT format validation (3 parts separated by dots)
      final parts = token.split('.');
      if (parts.length != 3) return false;

      // Check if parts are base64 encoded
      for (final part in parts) {
        if (part.isEmpty) return false;
        // Try to decode base64
        base64Url.decode(base64Url.normalize(part));
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Extract user information from custom token (without verification)
  static Map<String, dynamic>? extractTokenPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = base64Url.decode(base64Url.normalize(parts[1]));
      final payloadString = utf8.decode(payload);
      return json.decode(payloadString);
    } catch (e) {
      return null;
    }
  }

  // Check if token is likely expired (basic check based on 'exp' claim)
  static bool isTokenLikelyExpired(String token) {
    try {
      final payload = extractTokenPayload(token);
      if (payload == null || payload['exp'] == null) return true;

      final exp = payload['exp'] as int;
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // Consider token expired if it expires within 5 minutes
      return (exp - now) < 300;
    } catch (e) {
      return true;
    }
  }

  // Generate custom token with retry logic
  static Future<CustomTokenResponse> generateCustomTokenWithRetry(
    String uid, {
    int maxRetries = 3,
  }) async {
    int attempts = 0;

    while (attempts < maxRetries) {
      attempts++;

      final response = await generateCustomToken(uid);

      if (response.success) {
        return response;
      }

      // If it's a network error and we haven't reached max retries, try again
      if (response.error == 'NetworkError' && attempts < maxRetries) {
        await Future.delayed(
            Duration(seconds: attempts * 2)); // Exponential backoff
        continue;
      }

      return response;
    }

    return CustomTokenResponse(
      success: false,
      error: 'MaxRetriesExceeded',
      message: 'Failed to generate custom token after $maxRetries attempts',
    );
  }
}
