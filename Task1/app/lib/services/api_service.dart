import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // For web use localhost, for Android emulator use 10.0.2.2.
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:4000/api';
    // Android emulator
    return 'http://10.0.2.2:4000/api';
    // If running on a real device, change to your machine IP:
    // return 'http://192.168.x.y:4000/api';
  }

  // REGISTER
  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    final body = res.body.isNotEmpty ? jsonDecode(res.body) : {};
    if (res.statusCode == 200 || res.statusCode == 201) {
      // store token + user
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', body['token']);
      await prefs.setString('user', jsonEncode(body['user']));
      return {'success': true, 'data': body};
    } else {
      return {'success': false, 'message': body['message'] ?? 'Register failed'};
    }
  }

  // LOGIN
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
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
