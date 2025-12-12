import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
/// Using Equatable for value comparison
abstract class Failure extends Equatable {
  final String message;
  
  const Failure(this.message);
  
  @override
  List<Object?> get props => [message];
}

/// Server-related failures
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Authentication-related failures
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Cache-related failures
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Validation-related failures
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Unknown/unexpected failures
class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}
