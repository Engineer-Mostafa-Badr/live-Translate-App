import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for user sign up with email and password
/// Follows the Single Responsibility Principle
class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  /// Execute the sign up operation
  /// 
  /// Parameters:
  /// - [email]: User's email address
  /// - [password]: User's password
  /// - [displayName]: User's display name
  /// 
  /// Returns:
  /// - Right(UserEntity) on success
  /// - Left(Failure) on error
  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
    required String displayName,
  }) async {
    // Validate inputs
    if (email.isEmpty) {
      return const Left(ValidationFailure('Email cannot be empty'));
    }
    
    if (password.isEmpty) {
      return const Left(ValidationFailure('Password cannot be empty'));
    }
    
    if (password.length < 6) {
      return const Left(ValidationFailure('Password must be at least 6 characters'));
    }
    
    if (displayName.isEmpty) {
      return const Left(ValidationFailure('Display name cannot be empty'));
    }
    
    // Validate email format
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return const Left(ValidationFailure('Invalid email format'));
    }
    
    // Call repository
    return await repository.signUpWithEmail(
      email: email,
      password: password,
      displayName: displayName,
    );
  }
}
