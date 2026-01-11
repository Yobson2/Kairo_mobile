// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'allocation_strategy_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AllocationStrategyModel _$AllocationStrategyModelFromJson(
        Map<String, dynamic> json) =>
    AllocationStrategyModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      isActive: json['is_active'] as bool,
      isTemplate: json['is_template'] as bool,
      allocations: (json['allocations'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$AllocationStrategyModelToJson(
        AllocationStrategyModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'name': instance.name,
      'is_active': instance.isActive,
      'is_template': instance.isTemplate,
      'allocations': instance.allocations,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
