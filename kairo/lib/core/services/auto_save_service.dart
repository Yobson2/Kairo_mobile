import 'dart:async';
import 'package:flutter/foundation.dart';

/// Auto-save service with debouncing for forgiveness architecture
/// Automatically saves data after a period of inactivity
class AutoSaveService {
  Timer? _debounceTimer;
  final Duration debounceDuration;
  bool _isSaving = false;
  SaveStatus _status = SaveStatus.idle;

  /// Callbacks
  final List<VoidCallback> _statusListeners = [];

  AutoSaveService({
    this.debounceDuration = const Duration(milliseconds: 500),
  });

  /// Current save status
  SaveStatus get status => _status;

  /// Is currently saving
  bool get isSaving => _isSaving;

  /// Add a status listener
  void addStatusListener(VoidCallback listener) {
    _statusListeners.add(listener);
  }

  /// Remove a status listener
  void removeStatusListener(VoidCallback listener) {
    _statusListeners.remove(listener);
  }

  /// Notify all listeners of status change
  void _notifyListeners() {
    for (final listener in _statusListeners) {
      listener();
    }
  }

  /// Update status
  void _updateStatus(SaveStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      _notifyListeners();
    }
  }

  /// Schedule auto-save with debouncing
  /// Cancels previous save attempts and schedules a new one
  void scheduleSave(Future<void> Function() saveFunction) {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Update status to pending
    _updateStatus(SaveStatus.pending);

    // Schedule new save
    _debounceTimer = Timer(debounceDuration, () async {
      await _executeSave(saveFunction);
    });
  }

  /// Execute the save operation
  Future<void> _executeSave(Future<void> Function() saveFunction) async {
    if (_isSaving) return; // Prevent concurrent saves

    _isSaving = true;
    _updateStatus(SaveStatus.saving);

    try {
      await saveFunction();
      _updateStatus(SaveStatus.saved);

      // Reset to idle after showing "saved" for a brief moment
      Timer(const Duration(milliseconds: 1500), () {
        if (_status == SaveStatus.saved) {
          _updateStatus(SaveStatus.idle);
        }
      });
    } catch (error) {
      _updateStatus(SaveStatus.error);
      if (kDebugMode) {
        print('Auto-save error: $error');
      }

      // Reset to idle after showing error
      Timer(const Duration(seconds: 3), () {
        if (_status == SaveStatus.error) {
          _updateStatus(SaveStatus.idle);
        }
      });

      rethrow; // Re-throw to allow caller to handle
    } finally {
      _isSaving = false;
    }
  }

  /// Save immediately without debouncing
  Future<void> saveImmediately(Future<void> Function() saveFunction) async {
    _debounceTimer?.cancel();
    await _executeSave(saveFunction);
  }

  /// Cancel any pending save
  void cancel() {
    _debounceTimer?.cancel();
    _updateStatus(SaveStatus.idle);
  }

  /// Dispose the service
  void dispose() {
    _debounceTimer?.cancel();
    _statusListeners.clear();
  }
}

/// Save status enum
enum SaveStatus {
  idle,     // Not saving, no pending saves
  pending,  // Save scheduled but not yet executing
  saving,   // Currently saving
  saved,    // Successfully saved
  error,    // Save failed
}

/// Extension for user-friendly status messages
extension SaveStatusExtension on SaveStatus {
  String get message {
    switch (this) {
      case SaveStatus.idle:
        return '';
      case SaveStatus.pending:
        return 'Changes pending...';
      case SaveStatus.saving:
        return 'Saving...';
      case SaveStatus.saved:
        return 'Saved';
      case SaveStatus.error:
        return 'Failed to save';
    }
  }

  bool get showIndicator {
    return this != SaveStatus.idle;
  }
}
