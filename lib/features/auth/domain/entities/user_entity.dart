import 'package:equatable/equatable.dart';

/// User entity representing the domain model
/// This is independent of any data source (Firebase, API, etc.)
class UserEntity extends Equatable {
  /// Unique user identifier
  final String uid;
  
  /// User's display name
  final String? displayName;
  
  /// User's email address
  final String email;
  
  /// User's profile photo URL
  final String? photoUrl;
  
  /// Whether the user's email is verified
  final bool emailVerified;
  
  /// Timestamp when the user was created
  final DateTime? createdAt;
  
  /// Timestamp when the user was last updated
  final DateTime? updatedAt;
  
  /// Authentication provider (email, google, etc.)
  final String? provider;

  const UserEntity({
    required this.uid,
    this.displayName,
    required this.email,
    this.photoUrl,
    this.emailVerified = false,
    this.createdAt,
    this.updatedAt,
    this.provider,
  });

  /// Create a copy of the user entity with updated fields
  UserEntity copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? photoUrl,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? provider,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      provider: provider ?? this.provider,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        displayName,
        email,
        photoUrl,
        emailVerified,
        createdAt,
        updatedAt,
        provider,
      ];

  @override
  String toString() {
    return 'UserEntity(uid: $uid, displayName: $displayName, email: $email, emailVerified: $emailVerified)';
  }
}
