import 'package:json_annotation/json_annotation.dart';
import 'package:kairo/features/auth/domain/entities/user_entity.dart';

part 'user_model.g.dart';

/// Data model for User with JSON serialization
@JsonSerializable()
class UserModel {
  final String id;
  final String email;
  final String role;
  final UserProfileModel profile;
  final UserPreferencesModel preferences;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.role,
    required this.profile,
    required this.preferences,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  /// Convert to domain entity
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      role: role,
      profile: profile.toEntity(),
      preferences: preferences.toEntity(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create from domain entity
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      role: entity.role,
      profile: UserProfileModel.fromEntity(entity.profile),
      preferences: UserPreferencesModel.fromEntity(entity.preferences),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

@JsonSerializable()
class UserProfileModel {
  @JsonKey(name: 'firstName')
  final String? firstName;
  @JsonKey(name: 'lastName')
  final String? lastName;
  @JsonKey(name: 'dateOfBirth')
  final DateTime? dateOfBirth;
  final String? gender;
  @JsonKey(name: 'phoneNumber')
  final String? phoneNumber;
  final String? avatar;

  const UserProfileModel({
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.gender,
    this.phoneNumber,
    this.avatar,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) => _$UserProfileModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserProfileModelToJson(this);

  UserProfile toEntity() {
    return UserProfile(
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: dateOfBirth,
      gender: gender,
      phoneNumber: phoneNumber,
      avatar: avatar,
    );
  }

  factory UserProfileModel.fromEntity(UserProfile entity) {
    return UserProfileModel(
      firstName: entity.firstName,
      lastName: entity.lastName,
      dateOfBirth: entity.dateOfBirth,
      gender: entity.gender,
      phoneNumber: entity.phoneNumber,
      avatar: entity.avatar,
    );
  }
}

@JsonSerializable()
class UserPreferencesModel {
  final bool notificationsEnabled;
  final bool dataShareConsent;
  final String theme;

  const UserPreferencesModel({
    this.notificationsEnabled = true,
    this.dataShareConsent = false,
    this.theme = 'system',
  });

  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) => _$UserPreferencesModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserPreferencesModelToJson(this);

  UserPreferences toEntity() {
    return UserPreferences(
      notificationsEnabled: notificationsEnabled,
      dataShareConsent: dataShareConsent,
      theme: theme,
    );
  }

  factory UserPreferencesModel.fromEntity(UserPreferences entity) {
    return UserPreferencesModel(
      notificationsEnabled: entity.notificationsEnabled,
      dataShareConsent: entity.dataShareConsent,
      theme: entity.theme,
    );
  }
}
