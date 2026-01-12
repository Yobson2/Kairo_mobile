import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
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
  /// Returns user only if they exist in BOTH Supabase auth AND database
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      // Check if user exists in database (not just Supabase auth)
      final userData = await _supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (userData != null) {
        return UserModel.fromJson(userData);
      }

      // User authenticated but NOT in database
      return null;
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

  /// Sign in with Google
  /// Returns existing user if email exists, null if new user needs to register
  Future<UserModel?> signInWithGoogle() async {
    try {
      // For Supabase, we need the Web Client ID as serverClientId on Android
      // On iOS, the client ID comes from Info.plist
      final String? webClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID'];

      if (webClientId == null || webClientId.contains('YOUR_')) {
        throw Exception(
            'Google Sign-In not configured. Please set GOOGLE_WEB_CLIENT_ID in .env file. '
            'See docs/GOOGLE_OAUTH_SETUP.md for setup instructions.');
      }

      final GoogleSignIn googleSignIn = GoogleSignIn(
        // Android needs web client ID for Supabase token exchange
        // iOS uses GIDClientID from Info.plist
        serverClientId: Platform.isAndroid ? webClientId : null,
        scopes: ['email', 'profile'],
      );

      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google sign-in was cancelled');
      }

      // Obtain the auth details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      if (idToken == null) {
        throw Exception('No ID token received from Google');
      }

      // Sign in to Supabase with Google credentials
      final authResponse = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (authResponse.user == null) {
        throw Exception('Google sign-in failed: No user returned');
      }

      // Check if user exists in database
      final userData = await _supabase
          .from('users')
          .select()
          .eq('id', authResponse.user!.id)
          .maybeSingle();

      // If user exists, return user data
      if (userData != null) {
        return UserModel.fromJson(userData);
      }

      // New user - return null to indicate registration needed
      return null;
    } on AuthException catch (e) {
      throw Exception('Google authentication error: ${e.message}');
    } catch (e) {
      throw Exception('Google sign-in failed: $e');
    }
  }

  /// Sign in with Apple
  /// Returns existing user if email exists, null if new user needs to register
  Future<UserModel?> signInWithApple() async {
    try {
      // Generate a random nonce for security
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      // Request Apple Sign-In credentials
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final String? idToken = credential.identityToken;
      if (idToken == null) {
        throw Exception('No ID token received from Apple');
      }

      // Sign in to Supabase with Apple credentials
      final authResponse = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );

      if (authResponse.user == null) {
        throw Exception('Apple sign-in failed: No user returned');
      }

      // Check if user exists in database
      final userData = await _supabase
          .from('users')
          .select()
          .eq('id', authResponse.user!.id)
          .maybeSingle();

      // If user exists, return user data
      if (userData != null) {
        return UserModel.fromJson(userData);
      }

      // New user - return null to indicate registration needed
      return null;
    } on AuthException catch (e) {
      throw Exception('Apple authentication error: ${e.message}');
    } catch (e) {
      throw Exception('Apple sign-in failed: $e');
    }
  }

  /// Generate a cryptographically secure random nonce
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Stream of authentication state changes
  /// IMPORTANT: Only returns a user if they exist in BOTH Supabase auth AND database
  /// This prevents new OAuth users from being auto-redirected to dashboard
  Stream<UserModel?> get authStateChanges async* {
    // Immediately emit the current session state to avoid blocking on splash screen
    final currentUser = _supabase.auth.currentUser;
    if (currentUser != null) {
      // Check if user exists in database (not just Supabase auth)
      try {
        final userData = await _supabase
            .from('users')
            .select()
            .eq('id', currentUser.id)
            .maybeSingle();

        if (userData != null) {
          // User exists in database - emit user data
          yield UserModel.fromJson(userData);
        } else {
          // User authenticated but NOT in database - emit null
          yield null;
        }
      } catch (e) {
        // Database query failed - emit null to be safe
        yield null;
      }
    } else {
      yield null;
    }

    // Then listen to auth state changes
    await for (final data in _supabase.auth.onAuthStateChange) {
      final user = data.session?.user;
      if (user == null) {
        yield null;
      } else {
        // Check if user exists in database (not just Supabase auth)
        try {
          final userData = await _supabase
              .from('users')
              .select()
              .eq('id', user.id)
              .maybeSingle();

          if (userData != null) {
            // User exists in database - emit user data
            yield UserModel.fromJson(userData);
          } else {
            // User authenticated but NOT in database - emit null
            yield null;
          }
        } catch (e) {
          // Database query failed - emit null to be safe
          yield null;
        }
      }
    }
  }
}
