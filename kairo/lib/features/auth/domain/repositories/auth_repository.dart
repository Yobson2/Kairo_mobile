import 'package:kairo/features/auth/domain/entities/user_entity.dart';

/// Authentication repository interface
/// Defines contracts for authentication operations
abstract class AuthRepository {
  /// Sign up with email and password
  /// Returns the created user entity
  Future<UserEntity> signUp({
    required String email,
    required String password,
    required UserProfile profile,
  });

  /// Sign in with email and password
  /// Returns the authenticated user entity
  Future<UserEntity> signIn({
    required String email,
    required String password,
  });

  /// Sign out the current user
  Future<void> signOut();

  /// Get the current authenticated user
  /// Returns null if not authenticated
  Future<UserEntity?> getCurrentUser();

  /// Update user profile
  Future<UserEntity> updateProfile({
    required String userId,
    required UserProfile profile,
  });

  /// Update user preferences
  Future<UserEntity> updatePreferences({
    required String userId,
    required UserPreferences preferences,
  });

  /// Send password reset email
  /// User will receive an email with a reset link valid for 1 hour
  Future<void> resetPassword({
    required String email,
  });

  /// Sign in with Google
  /// Returns existing user if email exists, null if new user needs to register
  Future<UserEntity?> signInWithGoogle();

  /// Sign in with Apple
  /// Returns existing user if email exists, null if new user needs to register
  Future<UserEntity?> signInWithApple();

  /// Stream of authentication state changes
  Stream<UserEntity?> get authStateChanges;
}
