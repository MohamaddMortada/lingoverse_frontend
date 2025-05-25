import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:8000/api'));

  Future<bool> login(String email, String password) async {
    try {
      final response = await _dio.post('/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        String token = response.data['token'];

        final profileResponse = await _dio.get(
          '/me',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );

        int userId = profileResponse.data['id'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setInt('user_id', userId); 
        return true;
      }
    } catch (e) {
      print("Login Error: $e");
    }
    return false;
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      final response = await _dio.post('/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        String token = response.data['token'];
        int userId = response.data['user']['id'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setInt('user_id', userId); 
        return true;
      }
    } catch (e) {
      print("Register Error: $e");
    }
    return false;
  }

  Future<void> logout() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token != null) {
        await _dio.post(
          '/logout',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
        await prefs.remove('token');
        await prefs.remove('user_id');
      }
    } catch (e) {
      print("Logout Error: $e");
    }
  }

  Future<bool> isAuthenticated() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }

  Future<Map<String, dynamic>?> getProfile() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token != null) {
        final response = await _dio.get(
          '/me',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
        return response.data;
      }
    } catch (e) {
      print("Profile fetch error: $e");
    }
    return null;
  }
}
