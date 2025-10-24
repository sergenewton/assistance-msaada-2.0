import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({
    required String email,
    required String password,
  });

  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  });

  Future<void> logout();
  
  Future<UserModel?> getCurrentUser();
  
  Future<void> forgotPassword({
    required String email,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;
  final String baseUrl = 'https://api.vbgplatform.com/v1';

  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await client.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return UserModel.fromJson(jsonResponse['user']);
    } else if (response.statusCode == 401) {
      throw AuthenticationException('Invalid credentials');
    } else {
      throw ServerException('Login failed');
    }
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    final response = await client.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
        'phone': phone,
      }),
    );

    if (response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body);
      return UserModel.fromJson(jsonResponse['user']);
    } else {
      throw ServerException('Registration failed');
    }
  }

  @override
  Future<void> logout() async {
    // Implementation for logout
    final response = await client.post(
      Uri.parse('$baseUrl/auth/logout'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw ServerException('Logout failed');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final response = await client.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return UserModel.fromJson(jsonResponse['user']);
    } else if (response.statusCode == 401) {
      return null;
    } else {
      throw ServerException('Failed to get user');
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    final response = await client.post(
      Uri.parse('$baseUrl/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode != 200) {
      throw ServerException('Failed to send reset email');
    }
  }
}