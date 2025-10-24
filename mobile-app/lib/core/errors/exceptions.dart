class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}

class CacheException implements Exception {}

class NetworkException implements Exception {}

class AuthenticationException implements Exception {
  final String message;
  AuthenticationException(this.message);
}

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);
}