import 'package:json_annotation/json_annotation.dart';
import 'package:kairo/features/allocation/domain/entities/income_entry.dart';

part 'income_entry_model.g.dart';

/// Data model for IncomeEntry with JSON serialization
/// Aligned with database schema and PRD requirements
@JsonSerializable()
class IncomeEntryModel {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  final double amount;
  final String currency; // KES, NGN, GHS, ZAR, USD, EUR
  @JsonKey(name: 'income_date')
  final DateTime incomeDate;
  @JsonKey(name: 'income_type')
  final String incomeType; // fixed, variable, mixed
  @JsonKey(name: 'income_source')
  final String? incomeSource; // cash, mobileMoney, formalSalary, gigIncome, other
  final String? description;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const IncomeEntryModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.currency,
    required this.incomeDate,
    required this.incomeType,
    this.incomeSource,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory IncomeEntryModel.fromJson(Map<String, dynamic> json) =>
      _$IncomeEntryModelFromJson(json);

  Map<String, dynamic> toJson() => _$IncomeEntryModelToJson(this);

  /// Convert to domain entity
  IncomeEntry toEntity() {
    return IncomeEntry(
      id: id,
      userId: userId,
      amount: amount,
      currency: currency,
      incomeDate: incomeDate,
      incomeType: IncomeType.fromString(incomeType),
      incomeSource: incomeSource != null
          ? IncomeSource.fromString(incomeSource!)
          : null,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create from domain entity
  factory IncomeEntryModel.fromEntity(IncomeEntry entity) {
    return IncomeEntryModel(
      id: entity.id,
      userId: entity.userId,
      amount: entity.amount,
      currency: entity.currency,
      incomeDate: entity.incomeDate,
      incomeType: entity.incomeType.value,
      incomeSource: entity.incomeSource?.value,
      description: entity.description,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
