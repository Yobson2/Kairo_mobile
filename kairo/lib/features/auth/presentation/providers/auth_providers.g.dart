// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authRemoteDataSourceHash() =>
    r'e2df59d3bc83dcb7877e873d1fc916f7155958ed';

/// Provides the AuthRemoteDataSource
///
/// Copied from [authRemoteDataSource].
@ProviderFor(authRemoteDataSource)
final authRemoteDataSourceProvider =
    AutoDisposeProvider<AuthRemoteDataSource>.internal(
  authRemoteDataSource,
  name: r'authRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthRemoteDataSourceRef = AutoDisposeProviderRef<AuthRemoteDataSource>;
String _$authRepositoryHash() => r'47e7f13a70a820843ed4242556697cb91432c454';

/// Provides the AuthRepository
///
/// Copied from [authRepository].
@ProviderFor(authRepository)
final authRepositoryProvider = AutoDisposeProvider<AuthRepository>.internal(
  authRepository,
  name: r'authRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthRepositoryRef = AutoDisposeProviderRef<AuthRepository>;
String _$authStateHash() => r'51eddfb9d96e2e367d2d414b2778a5c3cffdf373';

/// Provides the current authentication state
///
/// Copied from [authState].
@ProviderFor(authState)
final authStateProvider = AutoDisposeStreamProvider<UserEntity?>.internal(
  authState,
  name: r'authStateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthStateRef = AutoDisposeStreamProviderRef<UserEntity?>;
String _$currentUserHash() => r'fe2f5c691e18c68dceae4f518ad1b0279c67bfa7';

/// Provides the current user
///
/// Copied from [currentUser].
@ProviderFor(currentUser)
final currentUserProvider = AutoDisposeFutureProvider<UserEntity?>.internal(
  currentUser,
  name: r'currentUserProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$currentUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentUserRef = AutoDisposeFutureProviderRef<UserEntity?>;
String _$currentUserProfileHash() =>
    r'4ec2ac512233105320cda14fdf7ead2fed77498d';

/// Provides the current user profile from Supabase profiles table
///
/// Copied from [currentUserProfile].
@ProviderFor(currentUserProfile)
final currentUserProfileProvider =
    AutoDisposeFutureProvider<Map<String, dynamic>?>.internal(
  currentUserProfile,
  name: r'currentUserProfileProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentUserProfileHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentUserProfileRef
    = AutoDisposeFutureProviderRef<Map<String, dynamic>?>;
String _$signUpHash() => r'2a5848d1f6f8fd663a9ff8109f7dc5c429a4c9a2';

/// Sign up with email and password
///
/// Copied from [SignUp].
@ProviderFor(SignUp)
final signUpProvider = AutoDisposeAsyncNotifierProvider<SignUp, void>.internal(
  SignUp.new,
  name: r'signUpProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$signUpHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SignUp = AutoDisposeAsyncNotifier<void>;
String _$signInHash() => r'feb352dd8a2aefe8fc598463c8be3224e4fd30df';

/// Sign in with email and password
///
/// Copied from [SignIn].
@ProviderFor(SignIn)
final signInProvider = AutoDisposeAsyncNotifierProvider<SignIn, void>.internal(
  SignIn.new,
  name: r'signInProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$signInHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SignIn = AutoDisposeAsyncNotifier<void>;
String _$signOutHash() => r'3c4dab9bd96e61df6ae341cdf0f221b447806060';

/// Sign out the current user
///
/// Copied from [SignOut].
@ProviderFor(SignOut)
final signOutProvider =
    AutoDisposeAsyncNotifierProvider<SignOut, void>.internal(
  SignOut.new,
  name: r'signOutProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$signOutHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SignOut = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
