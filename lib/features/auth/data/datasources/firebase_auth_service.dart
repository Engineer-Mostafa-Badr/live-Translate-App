import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../models/user_model.dart';

/// Firebase Authentication Service
/// Handles all Firebase Auth and Firestore operations
class FirebaseAuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthService({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  /// Collection reference for users in Firestore
  CollectionReference get _usersCollection => _firestore.collection('users');

  /// Get current Firebase user
  firebase_auth.User? get currentFirebaseUser => _firebaseAuth.currentUser;

  /// Get current user as UserModel
  UserModel? get currentUser {
    final user = currentFirebaseUser;
    if (user == null) return null;
    return UserModel.fromFirebaseUser(user);
  }

  /// Stream of authentication state changes
  /// Emits UserModel when user logs in, null when user logs out
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((user) {
      if (user == null) return null;
      return UserModel.fromFirebaseUser(user);
    });
  }

  /// Sign up with email and password
  /// Creates user in Firebase Auth and stores data in Firestore
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      Logger.log('Signing up user with email: $email', tag: 'AUTH_SERVICE');

      // Create user in Firebase Auth
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthException('User creation failed');
      }

      // Update display name
      await user.updateDisplayName(displayName);
      await user.reload();
      
      // Get updated user
      final updatedUser = _firebaseAuth.currentUser;
      if (updatedUser == null) {
        throw const AuthException('Failed to get updated user');
      }

      // Create user model
      final userModel = UserModel.fromFirebaseUser(updatedUser);

      // Save user data to Firestore
      await _saveUserToFirestore(userModel);

      Logger.success('User signed up successfully: ${user.uid}', tag: 'AUTH_SERVICE');
      return userModel;
    } on firebase_auth.FirebaseAuthException catch (e) {
      Logger.error('Firebase Auth error: ${e.code} - ${e.message}', tag: 'AUTH_SERVICE');
      throw AuthException(_getAuthErrorMessage(e.code), e.code);
    } catch (e) {
      Logger.error('Sign up error: $e', tag: 'AUTH_SERVICE');
      throw AuthException('Failed to sign up: $e');
    }
  }

  /// Sign in with email and password
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      Logger.log('Signing in user with email: $email', tag: 'AUTH_SERVICE');

      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthException('Sign in failed');
      }

      final userModel = UserModel.fromFirebaseUser(user);

      // Update user data in Firestore
      await _saveUserToFirestore(userModel);

      Logger.success('User signed in successfully: ${user.uid}', tag: 'AUTH_SERVICE');
      return userModel;
    } on firebase_auth.FirebaseAuthException catch (e) {
      Logger.error('Firebase Auth error: ${e.code} - ${e.message}', tag: 'AUTH_SERVICE');
      throw AuthException(_getAuthErrorMessage(e.code), e.code);
    } catch (e) {
      Logger.error('Sign in error: $e', tag: 'AUTH_SERVICE');
      throw AuthException('Failed to sign in: $e');
    }
  }

  /// Sign in with Google
  Future<UserModel> signInWithGoogle() async {
    try {
      Logger.log('Signing in with Google', tag: 'AUTH_SERVICE');

      // Trigger the Google Sign In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw const AuthException('Google sign in was cancelled');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _firebaseAuth.signInWithCredential(credential);

      final user = userCredential.user;
      if (user == null) {
        throw const AuthException('Google sign in failed');
      }

      final userModel = UserModel.fromFirebaseUser(user);

      // Save user data to Firestore
      await _saveUserToFirestore(userModel);

      Logger.success('User signed in with Google: ${user.uid}', tag: 'AUTH_SERVICE');
      return userModel;
    } on firebase_auth.FirebaseAuthException catch (e) {
      Logger.error('Firebase Auth error: ${e.code} - ${e.message}', tag: 'AUTH_SERVICE');
      throw AuthException(_getAuthErrorMessage(e.code), e.code);
    } catch (e) {
      Logger.error('Google sign in error: $e', tag: 'AUTH_SERVICE');
      throw AuthException('Failed to sign in with Google: $e');
    }
  }

  /// Sign out from Firebase and Google
  Future<void> signOut() async {
    try {
      Logger.log('Signing out user', tag: 'AUTH_SERVICE');

      // Sign out from Google if signed in
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      // Sign out from Firebase
      await _firebaseAuth.signOut();

      Logger.success('User signed out successfully', tag: 'AUTH_SERVICE');
    } catch (e) {
      Logger.error('Sign out error: $e', tag: 'AUTH_SERVICE');
      throw AuthException('Failed to sign out: $e');
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      Logger.log('Sending password reset email to: $email', tag: 'AUTH_SERVICE');

      await _firebaseAuth.sendPasswordResetEmail(email: email);

      Logger.success('Password reset email sent', tag: 'AUTH_SERVICE');
    } on firebase_auth.FirebaseAuthException catch (e) {
      Logger.error('Firebase Auth error: ${e.code} - ${e.message}', tag: 'AUTH_SERVICE');
      throw AuthException(_getAuthErrorMessage(e.code), e.code);
    } catch (e) {
      Logger.error('Password reset error: $e', tag: 'AUTH_SERVICE');
      throw AuthException('Failed to send password reset email: $e');
    }
  }

  /// Update user profile (display name and photo URL)
  Future<void> updateUserProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final user = currentFirebaseUser;
      if (user == null) {
        throw const AuthException('No user is currently signed in');
      }

      Logger.log('Updating user profile: ${user.uid}', tag: 'AUTH_SERVICE');

      // Update Firebase Auth profile
      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }
      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }

      await user.reload();

      // Update Firestore document
      final updatedUser = _firebaseAuth.currentUser;
      if (updatedUser != null) {
        final userModel = UserModel.fromFirebaseUser(updatedUser);
        await _saveUserToFirestore(userModel);
      }

      Logger.success('User profile updated', tag: 'AUTH_SERVICE');
    } on firebase_auth.FirebaseAuthException catch (e) {
      Logger.error('Firebase Auth error: ${e.code} - ${e.message}', tag: 'AUTH_SERVICE');
      throw AuthException(_getAuthErrorMessage(e.code), e.code);
    } catch (e) {
      Logger.error('Update profile error: $e', tag: 'AUTH_SERVICE');
      throw AuthException('Failed to update profile: $e');
    }
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    try {
      final user = currentFirebaseUser;
      if (user == null) {
        throw const AuthException('No user is currently signed in');
      }

      Logger.log('Deleting user account: ${user.uid}', tag: 'AUTH_SERVICE');

      // Delete Firestore document
      await _usersCollection.doc(user.uid).delete();

      // Delete Firebase Auth account
      await user.delete();

      Logger.success('User account deleted', tag: 'AUTH_SERVICE');
    } on firebase_auth.FirebaseAuthException catch (e) {
      Logger.error('Firebase Auth error: ${e.code} - ${e.message}', tag: 'AUTH_SERVICE');
      throw AuthException(_getAuthErrorMessage(e.code), e.code);
    } catch (e) {
      Logger.error('Delete account error: $e', tag: 'AUTH_SERVICE');
      throw AuthException('Failed to delete account: $e');
    }
  }

  /// Get user from Firestore
  Future<UserModel?> getUserFromFirestore(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } catch (e) {
      Logger.error('Get user from Firestore error: $e', tag: 'AUTH_SERVICE');
      throw CacheException('Failed to get user from Firestore: $e');
    }
  }

  /// Save user data to Firestore
  Future<void> _saveUserToFirestore(UserModel user) async {
    try {
      await _usersCollection.doc(user.uid).set(
            user.toFirestore(),
            SetOptions(merge: true),
          );
      Logger.log('User data saved to Firestore: ${user.uid}', tag: 'AUTH_SERVICE');
    } catch (e) {
      Logger.error('Save to Firestore error: $e', tag: 'AUTH_SERVICE');
      throw CacheException('Failed to save user to Firestore: $e');
    }
  }

  /// Get user-friendly error message from Firebase Auth error code
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'The password is too weak';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'invalid-email':
        return 'The email address is invalid';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-credential':
        return 'Invalid email or password';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      case 'requires-recent-login':
        return 'Please sign in again to perform this action';
      default:
        return 'Authentication failed. Please try again';
    }
  }
}
