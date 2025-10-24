import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure();
}

// General failures
class ServerFailure extends Failure {
  final String message;

  const ServerFailure(this.message);

  @override
  List<Object> get props => [message];
}

class CacheFailure extends Failure {
  @override
  List<Object> get props => [];
}

class NetworkFailure extends Failure {
  @override
  List<Object> get props => [];
}

class ValidationFailure extends Failure {
  final String message;

  const ValidationFailure(this.message);

  @override
  List<Object> get props => [message];
}

class AuthenticationFailure extends Failure {
  final String message;

  const AuthenticationFailure(this.message);

  @override
  List<Object> get props => [message];
}