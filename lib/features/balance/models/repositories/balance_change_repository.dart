import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tutor_zone/features/balance/models/data/balance_change.dart';
import 'package:tutor_zone/features/balance/models/data_sources/balance_change_local_data_source.dart';

part 'balance_change_repository.g.dart';

/// Balance change repository provider (local mode)
@riverpod
BalanceChangeRepository balanceChangeRepository(Ref ref) {
  final dataSource = ref.watch(balanceChangeLocalDataSourceProvider);
  return BalanceChangeRepositoryLocal(dataSource);
}

/// Abstract repository interface for balance change operations.
///
/// Provides a consistent API regardless of data source (local Sembast or cloud Firestore).
abstract class BalanceChangeRepository {
  /// Create a new balance change
  Future<BalanceChange> create(BalanceChange balanceChange);

  /// Get balance change by ID
  Future<BalanceChange?> getById(String id);

  /// Get all balance changes
  Future<List<BalanceChange>> getAll();

  /// Get balance changes by student ID (sorted by timestamp, most recent first)
  Future<List<BalanceChange>> getByStudentId(String studentId);

  /// Get balance changes by student ID (sorted ascending for running balance)
  Future<List<BalanceChange>> getByStudentIdAscending(String studentId);

  /// Get total balance changes amount for a student
  Future<int> getTotalAmountByStudentId(String studentId);

  /// Delete a balance change by ID
  Future<void> delete(String id);

  /// Delete all balance changes for a student (for cascade deletion)
  Future<void> deleteByStudentId(String studentId);

  /// Check if balance change exists
  Future<bool> exists(String id);

  /// Get count of all balance changes
  Future<int> count();

  /// Get count of balance changes for a student
  Future<int> countByStudentId(String studentId);

  /// Stream of all balance changes (sorted by timestamp, most recent first)
  Stream<List<BalanceChange>> watchAll();

  /// Stream of a single balance change by ID
  Stream<BalanceChange?> watchById(String id);

  /// Stream of balance changes for a specific student
  Stream<List<BalanceChange>> watchByStudentId(String studentId);
}

/// Local implementation using Sembast
class BalanceChangeRepositoryLocal implements BalanceChangeRepository {
  final BalanceChangeLocalDataSource _dataSource;

  /// Creates a new [BalanceChangeRepositoryLocal] with the given data source.
  BalanceChangeRepositoryLocal(this._dataSource);

  @override
  Future<BalanceChange> create(BalanceChange balanceChange) =>
      _dataSource.create(balanceChange);

  @override
  Future<BalanceChange?> getById(String id) => _dataSource.getById(id);

  @override
  Future<List<BalanceChange>> getAll() => _dataSource.getAll();

  @override
  Future<List<BalanceChange>> getByStudentId(String studentId) =>
      _dataSource.getByStudentId(studentId);

  @override
  Future<List<BalanceChange>> getByStudentIdAscending(String studentId) =>
      _dataSource.getByStudentIdAscending(studentId);

  @override
  Future<int> getTotalAmountByStudentId(String studentId) =>
      _dataSource.getTotalAmountByStudentId(studentId);

  @override
  Future<void> delete(String id) => _dataSource.delete(id);

  @override
  Future<void> deleteByStudentId(String studentId) =>
      _dataSource.deleteByStudentId(studentId);

  @override
  Future<bool> exists(String id) => _dataSource.exists(id);

  @override
  Future<int> count() => _dataSource.count();

  @override
  Future<int> countByStudentId(String studentId) =>
      _dataSource.countByStudentId(studentId);

  @override
  Stream<List<BalanceChange>> watchAll() => _dataSource.watchAll();

  @override
  Stream<BalanceChange?> watchById(String id) => _dataSource.watchById(id);

  @override
  Stream<List<BalanceChange>> watchByStudentId(String studentId) =>
      _dataSource.watchByStudentId(studentId);
}

/// Cloud implementation (Phase 2)
class BalanceChangeRepositoryCloud implements BalanceChangeRepository {
  @override
  Future<BalanceChange> create(BalanceChange balanceChange) {
    throw UnimplementedError('Cloud mode not implemented in Phase 1');
  }

  @override
  Future<BalanceChange?> getById(String id) {
    throw UnimplementedError('Cloud mode not implemented in Phase 1');
  }

  @override
  Future<List<BalanceChange>> getAll() {
    throw UnimplementedError('Cloud mode not implemented in Phase 1');
  }

  @override
  Future<List<BalanceChange>> getByStudentId(String studentId) {
    throw UnimplementedError('Cloud mode not implemented in Phase 1');
  }

  @override
  Future<List<BalanceChange>> getByStudentIdAscending(String studentId) {
    throw UnimplementedError('Cloud mode not implemented in Phase 1');
  }

  @override
  Future<int> getTotalAmountByStudentId(String studentId) {
    throw UnimplementedError('Cloud mode not implemented in Phase 1');
  }

  @override
  Future<void> delete(String id) {
    throw UnimplementedError('Cloud mode not implemented in Phase 1');
  }

  @override
  Future<void> deleteByStudentId(String studentId) {
    throw UnimplementedError('Cloud mode not implemented in Phase 1');
  }

  @override
  Future<bool> exists(String id) {
    throw UnimplementedError('Cloud mode not implemented in Phase 1');
  }

  @override
  Future<int> count() {
    throw UnimplementedError('Cloud mode not implemented in Phase 1');
  }

  @override
  Future<int> countByStudentId(String studentId) {
    throw UnimplementedError('Cloud mode not implemented in Phase 1');
  }

  @override
  Stream<List<BalanceChange>> watchAll() {
    throw UnimplementedError('Cloud mode not implemented in Phase 1');
  }

  @override
  Stream<BalanceChange?> watchById(String id) {
    throw UnimplementedError('Cloud mode not implemented in Phase 1');
  }

  @override
  Stream<List<BalanceChange>> watchByStudentId(String studentId) {
    throw UnimplementedError('Cloud mode not implemented in Phase 1');
  }
}

