import 'package:kairo/features/allocation/data/datasources/allocation_remote_datasource.dart';
import 'package:kairo/features/allocation/data/models/allocation_category_model.dart';
import 'package:kairo/features/allocation/data/models/allocation_strategy_model.dart';
import 'package:kairo/features/allocation/data/models/income_entry_model.dart';
import 'package:kairo/features/allocation/domain/entities/allocation_category.dart';
import 'package:kairo/features/allocation/domain/entities/allocation_strategy.dart';
import 'package:kairo/features/allocation/domain/entities/income_entry.dart';
import 'package:kairo/features/allocation/domain/repositories/allocation_repository.dart';

/// Implementation of AllocationRepository using Supabase
class AllocationRepositoryImpl implements AllocationRepository {
  final AllocationRemoteDataSource _remoteDataSource;
  final String _userId;

  AllocationRepositoryImpl(this._remoteDataSource, this._userId);

  // ============================================================================
  // ALLOCATION CATEGORIES
  // ============================================================================

  @override
  Future<List<AllocationCategory>> getCategories() async {
    final models = await _remoteDataSource.getCategories(_userId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<AllocationCategory> createCategory(AllocationCategory category) async {
    final model = AllocationCategoryModel.fromEntity(category);
    final created = await _remoteDataSource.createCategory(model);
    return created.toEntity();
  }

  @override
  Future<AllocationCategory> updateCategory(AllocationCategory category) async {
    final model = AllocationCategoryModel.fromEntity(category);
    final updated = await _remoteDataSource.updateCategory(model);
    return updated.toEntity();
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    await _remoteDataSource.deleteCategory(categoryId);
  }

  @override
  Future<void> reorderCategories(List<String> categoryIds) async {
    // Update display_order for each category
    for (var i = 0; i < categoryIds.length; i++) {
      final categories = await getCategories();
      final category = categories.firstWhere((c) => c.id == categoryIds[i]);
      await updateCategory(category.copyWith(displayOrder: i));
    }
  }

  // ============================================================================
  // ALLOCATION STRATEGIES
  // ============================================================================

  @override
  Future<List<AllocationStrategy>> getStrategies() async {
    final models = await _remoteDataSource.getStrategies(_userId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<AllocationStrategy?> getActiveStrategy() async {
    final model = await _remoteDataSource.getActiveStrategy(_userId);
    return model?.toEntity();
  }

  @override
  Future<AllocationStrategy> createStrategy(AllocationStrategy strategy) async {
    final model = AllocationStrategyModel.fromEntity(strategy);
    final created = await _remoteDataSource.createStrategy(model);
    return created.toEntity();
  }

  @override
  Future<AllocationStrategy> updateStrategy(AllocationStrategy strategy) async {
    final model = AllocationStrategyModel.fromEntity(strategy);
    final updated = await _remoteDataSource.updateStrategy(model);
    return updated.toEntity();
  }

  @override
  Future<void> deleteStrategy(String strategyId) async {
    await _remoteDataSource.deleteStrategy(strategyId);
  }

  @override
  Future<void> setActiveStrategy(String strategyId) async {
    await _remoteDataSource.setActiveStrategy(_userId, strategyId);
  }

  // ============================================================================
  // INCOME ENTRIES
  // ============================================================================

  @override
  Future<List<IncomeEntry>> getIncomeEntries({int? limit, int? offset}) async {
    final models = await _remoteDataSource.getIncomeEntries(
      _userId,
      limit: limit,
      offset: offset,
    );
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<IncomeEntry?> getLatestIncome() async {
    final model = await _remoteDataSource.getLatestIncome(_userId);
    return model?.toEntity();
  }

  @override
  Future<IncomeEntry> createIncomeEntry(IncomeEntry income) async {
    final model = IncomeEntryModel.fromEntity(income);
    final created = await _remoteDataSource.createIncomeEntry(model);
    return created.toEntity();
  }

  @override
  Future<IncomeEntry> updateIncomeEntry(IncomeEntry income) async {
    final model = IncomeEntryModel.fromEntity(income);
    final updated = await _remoteDataSource.updateIncomeEntry(model);
    return updated.toEntity();
  }

  @override
  Future<void> deleteIncomeEntry(String incomeId) async {
    await _remoteDataSource.deleteIncomeEntry(incomeId);
  }

  // ============================================================================
  // ALLOCATION OPERATIONS
  // ============================================================================

  @override
  Future<void> saveAllocation({
    required IncomeEntry income,
    required AllocationStrategy strategy,
  }) async {
    final incomeModel = IncomeEntryModel.fromEntity(income);
    final strategyModel = AllocationStrategyModel.fromEntity(strategy);

    await _remoteDataSource.saveAllocation(
      income: incomeModel,
      strategy: strategyModel,
    );
  }

  @override
  Future<Map<String, dynamic>> getAllocationSummary() async {
    return await _remoteDataSource.getAllocationSummary(_userId);
  }
}
