import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sembast/sembast.dart';
import 'package:tutor_zone/core/debug_log/logger.dart';
import 'package:tutor_zone/core/local_storage/sembast_db.dart';
import 'package:tutor_zone/features/balance/models/data/balance_change.dart';

part 'balance_change_local_data_source.g.dart';

/// Local data source for BalanceChange CRUD operations using Sembast.
@riverpod
BalanceChangeLocalDataSource balanceChangeLocalDataSource(Ref ref) {
  final db = ref.watch(sembastDatabaseProvider).requireValue;
  return BalanceChangeLocalDataSource(db);
}

/// Provides CRUD operations for balance changes in Sembast database.
class BalanceChangeLocalDataSource {
  final Database _db;

  /// Creates a new [BalanceChangeLocalDataSource] with the given database.
  BalanceChangeLocalDataSource(this._db);

  /// Create a new balance change
  Future<BalanceChange> create(BalanceChange balanceChange) async {
    try {
      logInfo('Creating balance change: ${balanceChange.id} for student ${balanceChange.studentId}');
      await balanceChangesStore.record(balanceChange.id).put(_db, balanceChange.toJson());
      return balanceChange;
    } catch (e, stack) {
      logError('Failed to create balance change', e, stack);
      rethrow;
    }
  }

  /// Get balance change by ID
  Future<BalanceChange?> getById(String id) async {
    try {
      final json = await balanceChangesStore.record(id).get(_db);
      if (json == null) return null;
      return BalanceChange.fromJson(json);
    } catch (e, stack) {
      logError('Failed to get balance change by ID: $id', e, stack);
      rethrow;
    }
  }

  /// Get all balance changes
  Future<List<BalanceChange>> getAll() async {
    try {
      final records = await balanceChangesStore.find(_db);
      return records.map((record) => BalanceChange.fromJson(record.value)).toList();
    } catch (e, stack) {
      logError('Failed to get all balance changes', e, stack);
      rethrow;
    }
  }

  /// Get balance changes by student ID (sorted by timestamp, most recent first)
  Future<List<BalanceChange>> getByStudentId(String studentId) async {
    try {
      final finder = Finder(
        filter: Filter.equals('studentId', studentId),
        sortOrders: [SortOrder('createdAt', false)], // Descending (most recent first)
      );
      final records = await balanceChangesStore.find(_db, finder: finder);
      return records.map((record) => BalanceChange.fromJson(record.value)).toList();
    } catch (e, stack) {
      logError('Failed to get balance changes for student: $studentId', e, stack);
      rethrow;
    }
  }

  /// Get balance changes by student ID (sorted ascending for running balance calculation)
  Future<List<BalanceChange>> getByStudentIdAscending(String studentId) async {
    try {
      final finder = Finder(
        filter: Filter.equals('studentId', studentId),
        sortOrders: [SortOrder('createdAt')], // Ascending (oldest first)
      );
      final records = await balanceChangesStore.find(_db, finder: finder);
      return records.map((record) => BalanceChange.fromJson(record.value)).toList();
    } catch (e, stack) {
      logError('Failed to get balance changes (ascending) for student: $studentId', e, stack);
      rethrow;
    }
  }

  /// Get total balance changes amount for a student
  Future<int> getTotalAmountByStudentId(String studentId) async {
    try {
      final balanceChanges = await getByStudentId(studentId);
      return balanceChanges.fold<int>(
        0,
        (sum, change) => sum + change.amountCents,
      );
    } catch (e, stack) {
      logError('Failed to get total balance changes for student: $studentId', e, stack);
      rethrow;
    }
  }

  /// Delete a balance change by ID
  Future<void> delete(String id) async {
    try {
      logInfo('Deleting balance change: $id');
      await balanceChangesStore.record(id).delete(_db);
    } catch (e, stack) {
      logError('Failed to delete balance change', e, stack);
      rethrow;
    }
  }

  /// Delete all balance changes for a student (for cascade deletion)
  Future<void> deleteByStudentId(String studentId) async {
    try {
      logInfo('Deleting all balance changes for student: $studentId');
      final finder = Finder(filter: Filter.equals('studentId', studentId));
      await balanceChangesStore.delete(_db, finder: finder);
    } catch (e, stack) {
      logError('Failed to delete balance changes for student: $studentId', e, stack);
      rethrow;
    }
  }

  /// Check if balance change exists
  Future<bool> exists(String id) async {
    try {
      return await balanceChangesStore.record(id).exists(_db);
    } catch (e, stack) {
      logError('Failed to check if balance change exists: $id', e, stack);
      rethrow;
    }
  }

  /// Get count of all balance changes
  Future<int> count() async {
    try {
      return await balanceChangesStore.count(_db);
    } catch (e, stack) {
      logError('Failed to count balance changes', e, stack);
      rethrow;
    }
  }

  /// Get count of balance changes for a student
  Future<int> countByStudentId(String studentId) async {
    try {
      return await balanceChangesStore.count(_db, filter: Filter.equals('studentId', studentId));
    } catch (e, stack) {
      logError('Failed to count balance changes for student: $studentId', e, stack);
      rethrow;
    }
  }

  /// Stream of all balance changes (sorted by timestamp, most recent first)
  Stream<List<BalanceChange>> watchAll() {
    final finder = Finder(sortOrders: [SortOrder('createdAt', false)]);
    return balanceChangesStore.query(finder: finder).onSnapshots(_db).map((snapshots) {
      return snapshots.map((snapshot) => BalanceChange.fromJson(snapshot.value)).toList();
    });
  }

  /// Stream of a single balance change by ID
  Stream<BalanceChange?> watchById(String id) {
    return balanceChangesStore.record(id).onSnapshot(_db).map((snapshot) {
      if (snapshot == null) return null;
      return BalanceChange.fromJson(snapshot.value);
    });
  }

  /// Stream of balance changes for a specific student
  Stream<List<BalanceChange>> watchByStudentId(String studentId) {
    final finder = Finder(
      filter: Filter.equals('studentId', studentId),
      sortOrders: [SortOrder('createdAt', false)],
    );
    return balanceChangesStore.query(finder: finder).onSnapshots(_db).map((snapshots) {
      return snapshots.map((snapshot) => BalanceChange.fromJson(snapshot.value)).toList();
    });
  }

  /// Delete all balance changes (for testing/QA)
  Future<void> deleteAll() async {
    try {
      logWarning('Deleting all balance changes');
      await balanceChangesStore.delete(_db);
    } catch (e, stack) {
      logError('Failed to delete all balance changes', e, stack);
      rethrow;
    }
  }
}
