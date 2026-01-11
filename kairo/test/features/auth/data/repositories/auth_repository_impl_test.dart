import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kairo/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:kairo/features/auth/data/models/user_model.dart';
import 'package:kairo/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:kairo/features/auth/domain/entities/user_entity.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(mockRemoteDataSource);
  });

  setUpAll(() {
    registerFallbackValue(const UserProfileModel());
    registerFallbackValue(const UserPreferencesModel());
  });

  group('AuthRepositoryImpl', () {
    const testEmail = 'test@example.com';
    const testPassword = 'password123';
    const testUserId = 'user-id-123';

    final testUserModel = UserModel(
      id: testUserId,
      email: testEmail,
      role: 'user',
      profile: const UserProfileModel(
        firstName: 'John',
        lastName: 'Doe',
      ),
      preferences: const UserPreferencesModel(),
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    const testProfile = UserProfile(
      firstName: 'John',
      lastName: 'Doe',
    );

    group('signUp', () {
      test('should return UserEntity when sign up is successful', () async {
        // Arrange
        when(() => mockRemoteDataSource.signUp(
              email: any(named: 'email'),
              password: any(named: 'password'),
              profile: any(named: 'profile'),
            )).thenAnswer((_) async => testUserModel);

        // Act
        final result = await repository.signUp(
          email: testEmail,
          password: testPassword,
          profile: testProfile,
        );

        // Assert
        expect(result, isA<UserEntity>());
        expect(result.id, testUserId);
        expect(result.email, testEmail);
        verify(() => mockRemoteDataSource.signUp(
              email: testEmail,
              password: testPassword,
              profile: any(named: 'profile'),
            )).called(1);
      });

      test('should throw exception when sign up fails', () async {
        // Arrange
        when(() => mockRemoteDataSource.signUp(
              email: any(named: 'email'),
              password: any(named: 'password'),
              profile: any(named: 'profile'),
            )).thenThrow(Exception('Sign up failed'));

        // Act & Assert
        expect(
          () => repository.signUp(
            email: testEmail,
            password: testPassword,
            profile: testProfile,
          ),
          throwsException,
        );
      });
    });

    group('signIn', () {
      test('should return UserEntity when sign in is successful', () async {
        // Arrange
        when(() => mockRemoteDataSource.signIn(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => testUserModel);

        // Act
        final result = await repository.signIn(
          email: testEmail,
          password: testPassword,
        );

        // Assert
        expect(result, isA<UserEntity>());
        expect(result.id, testUserId);
        expect(result.email, testEmail);
        verify(() => mockRemoteDataSource.signIn(
              email: testEmail,
              password: testPassword,
            )).called(1);
      });

      test('should throw exception when sign in fails', () async {
        // Arrange
        when(() => mockRemoteDataSource.signIn(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenThrow(Exception('Sign in failed'));

        // Act & Assert
        expect(
          () => repository.signIn(
            email: testEmail,
            password: testPassword,
          ),
          throwsException,
        );
      });
    });

    group('signOut', () {
      test('should call remote data source signOut', () async {
        // Arrange
        when(() => mockRemoteDataSource.signOut())
            .thenAnswer((_) async => {});

        // Act
        await repository.signOut();

        // Assert
        verify(() => mockRemoteDataSource.signOut()).called(1);
      });

      test('should throw exception when sign out fails', () async {
        // Arrange
        when(() => mockRemoteDataSource.signOut())
            .thenThrow(Exception('Sign out failed'));

        // Act & Assert
        expect(() => repository.signOut(), throwsException);
      });
    });

    group('getCurrentUser', () {
      test('should return UserEntity when user is authenticated', () async {
        // Arrange
        when(() => mockRemoteDataSource.getCurrentUser())
            .thenAnswer((_) async => testUserModel);

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result, isA<UserEntity>());
        expect(result?.id, testUserId);
        verify(() => mockRemoteDataSource.getCurrentUser()).called(1);
      });

      test('should return null when no user is authenticated', () async {
        // Arrange
        when(() => mockRemoteDataSource.getCurrentUser())
            .thenAnswer((_) async => null);

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result, isNull);
        verify(() => mockRemoteDataSource.getCurrentUser()).called(1);
      });
    });

    group('updateProfile', () {
      const updatedProfile = UserProfile(
        firstName: 'Jane',
        lastName: 'Smith',
      );

      final updatedUserModel = UserModel(
        id: testUserId,
        email: testEmail,
        role: 'user',
        profile: const UserProfileModel(
          firstName: 'Jane',
          lastName: 'Smith',
        ),
        preferences: const UserPreferencesModel(),
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
      );

      test('should return updated UserEntity when update is successful',
          () async {
        // Arrange
        when(() => mockRemoteDataSource.updateProfile(
              userId: any(named: 'userId'),
              profile: any(named: 'profile'),
            )).thenAnswer((_) async => updatedUserModel);

        // Act
        final result = await repository.updateProfile(
          userId: testUserId,
          profile: updatedProfile,
        );

        // Assert
        expect(result, isA<UserEntity>());
        expect(result.profile.firstName, 'Jane');
        verify(() => mockRemoteDataSource.updateProfile(
              userId: testUserId,
              profile: any(named: 'profile'),
            )).called(1);
      });
    });

    group('updatePreferences', () {
      const updatedPreferences = UserPreferences(
        notificationsEnabled: false,
        dataShareConsent: true,
        theme: 'dark',
      );

      final updatedUserModel = UserModel(
        id: testUserId,
        email: testEmail,
        role: 'user',
        profile: const UserProfileModel(
          firstName: 'John',
          lastName: 'Doe',
        ),
        preferences: const UserPreferencesModel(
          notificationsEnabled: false,
          dataShareConsent: true,
          theme: 'dark',
        ),
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
      );

      test('should return updated UserEntity when update is successful',
          () async {
        // Arrange
        when(() => mockRemoteDataSource.updatePreferences(
              userId: any(named: 'userId'),
              preferences: any(named: 'preferences'),
            )).thenAnswer((_) async => updatedUserModel);

        // Act
        final result = await repository.updatePreferences(
          userId: testUserId,
          preferences: updatedPreferences,
        );

        // Assert
        expect(result, isA<UserEntity>());
        expect(result.preferences.notificationsEnabled, false);
        expect(result.preferences.theme, 'dark');
        verify(() => mockRemoteDataSource.updatePreferences(
              userId: testUserId,
              preferences: any(named: 'preferences'),
            )).called(1);
      });
    });
  });
}
