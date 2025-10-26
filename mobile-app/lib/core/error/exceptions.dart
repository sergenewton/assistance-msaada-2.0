// Custom Exceptions
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  
  const ServerException(this.message, [this.statusCode]);
  
  @override
  String toString() => 'ServerException: $message (Code: $statusCode)';
}

class NetworkException implements Exception {
  final String message;
  
  const NetworkException(this.message);
  
  @override
  String toString() => 'NetworkException: $message';
}

class CacheException implements Exception {
  final String message;
  
  const CacheException(this.message);
  
  @override
  String toString() => 'CacheException: $message';
}

class ValidationException implements Exception {
  final String message;
  final Map<String, List<String>>? errors;
  
  const ValidationException(this.message, [this.errors]);
  
  @override
  String toString() => 'ValidationException: $message';
}

class AuthenticationException implements Exception {
  final String message;
  
  const AuthenticationException(this.message);
  
  @override
  String toString() => 'AuthenticationException: $message';
}

class AuthorizationException implements Exception {
  final String message;
  
  const AuthorizationException(this.message);
  
  @override
  String toString() => 'AuthorizationException: $message';
}

class BiometricException implements Exception {
  final String message;
  
  const BiometricException(this.message);
  
  @override
  String toString() => 'BiometricException: $message';
}

class FileUploadException implements Exception {
  final String message;
  
  const FileUploadException(this.message);
  
  @override
  String toString() => 'FileUploadException: $message';
}