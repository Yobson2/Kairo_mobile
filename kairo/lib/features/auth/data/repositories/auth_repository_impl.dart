import 'package:kairo/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:kairo/features/auth/data/models/user_model.dart';
import 'package:kairo/features/auth/domain/entities/user_entity.dart';
import 'package:kairo/features/auth/domain/repositories/auth_repository.dart';

/// Implementation of AuthRepository using Supabase
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<UserEntity> signUp({
    required String email,
    required String password,
    required UserProfile profile,
  }) async {
    final profileModel = UserProfileModel.fromEntity(profile);
    final userModel = await _remoteDataSource.signUp(
      email: email,
      password: password,
      profile: profileModel,
    );
    return userModel.toEntity();
  }

  @override
  Future<UserEntity> signIn({
    required String email,
    required String password,
  }) async {
    final userModel = await _remoteDataSource.signIn(
      email: email,
      password: password,
    );
    return userModel.toEntity();
  }

  @override
  Future<void> signOut() async {
    await _remoteDataSource.signOut();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final userModel = await _remoteDataSource.getCurrentUser();
    return userModel?.toEntity();
  }

  @override
  Future<UserEntity> updateProfile({
    required String userId,
    required UserProfile profile,
  }) async {
    final profileModel = UserProfileModel.fromEntity(profile);
    final userModel = await _remoteDataSource.updateProfile(
      userId: userId,
      profile: profileModel,
    );
    return userModel.toEntity();
  }

  @override
  Future<UserEntity> updatePreferences({
    required String userId,
    required UserPreferences preferences,
  }) async {
    final preferencesModel = UserPreferencesModel.fromEntity(preferences);
    final userModel = await _remoteDataSource.updatePreferences(
      userId: userId,
      preferences: preferencesModel,
    );
    return userModel.toEntity();
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _remoteDataSource.authStateChanges.map(
      (userModel) => userModel?.toEntity(),
    );
  }

  @override
  Future<void> resetPassword({required String email}) async {
    return _remoteDataSource.resetPassword(email: email);
  }

  @override
  Future<UserEntity?> signInWithGoogle() async {
    final userModel = await _remoteDataSource.signInWithGoogle();
    return userModel?.toEntity();
  }

  @override
  Future<UserEntity?> signInWithApple() async {
    final userModel = await _remoteDataSource.signInWithApple();
    return userModel?.toEntity();
  }
}
