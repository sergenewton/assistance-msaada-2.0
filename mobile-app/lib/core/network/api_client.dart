import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../error/exceptions.dart';

class ApiClient {
  late final Dio _dio;
  String? _accessToken;
  
  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: Duration(milliseconds: ApiConstants.connectTimeout),
      receiveTimeout: Duration(milliseconds: ApiConstants.receiveTimeout),
      headers: ApiConstants.defaultHeaders,
    ));
    
    _setupInterceptors();
  }
  
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_accessToken != null) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          _handleError(error);
          handler.next(error);
        },
      ),
    );
  }
  
  void setAccessToken(String token) {
    _accessToken = token;
  }
  
  void clearAccessToken() {
    _accessToken = null;
  }
  
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Exception _handleError(dynamic error) {
    if (error is DioError) {
      switch (error.type) {
        case DioErrorType.connectTimeout:
        case DioErrorType.sendTimeout:
        case DioErrorType.receiveTimeout:
          return const NetworkException('Connection timeout');
        case DioErrorType.response:
          final statusCode = error.response?.statusCode;
          final message = error.response?.data?['message'] ?? 'Server error';
          return ServerException(message, statusCode);
        case DioErrorType.cancel:
          return const NetworkException('Request cancelled');
        default:
          return const NetworkException('Network error');
      }
    }
    
    if (error is SocketException) {
      return const NetworkException('No internet connection');
    }
    
    return ServerException(error.toString());
  }
}