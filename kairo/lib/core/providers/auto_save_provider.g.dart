// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_save_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$autoSaveServiceHash() => r'4c1f078272dd22d4ce7f328c9a31291bb97ba0a6';

/// Provider for auto-save service
/// Each screen/feature can have its own instance
///
/// Copied from [autoSaveService].
@ProviderFor(autoSaveService)
final autoSaveServiceProvider = AutoDisposeProvider<AutoSaveService>.internal(
  autoSaveService,
  name: r'autoSaveServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$autoSaveServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AutoSaveServiceRef = AutoDisposeProviderRef<AutoSaveService>;
String _$autoSaveStatusHash() => r'cd39ffb0941557a3296b234941dd56cb266c4a6b';

/// Provider for auto-save status
/// Listens to status changes for UI updates
///
/// Copied from [AutoSaveStatus].
@ProviderFor(AutoSaveStatus)
final autoSaveStatusProvider =
    AutoDisposeNotifierProvider<AutoSaveStatus, SaveStatus>.internal(
  AutoSaveStatus.new,
  name: r'autoSaveStatusProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$autoSaveStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AutoSaveStatus = AutoDisposeNotifier<SaveStatus>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
