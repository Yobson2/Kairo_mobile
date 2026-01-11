import 'package:kairo/features/allocation/domain/entities/allocation_category.dart';
import 'package:kairo/features/allocation/domain/entities/allocation_strategy.dart';
import 'package:kairo/features/allocation/domain/entities/income_entry.dart';

/// Repository interface for allocation operations
abstract class AllocationRepository {
  // ============================================================================
  // ALLOCATION CATEGORIES
  // ============================================================================

  /// Get all allocation categories for the current user
  Future<List<AllocationCategory>> getCategories();

  /// Create a new allocation category
  Future<AllocationCategory> createCategory(AllocationCategory category);

  /// Update an existing allocation category
  Future<AllocationCategory> updateCategory(AllocationCategory category);

  /// Delete an allocation category
  Future<void> deleteCategory(String categoryId);

  /// Reorder categories
  Future<void> reorderCategories(List<String> categoryIds);

  // ============================================================================
  // ALLOCATION STRATEGIES
  // ============================================================================

  /// Get all allocation strategies for the current user
  Future<List<AllocationStrategy>> getStrategies();

  /// Get the active allocation strategy
  Future<AllocationStrategy?> getActiveStrategy();

  /// Create a new allocation strategy
  Future<AllocationStrategy> createStrategy(AllocationStrategy strategy);

  /// Update an existing allocation strategy
  Future<AllocationStrategy> updateStrategy(AllocationStrategy strategy);

  /// Delete an allocation strategy
  Future<void> deleteStrategy(String strategyId);

  /// Set a strategy as active (deactivates others)
  Future<void> setActiveStrategy(String strategyId);

  // ============================================================================
  // INCOME ENTRIES
  // ============================================================================

  /// Get income entries for the current user
  Future<List<IncomeEntry>> getIncomeEntries({int? limit, int? offset});

  /// Get latest income entry
  Future<IncomeEntry?> getLatestIncome();

  /// Create a new income entry
  Future<IncomeEntry> createIncomeEntry(IncomeEntry income);

  /// Update an existing income entry
  Future<IncomeEntry> updateIncomeEntry(IncomeEntry income);

  /// Delete an income entry
  Future<void> deleteIncomeEntry(String incomeId);

  // ============================================================================
  // ALLOCATION OPERATIONS
  // ============================================================================

  /// Save a complete allocation (income + category allocations)
  /// This is the main operation for the onboarding flow
  Future<void> saveAllocation({
    required IncomeEntry income,
    required AllocationStrategy strategy,
  });

  /// Get allocation summary for dashboard
  Future<Map<String, dynamic>> getAllocationSummary();
}
