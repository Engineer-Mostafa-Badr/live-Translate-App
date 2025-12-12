import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for user sign in with Google
/// Follows the Single Responsibility Principle
class GoogleSignInUseCase {
  final AuthRepository repository;

  GoogleSignInUseCase(this.repository);

  /// Execute the Google sign in operation
  /// 
  /// Returns:
  /// - Right(UserEntity) on success
  /// - Left(Failure) on error
  Future<Either<Failure, UserEntity>> call() async {
    return await repository.signInWithGoogle();
  }
}
