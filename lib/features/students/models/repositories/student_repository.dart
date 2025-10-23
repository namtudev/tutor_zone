import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tutor_zone/features/students/models/data/student.dart';
import 'package:tutor_zone/features/students/models/data_sources/student_local_data_source.dart';

part 'student_repository.g.dart';

/// Provider for StudentRepository based on access mode
@riverpod
StudentRepository studentRepository(Ref ref) {
  // TODO: Check app access mode (local vs cloud) from settings
  // For Phase 1, always use local repository
  final localDataSource = ref.watch(studentLocalDataSourceProvider);
  return StudentRepositoryLocal(localDataSource);
}

/// Abstract repository interface for student operations.
/// 
/// Provides a consistent API regardless of data source (local Sembast or cloud Firestore).
abstract class StudentRepository {
  /// Create a new student
  Future<Student> create(Student student);

  /// Get student by ID
  Future<Student?> getById(String id);

  /// Get all students
  Future<List<Student>> getAll();

  /// Get all students sorted by name
  Future<List<Student>> getAllSorted();

  /// Search students by name
  Future<List<Student>> searchByName(String query);

  /// Get students with negative balance (owe money)
  Future<List<Student>> getStudentsWithNegativeBalance();

  /// Get students with positive balance (prepaid credit)
  Future<List<Student>> getStudentsWithPositiveBalance();

  /// Update an existing student
  Future<Student> update(Student student);

  /// Update student balance (used by allocation engine)
  Future<void> updateBalance(String studentId, int newBalanceCents);

  /// Delete a student by ID
  /// Note: Should cascade delete related sessions, balance changes, and schedules
  Future<void> delete(String id);

  /// Check if student exists
  Future<bool> exists(String id);

  /// Get count of all students
  Future<int> count();

  /// Stream of all students (sorted by name)
  Stream<List<Student>> watchAll();

  /// Stream of a single student by ID
  Stream<Student?> watchById(String id);

  /// Stream of students with negative balance
  Stream<List<Student>> watchStudentsWithNegativeBalance();
}

/// Local implementation using Sembast
class StudentRepositoryLocal implements StudentRepository {
  final StudentLocalDataSource _dataSource;

  /// Creates a new [StudentRepositoryLocal] with the given data source.
  StudentRepositoryLocal(this._dataSource);

  @override
  Future<Student> create(Student student) => _dataSource.create(student);

  @override
  Future<Student?> getById(String id) => _dataSource.getById(id);

  @override
  Future<List<Student>> getAll() => _dataSource.getAll();

  @override
  Future<List<Student>> getAllSorted() => _dataSource.getAllSorted();

  @override
  Future<List<Student>> searchByName(String query) => _dataSource.searchByName(query);

  @override
  Future<List<Student>> getStudentsWithNegativeBalance() => 
      _dataSource.getStudentsWithNegativeBalance();

  @override
  Future<List<Student>> getStudentsWithPositiveBalance() => 
      _dataSource.getStudentsWithPositiveBalance();

  @override
  Future<Student> update(Student student) => _dataSource.update(student);

  @override
  Future<void> updateBalance(String studentId, int newBalanceCents) => 
      _dataSource.updateBalance(studentId, newBalanceCents);

  @override
  Future<void> delete(String id) async {
    // TODO: Implement cascade deletion of related records
    // For now, just delete the student
    // In Phase 2, add deletion of:
    // - sessions (sessionsStore)
    // - balance_changes (balanceChangesStore)
    // - recurring_schedules (recurringSchedulesStore)
    await _dataSource.delete(id);
  }

  @override
  Future<bool> exists(String id) => _dataSource.exists(id);

  @override
  Future<int> count() => _dataSource.count();

  @override
  Stream<List<Student>> watchAll() => _dataSource.watchAll();

  @override
  Stream<Student?> watchById(String id) => _dataSource.watchById(id);

  @override
  Stream<List<Student>> watchStudentsWithNegativeBalance() => 
      _dataSource.watchStudentsWithNegativeBalance();
}

/// Cloud implementation using Firestore (Phase 2)
class StudentRepositoryCloud implements StudentRepository {
  @override
  Future<Student> create(Student student) {
    throw UnimplementedError('Cloud mode not implemented in Phase 1');
  }

  @override
  Future<Student?> getById(String id) {
    throw UnimplementedError('Cloud mode not implemented in Phase 1');
  }

  @override
  Future<List<Student>> getAll() {
    throw UnimplementedError('Cloud mode not implemented in Phase 1');
  }

  @override
  Future<List<Student>> getAllSorted() {
    throw UnimplementedError('Cloud mode not implemented in Phase 1');
  }

  @override
  Future<List<Student>> searchByName(String query) {
    throw UnimplementedError('Cloud mode not implemented in Phase 1');
  }

  @override
  Future<List<Student>> getStudentsWithNegativeBalance() {
    throw UnimplementedError('Cloud mode not implemented in Phase 1');
  }

  @override
  Future<List<Student>> getStudentsWithPositiveBalance() {
    throw UnimplementedError('Cloud mode not implemented in Phase 1');
  }

  @override
  Future<Student> update(Student student) {
    throw UnimplementedError('Cloud mode not implemented in Phase 1');
  }

  @override
  Future<void> updateBalance(String studentId, int newBalanceCents) {
    throw UnimplementedError('Cloud mode not implemented in Phase 1');
  }

  @override
  Future<void> delete(String id) {
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
  Stream<List<Student>> watchAll() {
    throw UnimplementedError('Cloud mode not implemented in Phase 1');
  }

  @override
  Stream<Student?> watchById(String id) {
    throw UnimplementedError('Cloud mode not implemented in Phase 1');
  }

  @override
  Stream<List<Student>> watchStudentsWithNegativeBalance() {
    throw UnimplementedError('Cloud mode not implemented in Phase 1');
  }
}

