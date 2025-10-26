import 'package:equatable/equatable.dart';

// Base Failure class
abstract class Failure extends Equatable {
  final String message;
  final int? code;
  
  const Failure(this.message, [this.code]);
  
  @override
  List<Object?> get props => [message, code];
}

// Specific Failure types
class ServerFailure extends Failure {
  const ServerFailure(String message, [int? code]) : super(message, code);
}

class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}

class ValidationFailure extends Failure {
  final Map<String, List<String>>? errors;
  
  const ValidationFailure(String message, [this.errors, int? code]) 
      : super(message, code);
  
  @override
  List<Object?> get props => [message, code, errors];
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure(String message) : super(message);
}

class AuthorizationFailure extends Failure {
  const AuthorizationFailure(String message) : super(message);
}

class BiometricFailure extends Failure {
  const BiometricFailure(String message) : super(message);
}

class FileUploadFailure extends Failure {
  const FileUploadFailure(String message) : super(message);
}

class UnknownFailure extends Failure {
  const UnknownFailure(String message) : super(message);
}