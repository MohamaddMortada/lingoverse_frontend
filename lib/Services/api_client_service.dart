import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClientService {
  final String baseUrl;

  ApiClientService({required this.baseUrl});

  Future<ApiResponse> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.get(url);
    return _handleResponse(response);
  }

  Future<ApiResponse> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<ApiResponse> put(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json','Accept': 'application/json',},
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<ApiResponse> delete(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.delete(url);
    return _handleResponse(response);
  }

  ApiResponse _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return ApiResponse(success: true, data: data);
    } else {
      return ApiResponse(success: false, error: response.body);
    }
  }
}

class ApiResponse {
  final bool success;
  final dynamic data;
  final String? error;

  ApiResponse({required this.success, this.data, this.error});
}
