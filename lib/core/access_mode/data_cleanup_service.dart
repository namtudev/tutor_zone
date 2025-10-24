import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tutor_zone/core/debug_log/logger.dart';
import 'package:tutor_zone/features/balance/models/data_sources/balance_change_local_data_source.dart';
import 'package:tutor_zone/features/sessions/models/data_sources/recurring_schedule_local_data_source.dart';
import 'package:tutor_zone/features/sessions/models/data_sources/session_local_data_source.dart';
import 'package:tutor_zone/features/students/models/data_sources/student_local_data_source.dart';

part 'data_cleanup_service.g.dart';

/// Service for cleaning up data when switching access modes
@riverpod
DataCleanupService dataCleanupService(Ref ref) {
  return DataCleanupService(ref);
}

/// Provides data cleanup functionality for mode switching.
///
/// Handles:
/// - Clearing Sembast database when switching to cloud mode
/// - Clearing Firebase cache when switching to local mode
class DataCleanupService {
  final Ref _ref;

  /// Creates a new [DataCleanupService]
  DataCleanupService(this._ref);

  /// Clear all local Sembast data
  ///
  /// This is called when switching from local mode to cloud mode.
  /// Deletes all data from all Sembast stores.
  Future<void> clearLocalData() async {
    try {
      logWarning('Clearing all local Sembast data');

      // Delete all data from each store
      final studentDataSource = _ref.read(studentLocalDataSourceProvider);
      final sessionDataSource = _ref.read(sessionLocalDataSourceProvider);
      final balanceChangeDataSource = _ref.read(balanceChangeLocalDataSourceProvider);
      final recurringScheduleDataSource = _ref.read(recurringScheduleLocalDataSourceProvider);

      await Future.wait([
        studentDataSource.deleteAll(),
        sessionDataSource.deleteAll(),
        balanceChangeDataSource.deleteAll(),
        recurringScheduleDataSource.deleteAll(),
      ]);

      logInfo('Local data cleared successfully');
    } catch (e, stack) {
      logError('Failed to clear local data', e, stack);
      rethrow;
    }
  }

  /// Clear Firebase cache and sign out
  ///
  /// This is called when switching from cloud mode to local mode.
  /// Signs out the user and clears any Firebase cached data.
  Future<void> clearCloudData() async {
    try {
      logWarning('Clearing Firebase cache and signing out');

      // Sign out from Firebase
      final firebaseAuth = FirebaseAuth.instance;
      if (firebaseAuth.currentUser != null) {
        await firebaseAuth.signOut();
        logInfo('Signed out from Firebase');
      }

      // Note: Firebase SDK automatically clears its cache on sign out
      // Additional cache clearing can be added here if needed

      logInfo('Cloud data cleared successfully');
    } catch (e, stack) {
      logError('Failed to clear cloud data', e, stack);
      rethrow;
    }
  }

  /// Clear all data (both local and cloud)
  ///
  /// This is a nuclear option that clears everything.
  /// Use with caution - typically only for testing or complete resets.
  Future<void> clearAllData() async {
    try {
      logWarning('Clearing ALL data (local and cloud)');

      await Future.wait([
        clearLocalData(),
        clearCloudData(),
      ]);

      logInfo('All data cleared successfully');
    } catch (e, stack) {
      logError('Failed to clear all data', e, stack);
      rethrow;
    }
  }
}

