import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:http/http.dart' as http;

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    } else {
      return 'http://10.0.2.2:8000/api';
    }
  }

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/login');
    final body = jsonEncode({'email': email, 'password': password});

    try {
      final response = await http.post(url, headers: _headers, body: body);

      debugPrint('Login URL: $url');
      debugPrint('Login Status: ${response.statusCode}');
      debugPrint('Login Response: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'token': data['token'] ?? data['data']?['token'],
          'user': data['user'] ?? data['data']?['user'],
          'message': data['message'] ?? 'Giriş başarılı',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'E-posta veya şifre hatalı',
          'errors': data['errors'],
        };
      }
    } catch (e) {
      debugPrint('Login Error: $e');
      return {'success': false, 'message': 'Bağlantı hatası: $e'};
    }
  }

  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    final url = Uri.parse('$baseUrl/register');

    final body = jsonEncode({
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });

    try {
      final response = await http.post(url, headers: _headers, body: body);

      debugPrint('Register Status: ${response.statusCode}');
      debugPrint('Register Response: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || data['success'] == true) {
        return {
          'success': true,
          'token': data['token'] ?? data['data']?['token'],
          'user': data['user'] ?? data['data']?['user'],
          'message': data['message'] ?? 'Kayıt başarılı',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Kayıt başarısız',
          'errors': data['errors'],
        };
      }
    } catch (e) {
      debugPrint('Register Error: $e');
      return {'success': false, 'message': 'Bağlantı hatası: $e'};
    }
  }

  static Future<Map<String, dynamic>> getStatistics(String token) async {
    final url = Uri.parse('$baseUrl/statistics');

    try {
      final response = await http.get(
        url,
        headers: {..._headers, 'Authorization': 'Bearer $token'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'statistics': data['statistics'] ?? data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'İstatistikler yüklenemedi',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateStatistics(
    String token,
    Map<String, dynamic> statistics,
  ) async {
    final url = Uri.parse('$baseUrl/statistics');

    try {
      final response = await http.put(
        url,
        headers: {..._headers, 'Authorization': 'Bearer $token'},
        body: jsonEncode(statistics),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'İstatistikler güncellendi',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'İstatistikler güncellenemedi',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: $e'};
    }
  }

  static Future<Map<String, dynamic>> getTasks(String token) async {
    final url = Uri.parse('$baseUrl/tasks');

    try {
      final response = await http.get(
        url,
        headers: {..._headers, 'Authorization': 'Bearer $token'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'tasks': data['tasks'] ?? data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Görevler yüklenemedi',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateTasks(
    String token,
    Map<String, dynamic> tasks,
  ) async {
    final url = Uri.parse('$baseUrl/tasks');

    try {
      final response = await http.put(
        url,
        headers: {..._headers, 'Authorization': 'Bearer $token'},
        body: jsonEncode(tasks),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Görevler güncellendi',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Görevler güncellenemedi',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: $e'};
    }
  }
}
