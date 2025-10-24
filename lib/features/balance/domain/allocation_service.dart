import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sembast/sembast.dart';
import 'package:tutor_zone/core/debug_log/logger.dart';
import 'package:tutor_zone/core/local_storage/sembast_db.dart';
import 'package:tutor_zone/features/sessions/models/data/session.dart';
import 'package:tutor_zone/features/sessions/models/data_sources/session_local_data_source.dart';
import 'package:tutor_zone/features/students/models/data/student.dart';
import 'package:tutor_zone/features/students/models/data_sources/student_local_data_source.dart';

part 'allocation_service.g.dart';

/// Service for FIFO exact-match credit allocation.
@riverpod
AllocationService allocationService(Ref ref) {
  final db = ref.watch(sembastDatabaseProvider).requireValue;
  final studentDataSource = ref.watch(studentLocalDataSourceProvider);
  final sessionDataSource = ref.watch(sessionLocalDataSourceProvider);
  return AllocationService(db, studentDataSource, sessionDataSource);
}

/// Provides FIFO exact-match allocation logic.
///
/// **Allocation Rule:**
/// - If a future unpaid session's amount exactly equals current balance,
///   mark that session as paid and reduce balance to 0.
/// - If not an exact match, do NOT split; leave as balance until an exact match occurs.
///
/// **Trigger Points:**
/// - On balance change (payment/adjustment)
/// - On session save (when amount changes)
/// - On recurrence generation (when new sessions are created)
class AllocationService {
  final Database _db;
  final StudentLocalDataSource _studentDataSource;
  final SessionLocalDataSource _sessionDataSource;

  /// Creates a new [AllocationService] with the given dependencies.
  AllocationService(this._db, this._studentDataSource, this._sessionDataSource);

  /// Run allocation check for a specific student.
  ///
  /// Checks if the student's current balance exactly matches the next unpaid session.
  /// If yes, marks the session as paid and reduces balance to 0.
  ///
  /// Returns true if allocation was performed, false otherwise.
  Future<bool> runAllocation(String studentId) async {
    try {
      logInfo('Running allocation check for student: $studentId');

      // Get student
      final student = await _studentDataSource.getById(studentId);
      if (student == null) {
        logWarning('Student not found: $studentId');
        return false;
      }

      // Check if student has positive balance
      if (student.balanceCents <= 0) {
        logDebug('Student $studentId has no positive balance (${student.balanceCents} cents)');
        return false;
      }

      // Get next unpaid session (FIFO - oldest first)
      final unpaidSessions = await _sessionDataSource.getUnpaidSessionsByStudentId(studentId);
      if (unpaidSessions.isEmpty) {
        logDebug('No unpaid sessions for student $studentId');
        return false;
      }

      // Sort by start time (ascending - oldest first for FIFO)
      unpaidSessions.sort((a, b) => a.start.compareTo(b.start));
      final nextUnpaidSession = unpaidSessions.first;

      // Check for exact match
      if (student.balanceCents == nextUnpaidSession.amountCents) {
        logInfo('Exact match found! Balance: ${student.balanceCents}, Session amount: ${nextUnpaidSession.amountCents}');

        // Perform allocation atomically
        await _performAllocation(student, nextUnpaidSession);
        return true;
      } else {
        logDebug('No exact match. Balance: ${student.balanceCents}, Next session: ${nextUnpaidSession.amountCents}');
        return false;
      }
    } catch (e, stack) {
      logError('Failed to run allocation for student $studentId', e, stack);
      rethrow;
    }
  }

  /// Perform allocation atomically using Sembast transaction.
  ///
  /// Updates both student balance and session payStatus together.
  Future<void> _performAllocation(Student student, Session session) async {
    try {
      logInfo('Performing allocation: Student ${student.id}, Session ${session.id}');

      await _db.transaction((txn) async {
        // Update student balance to 0
        final updatedStudent = student.copyWith(
          balanceCents: 0,
          updatedAt: DateTime.now().toIso8601String(),
        );
        await studentsStore.record(student.id).put(txn, updatedStudent.toJson());

        // Mark session as paid
        final updatedSession = session.markAsPaid();
        await sessionsStore.record(session.id).put(txn, updatedSession.toJson());

        logInfo('Allocation completed: Balance ${student.balanceCents} → 0, Session ${session.id} → paid');
      });
    } catch (e, stack) {
      logError('Failed to perform allocation', e, stack);
      rethrow;
    }
  }

