import 'package:equatable/equatable.dart';

/// Allocation category entity representing where money should go
class AllocationCategory extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String color; // Hex color code
  final String? icon;
  final bool isDefault;
  final int displayOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AllocationCategory({
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

  AllocationCategory copyWith({
    String? id,
    String? userId,
    String? name,
    String? color,
    String? icon,
    bool? isDefault,
    int? displayOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AllocationCategory(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isDefault: isDefault ?? this.isDefault,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        color,
        icon,
        isDefault,
        displayOrder,
        createdAt,
        updatedAt,
      ];
}
