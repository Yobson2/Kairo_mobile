import 'package:equatable/equatable.dart';

/// Income type enumeration
enum IncomeType {
  fixed,
  variable,
  mixed;

  String get value => name;

  static IncomeType fromString(String value) {
    return IncomeType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => IncomeType.variable,
    );
  }
}

/// Income source enumeration (FR13)
/// Aligns with PRD Story 2.3: Income Entry Screen
enum IncomeSource {
  cash('Cash', 'Physical cash in hand'),
  mobileMoney('Mobile Money', 'M-Pesa, MTN Money, Airtel Money, etc.'),
  formalSalary('Formal Salary', 'Regular employment salary'),
  gigIncome('Gig Income', 'Freelance, gig work, or project-based income'),
  other('Other', 'Other income sources');

  final String label;
  final String description;

  const IncomeSource(this.label, this.description);

  String get value => name;

  static IncomeSource fromString(String value) {
    return IncomeSource.values.firstWhere(
      (source) => source.name == value,
      orElse: () => IncomeSource.cash,
    );
  }
}

/// Income entry entity tracking money coming in
/// Aligned with PRD Story 2.3: Income Entry Screen and database schema
class IncomeEntry extends Equatable {
  final String id;
  final String userId;
  final double amount;
  final String currency; // KES, NGN, GHS, ZAR, USD, EUR
  final DateTime incomeDate; // Date when income was received
  final IncomeType incomeType; // fixed, variable, mixed
  final IncomeSource? incomeSource; // cash, mobileMoney, formalSalary, gigIncome, other
  final String? description; // Optional notes about the income
  final DateTime createdAt;
  final DateTime updatedAt;

  const IncomeEntry({
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

  IncomeEntry copyWith({
    String? id,
    String? userId,
    double? amount,
    String? currency,
    DateTime? incomeDate,
    IncomeType? incomeType,
    IncomeSource? incomeSource,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return IncomeEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      incomeDate: incomeDate ?? this.incomeDate,
      incomeType: incomeType ?? this.incomeType,
      incomeSource: incomeSource ?? this.incomeSource,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        amount,
        currency,
        incomeDate,
        incomeType,
        incomeSource,
        description,
        createdAt,
        updatedAt,
      ];
}
