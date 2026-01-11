// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'allocation_category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AllocationCategoryModel _$AllocationCategoryModelFromJson(
        Map<String, dynamic> json) =>
    AllocationCategoryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      color: json['color'] as String,
      icon: json['icon'] as String?,
      isDefault: json['is_default'] as bool,
      displayOrder: (json['display_order'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$AllocationCategoryModelToJson(
        AllocationCategoryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'name': instance.name,
      'color': instance.color,
      'icon': instance.icon,
      'is_default': instance.isDefault,
      'display_order': instance.displayOrder,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
