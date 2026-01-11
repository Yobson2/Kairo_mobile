// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'allocation_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allocationRemoteDataSourceHash() =>
    r'72244ef5405720cb1f7afbf4cde7c7c702849f92';

/// Provides the AllocationRemoteDataSource
///
/// Copied from [allocationRemoteDataSource].
@ProviderFor(allocationRemoteDataSource)
final allocationRemoteDataSourceProvider =
    AutoDisposeProvider<AllocationRemoteDataSource>.internal(
  allocationRemoteDataSource,
  name: r'allocationRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allocationRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllocationRemoteDataSourceRef
    = AutoDisposeProviderRef<AllocationRemoteDataSource>;
String _$allocationRepositoryHash() =>
    r'e41d2b648897e6a8b157a9bbfbb974f50afe46ef';

/// Provides the AllocationRepository
///
/// Copied from [allocationRepository].
@ProviderFor(allocationRepository)
final allocationRepositoryProvider =
    AutoDisposeProvider<AllocationRepository>.internal(
  allocationRepository,
  name: r'allocationRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allocationRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllocationRepositoryRef = AutoDisposeProviderRef<AllocationRepository>;
String _$allocationCategoriesHash() =>
    r'2ea9955f3475eeccb01d0413a4802a73da7b23a1';

/// Provides all allocation categories for the current user
///
/// Copied from [allocationCategories].
@ProviderFor(allocationCategories)
final allocationCategoriesProvider =
    AutoDisposeFutureProvider<List<AllocationCategory>>.internal(
  allocationCategories,
  name: r'allocationCategoriesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allocationCategoriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllocationCategoriesRef
    = AutoDisposeFutureProviderRef<List<AllocationCategory>>;
String _$activeStrategyHash() => r'7485856fbc6b9bce2d0f264522bb4f402c83fd9e';

/// Provides the active allocation strategy
///
/// Copied from [activeStrategy].
@ProviderFor(activeStrategy)
final activeStrategyProvider =
    AutoDisposeFutureProvider<AllocationStrategy?>.internal(
  activeStrategy,
  name: r'activeStrategyProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeStrategyHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveStrategyRef = AutoDisposeFutureProviderRef<AllocationStrategy?>;
String _$allocationStrategiesHash() =>
    r'781d63f3e380c0bcdecd9920c0e1e117e80691e3';

/// Provides all allocation strategies
///
/// Copied from [allocationStrategies].
@ProviderFor(allocationStrategies)
final allocationStrategiesProvider =
    AutoDisposeFutureProvider<List<AllocationStrategy>>.internal(
  allocationStrategies,
  name: r'allocationStrategiesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allocationStrategiesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllocationStrategiesRef
    = AutoDisposeFutureProviderRef<List<AllocationStrategy>>;
String _$latestIncomeHash() => r'b95cd139a9a0d4b0fd403488f7cdfba300192ad0';

/// Provides the latest income entry
///
/// Copied from [latestIncome].
@ProviderFor(latestIncome)
final latestIncomeProvider = AutoDisposeFutureProvider<IncomeEntry?>.internal(
  latestIncome,
  name: r'latestIncomeProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$latestIncomeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LatestIncomeRef = AutoDisposeFutureProviderRef<IncomeEntry?>;
String _$allocationSummaryHash() => r'b22fe2a9142069bf61c3ee4c02e9577a108af245';

/// Provides the allocation summary for dashboard
///
/// Copied from [allocationSummary].
@ProviderFor(allocationSummary)
final allocationSummaryProvider =
    AutoDisposeFutureProvider<Map<String, dynamic>>.internal(
  allocationSummary,
  name: r'allocationSummaryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allocationSummaryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllocationSummaryRef
    = AutoDisposeFutureProviderRef<Map<String, dynamic>>;
String _$incomeEntriesHash() => r'31362e7f24794a4c2378fc3a9c487d0e2fff2f40';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Provides all income entries for the current user
///
/// Copied from [incomeEntries].
@ProviderFor(incomeEntries)
const incomeEntriesProvider = IncomeEntriesFamily();

/// Provides all income entries for the current user
///
/// Copied from [incomeEntries].
class IncomeEntriesFamily extends Family<AsyncValue<List<IncomeEntry>>> {
  /// Provides all income entries for the current user
  ///
  /// Copied from [incomeEntries].
  const IncomeEntriesFamily();

  /// Provides all income entries for the current user
  ///
  /// Copied from [incomeEntries].
  IncomeEntriesProvider call({
    int? limit,
    int? offset,
  }) {
    return IncomeEntriesProvider(
      limit: limit,
      offset: offset,
    );
  }

  @override
  IncomeEntriesProvider getProviderOverride(
    covariant IncomeEntriesProvider provider,
  ) {
    return call(
      limit: provider.limit,
      offset: provider.offset,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'incomeEntriesProvider';
}

/// Provides all income entries for the current user
///
/// Copied from [incomeEntries].
class IncomeEntriesProvider
    extends AutoDisposeFutureProvider<List<IncomeEntry>> {
  /// Provides all income entries for the current user
  ///
  /// Copied from [incomeEntries].
  IncomeEntriesProvider({
    int? limit,
    int? offset,
  }) : this._internal(
          (ref) => incomeEntries(
            ref as IncomeEntriesRef,
            limit: limit,
            offset: offset,
          ),
          from: incomeEntriesProvider,
          name: r'incomeEntriesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$incomeEntriesHash,
          dependencies: IncomeEntriesFamily._dependencies,
          allTransitiveDependencies:
              IncomeEntriesFamily._allTransitiveDependencies,
          limit: limit,
          offset: offset,
        );

  IncomeEntriesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.limit,
    required this.offset,
  }) : super.internal();

  final int? limit;
  final int? offset;

  @override
  Override overrideWith(
    FutureOr<List<IncomeEntry>> Function(IncomeEntriesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: IncomeEntriesProvider._internal(
        (ref) => create(ref as IncomeEntriesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        limit: limit,
        offset: offset,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<IncomeEntry>> createElement() {
    return _IncomeEntriesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IncomeEntriesProvider &&
        other.limit == limit &&
        other.offset == offset;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, limit.hashCode);
    hash = _SystemHash.combine(hash, offset.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin IncomeEntriesRef on AutoDisposeFutureProviderRef<List<IncomeEntry>> {
  /// The parameter `limit` of this provider.
  int? get limit;

  /// The parameter `offset` of this provider.
  int? get offset;
}

class _IncomeEntriesProviderElement
    extends AutoDisposeFutureProviderElement<List<IncomeEntry>>
    with IncomeEntriesRef {
  _IncomeEntriesProviderElement(super.provider);

  @override
  int? get limit => (origin as IncomeEntriesProvider).limit;
  @override
  int? get offset => (origin as IncomeEntriesProvider).offset;
}

String _$createIncomeEntryHash() => r'ce326f07b593cdcfa6df3c56fcee896fdb9f6114';

/// Create income entry
///
/// Copied from [CreateIncomeEntry].
@ProviderFor(CreateIncomeEntry)
final createIncomeEntryProvider =
    AutoDisposeAsyncNotifierProvider<CreateIncomeEntry, void>.internal(
  CreateIncomeEntry.new,
  name: r'createIncomeEntryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$createIncomeEntryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CreateIncomeEntry = AutoDisposeAsyncNotifier<void>;
String _$updateIncomeEntryHash() => r'd17c5f0313968e8d401a693510c41e2ad155eb87';

/// Update income entry
///
/// Copied from [UpdateIncomeEntry].
@ProviderFor(UpdateIncomeEntry)
final updateIncomeEntryProvider =
    AutoDisposeAsyncNotifierProvider<UpdateIncomeEntry, void>.internal(
  UpdateIncomeEntry.new,
  name: r'updateIncomeEntryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$updateIncomeEntryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UpdateIncomeEntry = AutoDisposeAsyncNotifier<void>;
String _$deleteIncomeEntryHash() => r'62dd00648659511bc18d7f0700bff40e7fa126ef';

/// Delete income entry
///
/// Copied from [DeleteIncomeEntry].
@ProviderFor(DeleteIncomeEntry)
final deleteIncomeEntryProvider =
    AutoDisposeAsyncNotifierProvider<DeleteIncomeEntry, void>.internal(
  DeleteIncomeEntry.new,
  name: r'deleteIncomeEntryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deleteIncomeEntryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DeleteIncomeEntry = AutoDisposeAsyncNotifier<void>;
String _$saveAllocationHash() => r'aa9062a10bd2495df120aa4e98bdc14a9a985246';

/// Save allocation - combines income entry and strategy
///
/// Copied from [SaveAllocation].
@ProviderFor(SaveAllocation)
final saveAllocationProvider =
    AutoDisposeAsyncNotifierProvider<SaveAllocation, void>.internal(
  SaveAllocation.new,
  name: r'saveAllocationProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$saveAllocationHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SaveAllocation = AutoDisposeAsyncNotifier<void>;
String _$createCategoryHash() => r'772173b4cdc2e134ce582511d853bcba8832765f';

/// Create a new allocation category
///
/// Copied from [CreateCategory].
@ProviderFor(CreateCategory)
final createCategoryProvider =
    AutoDisposeAsyncNotifierProvider<CreateCategory, void>.internal(
  CreateCategory.new,
  name: r'createCategoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$createCategoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CreateCategory = AutoDisposeAsyncNotifier<void>;
String _$updateCategoryHash() => r'da4576a2fe5b7ba9ab505930c9f92e5c4292927f';

/// Update an existing allocation category
///
/// Copied from [UpdateCategory].
@ProviderFor(UpdateCategory)
final updateCategoryProvider =
    AutoDisposeAsyncNotifierProvider<UpdateCategory, void>.internal(
  UpdateCategory.new,
  name: r'updateCategoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$updateCategoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UpdateCategory = AutoDisposeAsyncNotifier<void>;
String _$deleteCategoryHash() => r'0c0dcb17c2392b20832ae592294ddff2e23d9ad9';

/// Delete an allocation category
///
/// Copied from [DeleteCategory].
@ProviderFor(DeleteCategory)
final deleteCategoryProvider =
    AutoDisposeAsyncNotifierProvider<DeleteCategory, void>.internal(
  DeleteCategory.new,
  name: r'deleteCategoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deleteCategoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DeleteCategory = AutoDisposeAsyncNotifier<void>;
String _$reorderCategoriesHash() => r'99436636eeb0aac915cf88933388b3893faced5b';

/// Reorder categories
///
/// Copied from [ReorderCategories].
@ProviderFor(ReorderCategories)
final reorderCategoriesProvider =
    AutoDisposeAsyncNotifierProvider<ReorderCategories, void>.internal(
  ReorderCategories.new,
  name: r'reorderCategoriesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reorderCategoriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ReorderCategories = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
