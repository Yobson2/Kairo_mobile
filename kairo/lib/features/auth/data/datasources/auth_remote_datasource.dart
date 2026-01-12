import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kairo/features/auth/data/models/user_model.dart';

/// Remote data source for authentication operations using Supabase
class AuthRemoteDataSource {
  final SupabaseClient _supabase;

  AuthRemoteDataSource(this._supabase);

  /// Sign up with email and password
  Future<UserModel> signUp({
    required String email,
    required String password,
    required UserProfileModel profile,
  }) async {
    try {
      // Sign up with Supabase Auth
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'role': 'user',
          'profile': profile.toJson(),
        },
      );

      if (authResponse.user == null) {
        throw Exception('Sign up failed: No user returned');
      }

      // Fetch the created user profile from public.users table
      final userData = await _supabase
          .from('users')
          .select()
          .eq('id', authResponse.user!.id)
          .single();

      return UserModel.fromJson(userData);
    } on AuthException catch (e) {
      throw Exception('Authentication error: ${e.message}');
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  /// Sign in with email and password
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final authResponse = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('Sign in failed: No user returned');
      }

      // Fetch user profile
      final userData = await _supabase
          .from('users')
          .select()
          .eq('id', authResponse.user!.id)
          .single();

      return UserModel.fromJson(userData);
    } on AuthException catch (e) {
      throw Exception('Authentication error: ${e.message}');
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  /// Get the current authenticated user
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final userData = await _supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .single();

      return UserModel.fromJson(userData);
    } catch (e) {
      return null;
    }
  }

  /// Update user profile
  Future<UserModel> updateProfile({
    required String userId,
    required UserProfileModel profile,
  }) async {
    try {
      final response = await _supabase
          .from('users')
          .update({'profile': profile.toJson()})
          .eq('id', userId)
          .select()
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Update profile failed: $e');
    }
  }

  /// Update user preferences
  Future<UserModel> updatePreferences({
    required String userId,
    required UserPreferencesModel preferences,
  }) async {
    try {
      final response = await _supabase
          .from('users')
          .update({'preferences': preferences.toJson()})
          .eq('id', userId)
          .select()
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Update preferences failed: $e');
    }
  }

  /// Send password reset email
  Future<void> resetPassword({required String email}) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  /// Stream of authentication state changes
  Stream<UserModel?> get authStateChanges async* {
    // Immediately emit the current session state to avoid blocking on splash screen
    final currentUser = _supabase.auth.currentUser;
    if (currentUser != null) {
      yield UserModel(
        id: currentUser.id,
        email: currentUser.email ?? '',
        role: 'user',
        profile: const UserProfileModel(),
        preferences: const UserPreferencesModel(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } else {
      yield null;
    }

    // Then listen to auth state changes
    await for (final data in _supabase.auth.onAuthStateChange) {
      final user = data.session?.user;
      if (user == null) {
        yield null;
      } else {
        yield UserModel(
          id: user.id,
          email: user.email ?? '',
          role: 'user',
          profile: const UserProfileModel(),
          preferences: const UserPreferencesModel(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
    }
  }
}
