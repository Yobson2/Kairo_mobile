// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      profile:
          UserProfileModel.fromJson(json['profile'] as Map<String, dynamic>),
      preferences: UserPreferencesModel.fromJson(
          json['preferences'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'role': instance.role,
      'profile': instance.profile,
      'preferences': instance.preferences,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

UserProfileModel _$UserProfileModelFromJson(Map<String, dynamic> json) =>
    UserProfileModel(
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      dateOfBirth: json['dateOfBirth'] == null
          ? null
          : DateTime.parse(json['dateOfBirth'] as String),
      gender: json['gender'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      avatar: json['avatar'] as String?,
    );

Map<String, dynamic> _$UserProfileModelToJson(UserProfileModel instance) =>
    <String, dynamic>{
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
      'gender': instance.gender,
      'phoneNumber': instance.phoneNumber,
      'avatar': instance.avatar,
    };

UserPreferencesModel _$UserPreferencesModelFromJson(
        Map<String, dynamic> json) =>
    UserPreferencesModel(
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      dataShareConsent: json['dataShareConsent'] as bool? ?? false,
      theme: json['theme'] as String? ?? 'system',
    );

Map<String, dynamic> _$UserPreferencesModelToJson(
        UserPreferencesModel instance) =>
    <String, dynamic>{
      'notificationsEnabled': instance.notificationsEnabled,
      'dataShareConsent': instance.dataShareConsent,
      'theme': instance.theme,
    };
