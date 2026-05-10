import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/role.dart';

// const String kBaseUrl = 'http://localhost:3030';
const String kBaseUrl = 'http://10.0.2.2:3030';
const String _tokenKey = 'jwt_token';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  String? _token;

  Map<String, String> get _authHeaders => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
  }

  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  bool get isLoggedIn => _token != null;

  // AUTHENTICATION

  Future<User> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$kBaseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ApiException(
        body['message']?.toString() ?? 'Login falhou',
        statusCode: response.statusCode,
      );
    }

    await saveToken(body['token'] as String);
    return User.fromJson(body);
  }

  // USERS

  Future<List<User>> getUsers() async {
    final response = await http.get(
      Uri.parse('$kBaseUrl/users'),
      headers: _authHeaders,
    );
    _checkAuth(response);
    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<User> createUser(User user) async {
    final response = await http.post(
      Uri.parse('$kBaseUrl/users'),
      headers: _authHeaders,
      body: jsonEncode(user.toJson()),
    );
    _checkAuth(response);
    if (response.statusCode != 200 && response.statusCode != 201) {
      _throwError(response);
    }
    return User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<User> updateUser(int id, User user) async {
    final response = await http.put(
      Uri.parse('$kBaseUrl/users/$id'),
      headers: _authHeaders,
      body: jsonEncode(user.toJson()),
    );
    _checkAuth(response);
    if (response.statusCode != 200 && response.statusCode != 201) {
      _throwError(response);
    }
    return User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> deleteUser(int id) async {
    final response = await http.delete(
      Uri.parse('$kBaseUrl/users/$id'),
      headers: _authHeaders,
    );
    _checkAuth(response);
    if (response.statusCode != 200 && response.statusCode != 201) {
      _throwError(response);
    }
  }

  // ROLES

  Future<List<Role>> getRoles() async {
    final response = await http.get(
      Uri.parse('$kBaseUrl/roles'),
      headers: _authHeaders,
    );
    _checkAuth(response);
    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) => Role.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Role> createRole(Role role) async {
    final response = await http.post(
      Uri.parse('$kBaseUrl/roles'),
      headers: _authHeaders,
      body: jsonEncode(role.toJson()),
    );
    _checkAuth(response);
    if (response.statusCode != 200 && response.statusCode != 201) {
      _throwError(response);
    }
    return Role.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> deleteRole(int id) async {
    final response = await http.delete(
      Uri.parse('$kBaseUrl/roles/$id'),
      headers: _authHeaders,
    );
    _checkAuth(response);
    if (response.statusCode != 200 && response.statusCode != 201) {
      _throwError(response);
    }
  }

  // HELPERS

  void _checkAuth(http.Response response) {
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw ApiException(
        'Sessão expirada. Faça login novamente.',
        statusCode: response.statusCode,
      );
    }
  }

  void _throwError(http.Response response) {
    String message = 'Erro desconhecido';
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      message = body['message']?.toString() ?? message;
    } catch (_) {}
    throw ApiException(message, statusCode: response.statusCode);
  }
}
