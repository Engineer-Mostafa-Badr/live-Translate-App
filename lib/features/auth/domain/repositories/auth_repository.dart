import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

/// Abstract repository interface for authentication operations
/// This defines the contract that the data layer must implement
abstract class AuthRepository {
  /// Get the current authenticated user
  /// Returns null if no user is authenticated
  Future<Either<Failure, UserEntity?>> getCurrentUser();
  
  /// Stream of authentication state changes
  /// Emits UserEntity when user logs in, null when user logs out
  Stream<UserEntity?> get authStateChanges;
  
  /// Sign up with email and password
  /// Returns the created user entity on success
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  });
  
  /// Sign in with email and password
  /// Returns the authenticated user entity on success
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });
  
  /// Sign in with Google
  /// Returns the authenticated user entity on success
  Future<Either<Failure, UserEntity>> signInWithGoogle();
  
  /// Sign out the current user
  /// Signs out from both Firebase and Google
  Future<Either<Failure, void>> signOut();
  
  /// Send password reset email
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);
  
  /// Update user profile (display name and photo URL)
  Future<Either<Failure, void>> updateUserProfile({
    String? displayName,
    String? photoUrl,
  });
  
  /// Delete user account
  Future<Either<Failure, void>> deleteAccount();
}
