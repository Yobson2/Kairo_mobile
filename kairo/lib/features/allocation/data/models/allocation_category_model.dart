import 'package:json_annotation/json_annotation.dart';
import 'package:kairo/features/allocation/domain/entities/allocation_category.dart';

part 'allocation_category_model.g.dart';

/// Data model for AllocationCategory with JSON serialization
@JsonSerializable()
class AllocationCategoryModel {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  final String name;
  final String color;
  final String? icon;
  @JsonKey(name: 'is_default')
  final bool isDefault;
  @JsonKey(name: 'display_order')
  final int displayOrder;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const AllocationCategoryModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.color,
    this.icon,
    required this.isDefault,
    required this.displayOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AllocationCategoryModel.fromJson(Map<String, dynamic> json) =>
      _$AllocationCategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$AllocationCategoryModelToJson(this);

  /// Convert to domain entity
  AllocationCategory toEntity() {
    return AllocationCategory(
      id: id,
      userId: userId,
      name: name,
      color: color,
      icon: icon,
      isDefault: isDefault,
      displayOrder: displayOrder,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create from domain entity
  factory AllocationCategoryModel.fromEntity(AllocationCategory entity) {
    return AllocationCategoryModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      color: entity.color,
      icon: entity.icon,
      isDefault: entity.isDefault,
      displayOrder: entity.displayOrder,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
