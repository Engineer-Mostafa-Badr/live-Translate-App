import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

/// Use case for user logout
/// Follows the Single Responsibility Principle
class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  /// Execute the logout operation
  /// Signs out from both Firebase and Google
  /// 
  /// Returns:
  /// - Right(void) on success
  /// - Left(Failure) on error
  Future<Either<Failure, void>> call() async {
    return await repository.signOut();
  }
}
