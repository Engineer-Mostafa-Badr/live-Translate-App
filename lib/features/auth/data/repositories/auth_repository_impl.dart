import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_service.dart';

/// Implementation of AuthRepository
/// Converts exceptions to failures and delegates to FirebaseAuthService
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthService authService;

  AuthRepositoryImpl({required this.authService});

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = authService.currentUser;
      return Right(user);
    } on AuthException catch (e) {
      Logger.error('Auth exception in getCurrentUser: ${e.message}', tag: 'AUTH_REPO');
      return Left(AuthFailure(e.message));
    } catch (e) {
      Logger.error('Unknown error in getCurrentUser: $e', tag: 'AUTH_REPO');
      return Left(UnknownFailure('Failed to get current user: $e'));
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return authService.authStateChanges;
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final user = await authService.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      return Right(user);
    } on AuthException catch (e) {
      Logger.error('Auth exception in signUpWithEmail: ${e.message}', tag: 'AUTH_REPO');
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      Logger.error('Network exception in signUpWithEmail: ${e.message}', tag: 'AUTH_REPO');
      return Left(NetworkFailure(e.message));
    } catch (e) {
      Logger.error('Unknown error in signUpWithEmail: $e', tag: 'AUTH_REPO');
      return Left(UnknownFailure('Failed to sign up: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final user = await authService.signInWithEmail(
        email: email,
        password: password,
      );
      return Right(user);
    } on AuthException catch (e) {
      Logger.error('Auth exception in signInWithEmail: ${e.message}', tag: 'AUTH_REPO');
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      Logger.error('Network exception in signInWithEmail: ${e.message}', tag: 'AUTH_REPO');
      return Left(NetworkFailure(e.message));
    } catch (e) {
      Logger.error('Unknown error in signInWithEmail: $e', tag: 'AUTH_REPO');
      return Left(UnknownFailure('Failed to sign in: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      final user = await authService.signInWithGoogle();
      return Right(user);
    } on AuthException catch (e) {
      Logger.error('Auth exception in signInWithGoogle: ${e.message}', tag: 'AUTH_REPO');
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      Logger.error('Network exception in signInWithGoogle: ${e.message}', tag: 'AUTH_REPO');
      return Left(NetworkFailure(e.message));
    } catch (e) {
      Logger.error('Unknown error in signInWithGoogle: $e', tag: 'AUTH_REPO');
      return Left(UnknownFailure('Failed to sign in with Google: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await authService.signOut();
      return const Right(null);
    } on AuthException catch (e) {
      Logger.error('Auth exception in signOut: ${e.message}', tag: 'AUTH_REPO');
      return Left(AuthFailure(e.message));
    } catch (e) {
      Logger.error('Unknown error in signOut: $e', tag: 'AUTH_REPO');
      return Left(UnknownFailure('Failed to sign out: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    try {
      await authService.sendPasswordResetEmail(email);
      return const Right(null);
    } on AuthException catch (e) {
      Logger.error('Auth exception in sendPasswordResetEmail: ${e.message}', tag: 'AUTH_REPO');
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      Logger.error('Network exception in sendPasswordResetEmail: ${e.message}', tag: 'AUTH_REPO');
      return Left(NetworkFailure(e.message));
    } catch (e) {
      Logger.error('Unknown error in sendPasswordResetEmail: $e', tag: 'AUTH_REPO');
      return Left(UnknownFailure('Failed to send password reset email: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      await authService.updateUserProfile(
        displayName: displayName,
        photoUrl: photoUrl,
      );
      return const Right(null);
    } on AuthException catch (e) {
      Logger.error('Auth exception in updateUserProfile: ${e.message}', tag: 'AUTH_REPO');
      return Left(AuthFailure(e.message));
    } catch (e) {
      Logger.error('Unknown error in updateUserProfile: $e', tag: 'AUTH_REPO');
      return Left(UnknownFailure('Failed to update profile: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      await authService.deleteAccount();
      return const Right(null);
    } on AuthException catch (e) {
      Logger.error('Auth exception in deleteAccount: ${e.message}', tag: 'AUTH_REPO');
      return Left(AuthFailure(e.message));
    } catch (e) {
      Logger.error('Unknown error in deleteAccount: $e', tag: 'AUTH_REPO');
      return Left(UnknownFailure('Failed to delete account: $e'));
    }
  }
}
