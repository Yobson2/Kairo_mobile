import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:kairo/core/providers/supabase_provider.dart';
import 'package:kairo/features/allocation/data/datasources/allocation_remote_datasource.dart';
import 'package:kairo/features/allocation/data/repositories/allocation_repository_impl.dart';
import 'package:kairo/features/allocation/domain/entities/allocation_category.dart';
import 'package:kairo/features/allocation/domain/entities/allocation_strategy.dart';
import 'package:kairo/features/allocation/domain/entities/income_entry.dart';
import 'package:kairo/features/allocation/domain/repositories/allocation_repository.dart';
import 'package:kairo/features/auth/presentation/providers/auth_providers.dart';

part 'allocation_providers.g.dart';

/// Provides the AllocationRemoteDataSource
@riverpod
AllocationRemoteDataSource allocationRemoteDataSource(
    AllocationRemoteDataSourceRef ref) {
  final supabase = ref.watch(supabaseProvider);
  return AllocationRemoteDataSource(supabase);
}

/// Provides the AllocationRepository
@riverpod
AllocationRepository allocationRepository(AllocationRepositoryRef ref) {
  final remoteDataSource = ref.watch(allocationRemoteDataSourceProvider);
  final currentUser = ref.watch(currentUserProvider);

  // Use current user ID, or empty string if not logged in
  final userId = currentUser.value?.id ?? '';

  return AllocationRepositoryImpl(remoteDataSource, userId);
}

/// Provides all allocation categories for the current user
@riverpod
Future<List<AllocationCategory>> allocationCategories(
    AllocationCategoriesRef ref) async {
  final repository = ref.watch(allocationRepositoryProvider);
  return repository.getCategories();
}

/// Provides the active allocation strategy
@riverpod
Future<AllocationStrategy?> activeStrategy(ActiveStrategyRef ref) async {
  final repository = ref.watch(allocationRepositoryProvider);
  return repository.getActiveStrategy();
}

/// Provides all allocation strategies
@riverpod
Future<List<AllocationStrategy>> allocationStrategies(
    AllocationStrategiesRef ref) async {
  final repository = ref.watch(allocationRepositoryProvider);
  return repository.getStrategies();
}

/// Provides the latest income entry
@riverpod
Future<IncomeEntry?> latestIncome(LatestIncomeRef ref) async {
  final repository = ref.watch(allocationRepositoryProvider);
  return repository.getLatestIncome();
}

/// Provides the allocation summary for dashboard
@riverpod
Future<Map<String, dynamic>> allocationSummary(AllocationSummaryRef ref) async {
  final repository = ref.watch(allocationRepositoryProvider);
  return repository.getAllocationSummary();
}

/// Provides all income entries for the current user
@riverpod
Future<List<IncomeEntry>> incomeEntries(IncomeEntriesRef ref, {int? limit, int? offset}) async {
  final repository = ref.watch(allocationRepositoryProvider);
  return repository.getIncomeEntries(limit: limit, offset: offset);
}

/// Create income entry
@riverpod
class CreateIncomeEntry extends _$CreateIncomeEntry {
  @override
  FutureOr<void> build() {}

  Future<void> execute(IncomeEntry income) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(allocationRepositoryProvider);
      await repository.createIncomeEntry(income);
      ref.invalidate(incomeEntriesProvider);
      ref.invalidate(latestIncomeProvider);
    });
  }
}

/// Update income entry
@riverpod
class UpdateIncomeEntry extends _$UpdateIncomeEntry {
  @override
  FutureOr<void> build() {}

  Future<void> execute(IncomeEntry income) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(allocationRepositoryProvider);
      await repository.updateIncomeEntry(income);
      ref.invalidate(incomeEntriesProvider);
      ref.invalidate(latestIncomeProvider);
    });
  }
}

/// Delete income entry
@riverpod
class DeleteIncomeEntry extends _$DeleteIncomeEntry {
  @override
  FutureOr<void> build() {}

  Future<void> execute(String incomeId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(allocationRepositoryProvider);
      await repository.deleteIncomeEntry(incomeId);
      ref.invalidate(incomeEntriesProvider);
      ref.invalidate(latestIncomeProvider);
    });
  }
}

/// Save allocation - combines income entry and strategy
@riverpod
class SaveAllocation extends _$SaveAllocation {
  @override
  FutureOr<void> build() {}

  Future<void> execute({
    required IncomeEntry income,
    required AllocationStrategy strategy,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(allocationRepositoryProvider);
      await repository.saveAllocation(
        income: income,
        strategy: strategy,
      );

      // Invalidate related providers to refresh data
      ref.invalidate(allocationCategoriesProvider);
      ref.invalidate(activeStrategyProvider);
      ref.invalidate(latestIncomeProvider);
      ref.invalidate(allocationSummaryProvider);
    });
  }
}

/// Create a new allocation category
@riverpod
class CreateCategory extends _$CreateCategory {
  @override
  FutureOr<void> build() {}

  Future<void> execute(AllocationCategory category) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(allocationRepositoryProvider);
      await repository.createCategory(category);
      ref.invalidate(allocationCategoriesProvider);
    });
  }
}

/// Update an existing allocation category
@riverpod
class UpdateCategory extends _$UpdateCategory {
  @override
  FutureOr<void> build() {}

  Future<void> execute(AllocationCategory category) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(allocationRepositoryProvider);
      await repository.updateCategory(category);
      ref.invalidate(allocationCategoriesProvider);
    });
  }
}

/// Delete an allocation category
@riverpod
class DeleteCategory extends _$DeleteCategory {
  @override
  FutureOr<void> build() {}

  Future<void> execute(String categoryId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(allocationRepositoryProvider);
      await repository.deleteCategory(categoryId);
      ref.invalidate(allocationCategoriesProvider);
    });
  }
}

/// Reorder categories
@riverpod
class ReorderCategories extends _$ReorderCategories {
  @override
  FutureOr<void> build() {}

  Future<void> execute(List<AllocationCategory> reorderedCategories) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(allocationRepositoryProvider);

      // Update display_order for each category
      for (int i = 0; i < reorderedCategories.length; i++) {
        final updatedCategory = reorderedCategories[i].copyWith(
          displayOrder: i + 1,
          updatedAt: DateTime.now(),
        );
        await repository.updateCategory(updatedCategory);
      }

      ref.invalidate(allocationCategoriesProvider);
    });
  }
}
