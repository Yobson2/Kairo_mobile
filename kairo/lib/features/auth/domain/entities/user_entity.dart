import 'package:equatable/equatable.dart';

/// User entity representing the authenticated user
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String role;
  final UserProfile profile;
  final UserPreferences preferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.role,
    required this.profile,
    required this.preferences,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, email, role, profile, preferences, createdAt, updatedAt];
}

/// User profile information
class UserProfile extends Equatable {
  final String? firstName;
  final String? lastName;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? phoneNumber;
  final String? avatar;

  const UserProfile({
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.gender,
    this.phoneNumber,
    this.avatar,
  });

  @override
  List<Object?> get props => [firstName, lastName, dateOfBirth, gender, phoneNumber, avatar];
}

/// User preferences
class UserPreferences extends Equatable {
  final bool notificationsEnabled;
  final bool dataShareConsent;
  final String theme;

  const UserPreferences({
    this.notificationsEnabled = true,
    this.dataShareConsent = false,
    this.theme = 'system',
  });

  @override
  List<Object?> get props => [notificationsEnabled, dataShareConsent, theme];
}
