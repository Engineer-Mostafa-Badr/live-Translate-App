import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for user login with email and password
/// Follows the Single Responsibility Principle
class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  /// Execute the login operation
  /// 
  /// Parameters:
  /// - [email]: User's email address
  /// - [password]: User's password
  /// 
  /// Returns:
  /// - Right(UserEntity) on success
  /// - Left(Failure) on error
  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
  }) async {
    // Validate inputs
    if (email.isEmpty) {
      return const Left(ValidationFailure('Email cannot be empty'));
    }
    
    if (password.isEmpty) {
      return const Left(ValidationFailure('Password cannot be empty'));
    }
    
    // Validate email format
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return const Left(ValidationFailure('Invalid email format'));
    }
    
    // Call repository
    return await repository.signInWithEmail(
      email: email,
      password: password,
    );
  }
}
