import 'dart:convert';
import 'package:http/http.dart' as http;

class PasswordResetManager {
  static const String _baseUrl = 'http://localhost:3000/api';

  // Send password reset email
  static Future<bool> sendPasswordResetEmail(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/sendPasswordReset'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error sending password reset: $e');
      return false;
    }
  }

  // Verify reset token
  static Future<Map<String, dynamic>?> verifyResetToken(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/verifyResetToken'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error verifying token: $e');
      return null;
    }
  }

  // Reset password with token
  static Future<bool> resetPassword(String token, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/resetPassword'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': token,
          'newPassword': newPassword,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error resetting password: $e');
      return false;
    }
  }
}
