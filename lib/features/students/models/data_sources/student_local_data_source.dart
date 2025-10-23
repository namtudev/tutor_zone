import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sembast/sembast.dart';
import 'package:tutor_zone/core/debug_log/logger.dart';
import 'package:tutor_zone/core/local_storage/sembast_db.dart';
import 'package:tutor_zone/features/students/models/data/student.dart';

part 'student_local_data_source.g.dart';

/// Local data source for Student CRUD operations using Sembast.
@riverpod
StudentLocalDataSource studentLocalDataSource(Ref ref) {
  final db = ref.watch(sembastDatabaseProvider).requireValue;
  return StudentLocalDataSource(db);
}

/// Provides CRUD operations for students in Sembast database.
class StudentLocalDataSource {
  final Database _db;

  /// Creates a new [StudentLocalDataSource] with the given database.
  StudentLocalDataSource(this._db);

  /// Create a new student
  Future<Student> create(Student student) async {
    try {
      logInfo('Creating student: ${student.id}');
      await studentsStore.record(student.id).put(_db, student.toJson());
      return student;
    } catch (e, stack) {
      logError('Failed to create student', e, stack);
      rethrow;
    }
  }

  /// Get student by ID
  Future<Student?> getById(String id) async {
    try {
      final json = await studentsStore.record(id).get(_db);
      if (json == null) return null;
      return Student.fromJson(json);
    } catch (e, stack) {
      logError('Failed to get student by ID: $id', e, stack);
      rethrow;
    }
  }

  /// Get all students
  Future<List<Student>> getAll() async {
    try {
      final records = await studentsStore.find(_db);
      return records.map((record) => Student.fromJson(record.value)).toList();
    } catch (e, stack) {
      logError('Failed to get all students', e, stack);
      rethrow;
    }
  }

  /// Get all students sorted by name
  Future<List<Student>> getAllSorted() async {
    try {
      final finder = Finder(sortOrders: [SortOrder('name')]);
      final records = await studentsStore.find(_db, finder: finder);
      return records.map((record) => Student.fromJson(record.value)).toList();
    } catch (e, stack) {
      logError('Failed to get sorted students', e, stack);
      rethrow;
    }
  }

  /// Search students by name (case-insensitive)
  Future<List<Student>> searchByName(String query) async {
    try {
      if (query.isEmpty) return getAllSorted();

      final allStudents = await getAllSorted();
      final lowerQuery = query.toLowerCase();
      
      return allStudents.where((student) {
        return student.name.toLowerCase().contains(lowerQuery);
      }).toList();
    } catch (e, stack) {
      logError('Failed to search students by name: $query', e, stack);
      rethrow;
    }
  }

  /// Get students with negative balance
  Future<List<Student>> getStudentsWithNegativeBalance() async {
    try {
      final finder = Finder(
        filter: Filter.lessThan('balanceCents', 0),
        sortOrders: [SortOrder('balanceCents')], // Most negative first
      );
      final records = await studentsStore.find(_db, finder: finder);
      return records.map((record) => Student.fromJson(record.value)).toList();
    } catch (e, stack) {
      logError('Failed to get students with negative balance', e, stack);
      rethrow;
    }
  }

  /// Get students with positive balance
  Future<List<Student>> getStudentsWithPositiveBalance() async {
    try {
      final finder = Finder(
        filter: Filter.greaterThan('balanceCents', 0),
        sortOrders: [SortOrder('balanceCents', false)], // Highest first
      );
      final records = await studentsStore.find(_db, finder: finder);
      return records.map((record) => Student.fromJson(record.value)).toList();
    } catch (e, stack) {
      logError('Failed to get students with positive balance', e, stack);
      rethrow;
    }
  }

  /// Update an existing student
  Future<Student> update(Student student) async {
    try {
      logInfo('Updating student: ${student.id}');
      
      // Verify student exists
      final exists = await studentsStore.record(student.id).exists(_db);
      if (!exists) {
        throw Exception('Student not found: ${student.id}');
      }

      await studentsStore.record(student.id).put(_db, student.toJson());
      return student;
    } catch (e, stack) {
      logError('Failed to update student', e, stack);
      rethrow;
    }
  }

  /// Update student balance (for allocation engine)
  Future<void> updateBalance(String studentId, int newBalanceCents) async {
    try {
      logInfo('Updating balance for student $studentId: $newBalanceCents cents');
      
      await studentsStore.record(studentId).update(_db, {
        'balanceCents': newBalanceCents,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e, stack) {
      logError('Failed to update student balance', e, stack);
      rethrow;
    }
  }

  /// Delete a student by ID
  /// Note: Caller should handle cascade deletion of related records
  Future<void> delete(String id) async {
    try {
      logInfo('Deleting student: $id');
      await studentsStore.record(id).delete(_db);
    } catch (e, stack) {
      logError('Failed to delete student', e, stack);
      rethrow;
    }
  }

  /// Check if student exists
  Future<bool> exists(String id) async {
    try {
      return await studentsStore.record(id).exists(_db);
    } catch (e, stack) {
      logError('Failed to check if student exists: $id', e, stack);
      rethrow;
    }
  }

  /// Get count of all students
  Future<int> count() async {
    try {
      return await studentsStore.count(_db);
    } catch (e, stack) {
      logError('Failed to count students', e, stack);
      rethrow;
    }
  }

  /// Stream of all students (sorted by name)
  Stream<List<Student>> watchAll() {
    final finder = Finder(sortOrders: [SortOrder('name')]);
    return studentsStore.query(finder: finder).onSnapshots(_db).map((snapshots) {
      return snapshots.map((snapshot) => Student.fromJson(snapshot.value)).toList();
    });
  }

  /// Stream of a single student by ID
  Stream<Student?> watchById(String id) {
    return studentsStore.record(id).onSnapshot(_db).map((snapshot) {
      if (snapshot == null) return null;
      return Student.fromJson(snapshot.value);
    });
  }

  /// Stream of students with negative balance
  Stream<List<Student>> watchStudentsWithNegativeBalance() {
    final finder = Finder(
      filter: Filter.lessThan('balanceCents', 0),
      sortOrders: [SortOrder('balanceCents')],
    );
    return studentsStore.query(finder: finder).onSnapshots(_db).map((snapshots) {
      return snapshots.map((snapshot) => Student.fromJson(snapshot.value)).toList();
    });
  }

  /// Delete all students (for testing/QA)
  Future<void> deleteAll() async {
    try {
      logWarning('Deleting all students');
      await studentsStore.delete(_db);
    } catch (e, stack) {
      logError('Failed to delete all students', e, stack);
      rethrow;
    }
  }
}

