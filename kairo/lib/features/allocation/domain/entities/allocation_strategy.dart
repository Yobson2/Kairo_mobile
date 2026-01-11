import 'package:equatable/equatable.dart';

/// Individual allocation within a strategy
class CategoryAllocation extends Equatable {
  final String categoryId;
  final double percentage;

  const CategoryAllocation({
    required this.categoryId,
    required this.percentage,
  });

  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'percentage': percentage,
    };
  }

  factory CategoryAllocation.fromJson(Map<String, dynamic> json) {
    return CategoryAllocation(
      categoryId: json['category_id'] as String,
      percentage: (json['percentage'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [categoryId, percentage];
}

/// Allocation strategy defining percentage splits across categories
class AllocationStrategy extends Equatable {
  final String id;
  final String userId;
  final String name;
  final bool isActive;
  final bool isTemplate;
  final List<CategoryAllocation> allocations;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AllocationStrategy({
    required this.id,
    required this.userId,
    required this.name,
    required this.isActive,
    required this.isTemplate,
    required this.allocations,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Calculate total percentage allocated
  double get totalPercentage {
    return allocations.fold(0.0, (sum, alloc) => sum + alloc.percentage);
  }

  /// Check if strategy is valid (total = 100%)
  bool get isValid {
    return (totalPercentage - 100.0).abs() < 0.01; // Allow small floating point error
  }

  /// Get allocation percentage for a specific category
  double getPercentageForCategory(String categoryId) {
    try {
      return allocations
          .firstWhere((alloc) => alloc.categoryId == categoryId)
          .percentage;
    } catch (e) {
      return 0.0;
    }
  }

  AllocationStrategy copyWith({
    String? id,
    String? userId,
    String? name,
    bool? isActive,
    bool? isTemplate,
    List<CategoryAllocation>? allocations,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AllocationStrategy(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      isTemplate: isTemplate ?? this.isTemplate,
      allocations: allocations ?? this.allocations,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        isActive,
        isTemplate,
        allocations,
        createdAt,
        updatedAt,
      ];
}