  /// Run allocation check after a balance change.
  ///
  /// This is triggered when a payment or adjustment is recorded.
  Future<bool> runAllocationAfterBalanceChange(String studentId) async {
    try {
      logInfo('Running allocation after balance change for student: $studentId');
      return await runAllocation(studentId);
    } catch (e, stack) {
      logError('Failed to run allocation after balance change', e, stack);
      rethrow;
    }
  }

  /// Run allocation check after a session is saved.
  ///
  /// This is triggered when a session's amount changes (e.g., time or rate edited).
  Future<bool> runAllocationAfterSessionSave(String studentId) async {
    try {
      logInfo('Running allocation after session save for student: $studentId');
      return await runAllocation(studentId);
    } catch (e, stack) {
      logError('Failed to run allocation after session save', e, stack);
      rethrow;
    }
  }

  /// Run allocation check after recurrence generation.
  ///
  /// This is triggered when new sessions are generated from recurring schedules.
  /// Checks if any newly generated sessions can be auto-paid.
  Future<int> runAllocationAfterGeneration(String studentId) async {
    try {
      logInfo('Running allocation after generation for student: $studentId');

      var allocatedCount = 0;

      // Keep running allocation until no more exact matches
      while (await runAllocation(studentId)) {
        allocatedCount++;
      }

      if (allocatedCount > 0) {
        logInfo('Allocated $allocatedCount sessions for student $studentId after generation');
      }

      return allocatedCount;
    } catch (e, stack) {
      logError('Failed to run allocation after generation', e, stack);
      rethrow;
    }
  }

  /// Check if allocation would occur for a given balance and student.
  ///
  /// This is a read-only check that doesn't perform the allocation.
  /// Useful for UI previews or validation.
  Future<bool> wouldAllocate(String studentId, int balanceCents) async {
    try {
      // Get next unpaid session
      final unpaidSessions = await _sessionDataSource.getUnpaidSessionsByStudentId(studentId);
      if (unpaidSessions.isEmpty) {
        return false;
      }

      // Sort by start time (ascending - oldest first for FIFO)
      unpaidSessions.sort((a, b) => a.start.compareTo(b.start));
      final nextUnpaidSession = unpaidSessions.first;

      // Check for exact match
      return balanceCents == nextUnpaidSession.amountCents;
    } catch (e, stack) {
      logError('Failed to check if allocation would occur', e, stack);
      rethrow;
    }
  }

  /// Get the next unpaid session that would be allocated.
  ///
  /// Returns null if no unpaid sessions exist.
  Future<Session?> getNextAllocationTarget(String studentId) async {
    try {
      final unpaidSessions = await _sessionDataSource.getUnpaidSessionsByStudentId(studentId);
      if (unpaidSessions.isEmpty) {
        return null;
      }

      // Sort by start time (ascending - oldest first for FIFO)
      unpaidSessions.sort((a, b) => a.start.compareTo(b.start));
      return unpaidSessions.first;
    } catch (e, stack) {
      logError('Failed to get next allocation target', e, stack);
      rethrow;
    }
  }

  /// Run allocation for multiple students.
  ///
  /// Useful for batch operations or system-wide allocation checks.
  Future<Map<String, bool>> runAllocationForStudents(List<String> studentIds) async {
    try {
      logInfo('Running allocation for ${studentIds.length} students');

      final results = <String, bool>{};

      for (final studentId in studentIds) {
        final allocated = await runAllocation(studentId);
        results[studentId] = allocated;
      }

      final allocatedCount = results.values.where((v) => v).length;
      logInfo('Allocation completed for ${studentIds.length} students: $allocatedCount allocations performed');

      return results;
    } catch (e, stack) {
      logError('Failed to run allocation for multiple students', e, stack);
      rethrow;
    }
  }

  /// Run allocation for all students with positive balance.
  ///
  /// This is a system-wide allocation check.
  /// Useful for maintenance or fixing allocation state.
  Future<int> runAllocationForAllStudents() async {
    try {
      logInfo('Running allocation for all students');

      // Get all students
      final students = await _studentDataSource.getAll();

      // Filter students with positive balance
      final studentsWithBalance = students.where((s) => s.balanceCents > 0).toList();

      if (studentsWithBalance.isEmpty) {
        logInfo('No students with positive balance');
        return 0;
      }

      logInfo('Found ${studentsWithBalance.length} students with positive balance');

      var allocatedCount = 0;

      for (final student in studentsWithBalance) {
        if (await runAllocation(student.id)) {
          allocatedCount++;
        }
      }

      logInfo('System-wide allocation completed: $allocatedCount allocations performed');
      return allocatedCount;
    } catch (e, stack) {
      logError('Failed to run allocation for all students', e, stack);
      rethrow;
    }
  }
}
