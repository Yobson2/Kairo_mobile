import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kairo/features/allocation/data/datasources/allocation_remote_datasource.dart';
import 'package:kairo/features/allocation/data/models/allocation_category_model.dart';
import 'package:kairo/features/allocation/data/models/allocation_strategy_model.dart';
import 'package:kairo/features/allocation/data/models/income_entry_model.dart';
import 'package:kairo/features/allocation/data/repositories/allocation_repository_impl.dart';
import 'package:kairo/features/allocation/domain/entities/allocation_category.dart';
import 'package:kairo/features/allocation/domain/entities/allocation_strategy.dart';
import 'package:kairo/features/allocation/domain/entities/income_entry.dart';

class MockAllocationRemoteDataSource extends Mock
    implements AllocationRemoteDataSource {}

void main() {
  late AllocationRepositoryImpl repository;
  late MockAllocationRemoteDataSource mockRemoteDataSource;
  const testUserId = 'user-123';

  setUp(() {
    mockRemoteDataSource = MockAllocationRemoteDataSource();
    repository = AllocationRepositoryImpl(mockRemoteDataSource, testUserId);
  });

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(AllocationCategoryModel(
      id: 'test',
      userId: 'test',
      name: 'test',
      color: '#000000',
      icon: null,
      isDefault: false,
      displayOrder: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
    registerFallbackValue(AllocationStrategyModel(
      id: 'test',
      userId: 'test',
      name: 'test',
      isActive: false,
      isTemplate: false,
      allocations: const [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
    registerFallbackValue(IncomeEntryModel(
      id: 'test',
      userId: 'test',
      amount: 0,
      currency: 'KES',
      incomeDate: DateTime.now(),
      incomeType: 'fixed',
      incomeSource: null,
      description: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
  });

  group('AllocationRepositoryImpl - Categories', () {
    final testCategoryModel = AllocationCategoryModel(
      id: 'cat-123',
      userId: testUserId,
      name: 'Family Support',
      color: '#EF4444',
      icon: 'family',
      isDefault: true,
      displayOrder: 1,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    test('getCategories should return list of categories', () async {
      // Arrange
      when(() => mockRemoteDataSource.getCategories(testUserId))
          .thenAnswer((_) async => [testCategoryModel]);

      // Act
      final result = await repository.getCategories();

      // Assert
      expect(result, isA<List<AllocationCategory>>());
      expect(result.length, 1);
      expect(result.first.name, 'Family Support');
      verify(() => mockRemoteDataSource.getCategories(testUserId)).called(1);
    });

    test('createCategory should return created category', () async {
      // Arrange
      final testCategory = testCategoryModel.toEntity();
      when(() => mockRemoteDataSource.createCategory(any()))
          .thenAnswer((_) async => testCategoryModel);

      // Act
      final result = await repository.createCategory(testCategory);

      // Assert
      expect(result, isA<AllocationCategory>());
      expect(result.id, 'cat-123');
      verify(() => mockRemoteDataSource.createCategory(any())).called(1);
    });

    test('updateCategory should return updated category', () async {
      // Arrange
      final testCategory = testCategoryModel.toEntity();
      when(() => mockRemoteDataSource.updateCategory(any()))
          .thenAnswer((_) async => testCategoryModel);

      // Act
      final result = await repository.updateCategory(testCategory);

      // Assert
      expect(result, isA<AllocationCategory>());
      verify(() => mockRemoteDataSource.updateCategory(any())).called(1);
    });

    test('deleteCategory should call remote data source', () async {
      // Arrange
      when(() => mockRemoteDataSource.deleteCategory('cat-123'))
          .thenAnswer((_) async => {});

      // Act
      await repository.deleteCategory('cat-123');

      // Assert
      verify(() => mockRemoteDataSource.deleteCategory('cat-123')).called(1);
    });
  });

  group('AllocationRepositoryImpl - Strategies', () {
    final testStrategyModel = AllocationStrategyModel(
      id: 'strat-123',
      userId: testUserId,
      name: 'My Strategy',
      isActive: true,
      isTemplate: false,
      allocations: const [
        {'category_id': 'cat-1', 'percentage': 50.0},
        {'category_id': 'cat-2', 'percentage': 50.0},
      ],
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    test('getStrategies should return list of strategies', () async {
      // Arrange
      when(() => mockRemoteDataSource.getStrategies(testUserId))
          .thenAnswer((_) async => [testStrategyModel]);

      // Act
      final result = await repository.getStrategies();

      // Assert
      expect(result, isA<List<AllocationStrategy>>());
      expect(result.length, 1);
      expect(result.first.name, 'My Strategy');
      verify(() => mockRemoteDataSource.getStrategies(testUserId)).called(1);
    });

    test('getActiveStrategy should return active strategy', () async {
      // Arrange
      when(() => mockRemoteDataSource.getActiveStrategy(testUserId))
          .thenAnswer((_) async => testStrategyModel);

      // Act
      final result = await repository.getActiveStrategy();

      // Assert
      expect(result, isA<AllocationStrategy>());
      expect(result?.isActive, true);
      verify(() => mockRemoteDataSource.getActiveStrategy(testUserId))
          .called(1);
    });

    test('createStrategy should return created strategy', () async {
      // Arrange
      final testStrategy = testStrategyModel.toEntity();
      when(() => mockRemoteDataSource.createStrategy(any()))
          .thenAnswer((_) async => testStrategyModel);

      // Act
      final result = await repository.createStrategy(testStrategy);

      // Assert
      expect(result, isA<AllocationStrategy>());
      expect(result.id, 'strat-123');
      verify(() => mockRemoteDataSource.createStrategy(any())).called(1);
    });

    test('setActiveStrategy should call remote data source', () async {
      // Arrange
      when(() => mockRemoteDataSource.setActiveStrategy(testUserId, 'strat-123'))
          .thenAnswer((_) async => {});

      // Act
      await repository.setActiveStrategy('strat-123');

      // Assert
      verify(() => mockRemoteDataSource.setActiveStrategy(testUserId, 'strat-123'))
          .called(1);
    });

    test('deleteStrategy should call remote data source', () async {
      // Arrange
      when(() => mockRemoteDataSource.deleteStrategy('strat-123'))
          .thenAnswer((_) async => {});

      // Act
      await repository.deleteStrategy('strat-123');

      // Assert
      verify(() => mockRemoteDataSource.deleteStrategy('strat-123')).called(1);
    });
  });

  group('AllocationRepositoryImpl - Income', () {
    final testIncomeModel = IncomeEntryModel(
      id: 'income-123',
      userId: testUserId,
      amount: 1000.0,
      currency: 'KES',
      incomeDate: DateTime(2024, 1, 1),
      incomeType: 'variable',
      incomeSource: 'freelance',
      description: null,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    test('getIncomeEntries should return list of income entries', () async {
      // Arrange
      when(() => mockRemoteDataSource.getIncomeEntries(
            testUserId,
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          )).thenAnswer((_) async => [testIncomeModel]);

      // Act
      final result = await repository.getIncomeEntries();

      // Assert
      expect(result, isA<List<IncomeEntry>>());
      expect(result.length, 1);
      expect(result.first.amount, 1000.0);
      verify(() => mockRemoteDataSource.getIncomeEntries(
            testUserId,
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          )).called(1);
    });

    test('getLatestIncome should return latest income', () async {
      // Arrange
      when(() => mockRemoteDataSource.getLatestIncome(testUserId))
          .thenAnswer((_) async => testIncomeModel);

      // Act
      final result = await repository.getLatestIncome();

      // Assert
      expect(result, isA<IncomeEntry>());
      expect(result?.amount, 1000.0);
      verify(() => mockRemoteDataSource.getLatestIncome(testUserId)).called(1);
    });

    test('createIncomeEntry should return created income', () async {
      // Arrange
      final testIncome = testIncomeModel.toEntity();
      when(() => mockRemoteDataSource.createIncomeEntry(any()))
          .thenAnswer((_) async => testIncomeModel);

      // Act
      final result = await repository.createIncomeEntry(testIncome);

      // Assert
      expect(result, isA<IncomeEntry>());
      expect(result.id, 'income-123');
      verify(() => mockRemoteDataSource.createIncomeEntry(any())).called(1);
    });
  });

  group('AllocationRepositoryImpl - Allocation Operations', () {
    test('saveAllocation should call remote data source', () async {
      // Arrange
      final testIncome = IncomeEntry(
        id: '',
        userId: testUserId,
        amount: 1000.0,
        currency: 'KES',
        incomeDate: DateTime.now(),
        incomeType: IncomeType.variable,
        incomeSource: IncomeSource.gigIncome,
        description: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final testStrategy = AllocationStrategy(
        id: '',
        userId: testUserId,
        name: 'Test Strategy',
        isActive: true,
        isTemplate: false,
        allocations: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(() => mockRemoteDataSource.saveAllocation(
            income: any(named: 'income'),
            strategy: any(named: 'strategy'),
          )).thenAnswer((_) async => {});

      // Act
      await repository.saveAllocation(
        income: testIncome,
        strategy: testStrategy,
      );

      // Assert
      verify(() => mockRemoteDataSource.saveAllocation(
            income: any(named: 'income'),
            strategy: any(named: 'strategy'),
          )).called(1);
    });

    test('getAllocationSummary should return summary map', () async {
      // Arrange
      final mockSummary = {
        'latest_income': {'amount': 1000.0},
        'active_strategy': {'name': 'My Strategy'},
        'categories': [],
        'total_allocated_this_month': 500.0,
      };

      when(() => mockRemoteDataSource.getAllocationSummary(testUserId))
          .thenAnswer((_) async => mockSummary);

      // Act
      final result = await repository.getAllocationSummary();

      // Assert
      expect(result, isA<Map<String, dynamic>>());
      expect(result['total_allocated_this_month'], 500.0);
      verify(() => mockRemoteDataSource.getAllocationSummary(testUserId))
          .called(1);
    });
  });
}
