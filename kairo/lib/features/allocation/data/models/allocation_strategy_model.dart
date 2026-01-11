import 'package:json_annotation/json_annotation.dart';
import 'package:kairo/features/allocation/domain/entities/allocation_strategy.dart';

part 'allocation_strategy_model.g.dart';

/// Data model for AllocationStrategy with JSON serialization
@JsonSerializable()
class AllocationStrategyModel {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  final String name;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'is_template')
  final bool isTemplate;
  final List<Map<String, dynamic>> allocations;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const AllocationStrategyModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.isActive,
    required this.isTemplate,
    required this.allocations,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AllocationStrategyModel.fromJson(Map<String, dynamic> json) =>
      _$AllocationStrategyModelFromJson(json);

  Map<String, dynamic> toJson() => _$AllocationStrategyModelToJson(this);

  /// Convert to domain entity
  AllocationStrategy toEntity() {
    final categoryAllocations = allocations
        .map((alloc) => CategoryAllocation.fromJson(alloc))
        .toList();

    return AllocationStrategy(
      id: id,
      userId: userId,
      name: name,
      isActive: isActive,
      isTemplate: isTemplate,
      allocations: categoryAllocations,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create from domain entity
  factory AllocationStrategyModel.fromEntity(AllocationStrategy entity) {
    final allocationsJson = entity.allocations
        .map((alloc) => alloc.toJson())
        .toList();

    return AllocationStrategyModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      isActive: entity.isActive,
      isTemplate: entity.isTemplate,
      allocations: allocationsJson,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
