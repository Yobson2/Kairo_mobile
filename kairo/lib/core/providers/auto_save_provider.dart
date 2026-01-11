import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:kairo/core/services/auto_save_service.dart';

part 'auto_save_provider.g.dart';

/// Provider for auto-save service
/// Each screen/feature can have its own instance
@riverpod
AutoSaveService autoSaveService(AutoSaveServiceRef ref) {
  final service = AutoSaveService(
    debounceDuration: const Duration(milliseconds: 500),
  );

  // Dispose when no longer needed
  ref.onDispose(() {
    service.dispose();
  });

  return service;
}

/// Provider for auto-save status
/// Listens to status changes for UI updates
@riverpod
class AutoSaveStatus extends _$AutoSaveStatus {
  @override
  SaveStatus build() {
    final service = ref.watch(autoSaveServiceProvider);

    // Listen to status changes
    void listener() {
      state = service.status;
    }

    service.addStatusListener(listener);

    ref.onDispose(() {
      service.removeStatusListener(listener);
    });

    return service.status;
  }
}
