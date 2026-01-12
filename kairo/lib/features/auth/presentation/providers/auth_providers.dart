import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:kairo/core/providers/supabase_provider.dart';
import 'package:kairo/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:kairo/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:kairo/features/auth/domain/entities/user_entity.dart';
import 'package:kairo/features/auth/domain/repositories/auth_repository.dart';

part 'auth_providers.g.dart';

/// Provides the AuthRemoteDataSource
@riverpod
AuthRemoteDataSource authRemoteDataSource(AuthRemoteDataSourceRef ref) {
  final supabase = ref.watch(supabaseProvider);
  return AuthRemoteDataSource(supabase);
}

/// Provides the AuthRepository
@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(remoteDataSource);
}

/// Provides the current authentication state
@riverpod
Stream<UserEntity?> authState(AuthStateRef ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
}

/// Provides the current user
@riverpod
Future<UserEntity?> currentUser(CurrentUserRef ref) async {
  final repository = ref.watch(authRepositoryProvider);
  return repository.getCurrentUser();
}

/// Sign up with email and password
@riverpod
class SignUp extends _$SignUp {
  @override
  FutureOr<void> build() {}

  Future<void> execute({
    required String email,
    required String password,
    required UserProfile profile,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      await repository.signUp(
        email: email,
        password: password,
        profile: profile,
      );
    });
  }
}

/// Sign in with email and password
@riverpod
class SignIn extends _$SignIn {
  @override
  FutureOr<void> build() {}

  Future<void> execute({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      await repository.signIn(
        email: email,
        password: password,
      );
    });
  }
}

/// Sign out the current user
@riverpod
class SignOut extends _$SignOut {
  @override
  FutureOr<void> build() {}

  Future<void> execute() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      await repository.signOut();
    });
  }
}

/// Sign in with Google
@riverpod
class GoogleSignIn extends _$GoogleSignIn {
  @override
  FutureOr<void> build() {}

  Future<bool> execute() async {
    state = const AsyncLoading();

    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.signInWithGoogle();

      state = const AsyncData(null);

      // Return true if user exists (logged in), false if needs registration
      return user != null;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }
}

/// Sign in with Apple
@riverpod
class AppleSignIn extends _$AppleSignIn {
  @override
  FutureOr<void> build() {}

  Future<bool> execute() async {
    state = const AsyncLoading();

    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.signInWithApple();

      state = const AsyncData(null);

      // Return true if user exists (logged in), false if needs registration
      return user != null;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }
}

/// Provides the current user profile from Supabase profiles table
@riverpod
Future<Map<String, dynamic>?> currentUserProfile(CurrentUserProfileRef ref) async {
  final supabase = ref.watch(supabaseProvider);
  final user = supabase.auth.currentUser;

  if (user == null) return null;

  try {
    final response = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();

    return response as Map<String, dynamic>;
  } catch (e) {
    // Profile might not exist yet, return default
    return {
      'id': user.id,
      'email': user.email,
      'onboarding_completed': false,
    };
  }
}
