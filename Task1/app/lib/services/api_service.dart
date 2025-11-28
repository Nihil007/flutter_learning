import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:4000/api';
    return 'http://10.0.2.2:4000/api';
    // For physical device: return 'http://192.168.x.y:4000/api';
  }

  // REGISTER
  static Future<Map<String, dynamic>> register(String name, String email, String mobile, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'mobile': mobile, 'password': password}),
    );
    final body = res.body.isNotEmpty ? jsonDecode(res.body) : {};
    if (res.statusCode == 201 || res.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', body['token']);
      await prefs.setString('user', jsonEncode(body['user']));
      return {'success': true, 'data': body};
    } else {
      return {'success': false, 'message': body['message'] ?? 'Register failed'};
    }
  }

  // LOGIN
  static Future<Map<String, dynamic>> login(String identifier, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'identifier': identifier, 'password': password}),
    );
    final body = res.body.isNotEmpty ? jsonDecode(res.body) : {};
    if (res.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', body['token']);
      await prefs.setString('user', jsonEncode(body['user']));
      return {'success': true, 'data': body};
    } else {
      return {'success': false, 'message': body['message'] ?? 'Login failed'};
    }
  }

  // FORGOT (send OTP via Twilio)
  static Future<Map<String, dynamic>> forgotPasswordSms(String mobile) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/password/forgot-sms'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mobile': mobile}),
      );

      final body = res.body.isNotEmpty ? jsonDecode(res.body) : {};

      if (res.statusCode == 200) {
        return {
          'success': true,
          'message': body['message'] ?? 'OTP sent if mobile is registered'
        };
      } else {
        return {
          'success': false,
          'message': body['message'] ?? 'Failed to send OTP'
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // VERIFY OTP (returns resetToken on success)
  static Future<Map<String, dynamic>> verifyOtp(String mobile, String otp) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/password/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mobile': mobile, 'otp': otp}),
      );

      final body = res.body.isNotEmpty ? jsonDecode(res.body) : {};

      if (res.statusCode == 200 && body['resetToken'] != null) {
        return {
          'success': true,
          'resetToken': body['resetToken'],
          'message': body['message'] ?? 'OTP verified'
        };
      } else {
        return {
          'success': false,
          'message': body['message'] ?? 'OTP verification failed'
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // RESET WITH TOKEN (use token received after OTP verify)
  static Future<Map<String, dynamic>> resetWithToken(String token, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/password/reset-with-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token, 'password': password}),
      );

      final body = res.body.isNotEmpty ? jsonDecode(res.body) : {};

      if (res.statusCode == 200) {
        return {
          'success': true,
          'message': body['message'] ?? 'Password reset successful'
        };
      } else {
        return {
          'success': false,
          'message': body['message'] ?? 'Password reset failed'
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // LOGOUT
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }

  // Get current user (local)
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString('user');
    if (s == null) return null;
    return jsonDecode(s) as Map<String, dynamic>;
  }
}
