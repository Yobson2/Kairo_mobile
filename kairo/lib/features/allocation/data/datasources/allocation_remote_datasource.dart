import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kairo/features/allocation/data/models/allocation_category_model.dart';
import 'package:kairo/features/allocation/data/models/allocation_strategy_model.dart';
import 'package:kairo/features/allocation/data/models/income_entry_model.dart';

/// Remote data source for allocation operations using Supabase
class AllocationRemoteDataSource {
  final SupabaseClient _supabase;

  AllocationRemoteDataSource(this._supabase);

  // ============================================================================
  // ALLOCATION CATEGORIES
  // ============================================================================

  Future<List<AllocationCategoryModel>> getCategories(String userId) async {
    try {
      final data = await _supabase
          .from('allocation_categories')
          .select()
          .eq('user_id', userId)
          .order('display_order');

      return (data as List)
          .map((item) => AllocationCategoryModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  Future<AllocationCategoryModel> createCategory(
      AllocationCategoryModel category) async {
    try {
      final data = await _supabase
          .from('allocation_categories')
          .insert(category.toJson())
          .select()
          .single();

      return AllocationCategoryModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  Future<AllocationCategoryModel> updateCategory(
      AllocationCategoryModel category) async {
    try {
      final data = await _supabase
          .from('allocation_categories')
          .update(category.toJson())
          .eq('id', category.id)
          .select()
          .single();

      return AllocationCategoryModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await _supabase
          .from('allocation_categories')
          .delete()
          .eq('id', categoryId);
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  // ============================================================================
  // ALLOCATION STRATEGIES
  // ============================================================================

  Future<List<AllocationStrategyModel>> getStrategies(String userId) async {
    try {
      final data = await _supabase
          .from('allocation_strategies')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (data as List)
          .map((item) => AllocationStrategyModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch strategies: $e');
    }
  }

  Future<AllocationStrategyModel?> getActiveStrategy(String userId) async {
    try {
      final data = await _supabase
          .from('allocation_strategies')
          .select()
          .eq('user_id', userId)
          .eq('is_active', true)
          .maybeSingle();

      if (data == null) return null;
      return AllocationStrategyModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch active strategy: $e');
    }
  }

  Future<AllocationStrategyModel> createStrategy(
      AllocationStrategyModel strategy) async {
    try {
      final data = await _supabase
          .from('allocation_strategies')
          .insert(strategy.toJson())
          .select()
          .single();

      return AllocationStrategyModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to create strategy: $e');
    }
  }

  Future<AllocationStrategyModel> updateStrategy(
      AllocationStrategyModel strategy) async {
    try {
      final data = await _supabase
          .from('allocation_strategies')
          .update(strategy.toJson())
          .eq('id', strategy.id)
          .select()
          .single();

      return AllocationStrategyModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to update strategy: $e');
    }
  }

  Future<void> deleteStrategy(String strategyId) async {
    try {
      await _supabase
          .from('allocation_strategies')
          .delete()
          .eq('id', strategyId);
    } catch (e) {
      throw Exception('Failed to delete strategy: $e');
    }
  }

  Future<void> setActiveStrategy(String userId, String strategyId) async {
    try {
      // Deactivate all strategies first
      await _supabase
          .from('allocation_strategies')
          .update({'is_active': false})
          .eq('user_id', userId);

      // Activate the selected strategy
      await _supabase
          .from('allocation_strategies')
          .update({'is_active': true})
          .eq('id', strategyId);
    } catch (e) {
      throw Exception('Failed to set active strategy: $e');
    }
  }

  // ============================================================================
  // INCOME ENTRIES
  // ============================================================================

  Future<List<IncomeEntryModel>> getIncomeEntries(
    String userId, {
    int? limit,
    int? offset,
  }) async {
    try {
      var query = _supabase
          .from('income_entries')
          .select()
          .eq('user_id', userId)
          .order('received_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 10) - 1);
      }

      final data = await query;

      return (data as List)
          .map((item) => IncomeEntryModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch income entries: $e');
    }
  }

  Future<IncomeEntryModel?> getLatestIncome(String userId) async {
    try {
      final data = await _supabase
          .from('income_entries')
          .select()
          .eq('user_id', userId)
          .order('received_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (data == null) return null;
      return IncomeEntryModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch latest income: $e');
    }
  }

  Future<IncomeEntryModel> createIncomeEntry(IncomeEntryModel income) async {
    try {
      final data = await _supabase
          .from('income_entries')
          .insert(income.toJson())
          .select()
          .single();

      return IncomeEntryModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to create income entry: $e');
    }
  }

  Future<IncomeEntryModel> updateIncomeEntry(IncomeEntryModel income) async {
    try {
      final data = await _supabase
          .from('income_entries')
          .update(income.toJson())
          .eq('id', income.id)
          .select()
          .single();

      return IncomeEntryModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to update income entry: $e');
    }
  }

  Future<void> deleteIncomeEntry(String incomeId) async {
    try {
      await _supabase.from('income_entries').delete().eq('id', incomeId);
    } catch (e) {
      throw Exception('Failed to delete income entry: $e');
    }
  }

  // ============================================================================
  // ALLOCATION OPERATIONS
  // ============================================================================

  Future<void> saveAllocation({
    required IncomeEntryModel income,
    required AllocationStrategyModel strategy,
  }) async {
    try {
      // Start a transaction-like operation
      // 1. Create income entry
      final createdIncome = await createIncomeEntry(income);

      // 2. Create or update strategy
      final savedStrategy = strategy.id.isEmpty
          ? await createStrategy(strategy)
          : await updateStrategy(strategy);

      // 3. Create allocated amounts for each category
      final allocatedAmounts = <Map<String, dynamic>>[];
      for (final allocation in savedStrategy.allocations) {
        final allocatedAmount = income.amount * (allocation['percentage'] / 100);
        allocatedAmounts.add({
          'user_id': income.userId,
          'income_entry_id': createdIncome.id,
          'category_id': allocation['category_id'],
          'strategy_id': savedStrategy.id,
          'allocated_amount': allocatedAmount,
          'percentage': allocation['percentage'],
        });
      }

      if (allocatedAmounts.isNotEmpty) {
        await _supabase.from('allocated_amounts').insert(allocatedAmounts);
      }
    } catch (e) {
      throw Exception('Failed to save allocation: $e');
    }
  }

  Future<Map<String, dynamic>> getAllocationSummary(String userId) async {
    try {
      // Get latest income
      final latestIncome = await getLatestIncome(userId);

      // Get active strategy
      final activeStrategy = await getActiveStrategy(userId);

      // Get categories
      final categories = await getCategories(userId);

      // Get total allocated this month
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);

      final allocatedData = await _supabase
          .from('allocated_amounts')
          .select('allocated_amount')
          .eq('user_id', userId)
          .gte('created_at', firstDayOfMonth.toIso8601String());

      double totalAllocated = 0;
      for (final item in allocatedData as List) {
        totalAllocated += (item['allocated_amount'] as num).toDouble();
      }

      return {
        'latest_income': latestIncome?.toJson(),
        'active_strategy': activeStrategy?.toJson(),
        'categories': categories.map((c) => c.toJson()).toList(),
        'total_allocated_this_month': totalAllocated,
      };
    } catch (e) {
      throw Exception('Failed to fetch allocation summary: $e');
    }
  }
}
