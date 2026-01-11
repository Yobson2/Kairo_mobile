// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'income_entry_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IncomeEntryModel _$IncomeEntryModelFromJson(Map<String, dynamic> json) =>
    IncomeEntryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      incomeDate: DateTime.parse(json['income_date'] as String),
      incomeType: json['income_type'] as String,
      incomeSource: json['income_source'] as String?,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$IncomeEntryModelToJson(IncomeEntryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'amount': instance.amount,
      'currency': instance.currency,
      'income_date': instance.incomeDate.toIso8601String(),
      'income_type': instance.incomeType,
      'income_source': instance.incomeSource,
      'description': instance.description,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
