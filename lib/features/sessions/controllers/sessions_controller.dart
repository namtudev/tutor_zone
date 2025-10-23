import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tutor_zone/core/debug_log/logger.dart';
import 'package:tutor_zone/features/balance/domain/allocation_service.dart';
import 'package:tutor_zone/features/sessions/models/data/session.dart';
import 'package:tutor_zone/features/sessions/models/repositories/session_repository.dart';
import 'package:uuid/uuid.dart';

part 'sessions_controller.g.dart';

const _uuid = Uuid();

/// Stream provider for all sessions
@riverpod
Stream<List<Session>> sessionsStream(Ref ref) {
  final repository = ref.watch(sessionRepositoryProvider);
  return repository.watchAll();
}

/// Stream provider for a single session by ID
@riverpod
Stream<Session?> sessionStream(Ref ref, String sessionId) {
  final repository = ref.watch(sessionRepositoryProvider);
  return repository.watchById(sessionId);
}

/// Stream provider for sessions by student ID
@riverpod
Stream<List<Session>> sessionsByStudentStream(Ref ref, String studentId) {
  final repository = ref.watch(sessionRepositoryProvider);
  return repository.watchByStudentId(studentId);
}

/// Stream provider for upcoming sessions
@riverpod
Stream<List<Session>> upcomingSessionsStream(Ref ref) {
  final repository = ref.watch(sessionRepositoryProvider);
  return repository.watchUpcomingSessions();
}

/// Stream provider for unpaid sessions
@riverpod
Stream<List<Session>> unpaidSessionsStream(Ref ref) {
  final repository = ref.watch(sessionRepositoryProvider);
  return repository.watchUnpaidSessions();
}

/// Controller for session CRUD operations with UI-bindable state.
@riverpod
class SessionsController extends _$SessionsController {
  SessionRepository get _repository => ref.read(sessionRepositoryProvider);

  @override
  Future<void> build() async {}

  /// Create a new session
  Future<void> createSession({
    required String studentId,
    required DateTime start,
    required DateTime end,
    required int rateSnapshotCents,
    SessionAttendance attendance = SessionAttendance.completed,
    PaymentStatus payStatus = PaymentStatus.unpaid,
    String? notes,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final session = Session.create(
        id: _uuid.v4(),
        studentId: studentId,
        start: start,
        end: end,
        rateSnapshotCents: rateSnapshotCents,
        attendance: attendance,
        payStatus: payStatus,
      );

      logInfo('Creating session: ${session.id} for student $studentId');
      await _repository.create(session);
      logInfo('Session created successfully: ${session.id}');
    });
  }

  /// Update an existing session
  Future<void> updateSession({
    required String id,
    required String studentId,
    required DateTime start,
    required DateTime end,
    required int rateSnapshotCents,
    SessionAttendance? attendance,
    PaymentStatus? payStatus,
    String? notes,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      logInfo('Updating session: $id');

      // Get existing session
      final existing = await _repository.getById(id);
      if (existing == null) {
        throw Exception('Session not found: $id');
      }

      // Update with new values
      final updated = existing.update(
        start: start,
        end: end,
        rateSnapshotCents: rateSnapshotCents,
        attendance: attendance,
        payStatus: payStatus,
      );

      await _repository.update(updated);
      logInfo('Session updated successfully: $id');

      // Trigger allocation check if amount changed (due to time or rate change)
      final amountChanged = start.toIso8601String() != existing.start ||
          end.toIso8601String() != existing.end ||
          rateSnapshotCents != existing.rateSnapshotCents;

      if (amountChanged) {
        final allocationService = ref.read(allocationServiceProvider);
        final allocated = await allocationService.runAllocationAfterSessionSave(existing.studentId);
        if (allocated) {
          logInfo('Auto-allocation performed for student ${existing.studentId}');
        }
      }
    });
  }

  /// Delete a session
  Future<void> deleteSession(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      logInfo('Deleting session: $id');
      await _repository.delete(id);
      logInfo('Session deleted successfully: $id');
    });
  }

  /// Mark session as paid
  Future<void> markSessionAsPaid(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      logInfo('Marking session as paid: $id');

      final session = await _repository.getById(id);
      if (session == null) {
        throw Exception('Session not found: $id');
      }

      final updated = session.markAsPaid();
      await _repository.update(updated);
      logInfo('Session marked as paid: $id');
    });
  }

  /// Mark session as unpaid
  Future<void> markSessionAsUnpaid(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      logInfo('Marking session as unpaid: $id');

      final session = await _repository.getById(id);
      if (session == null) {
        throw Exception('Session not found: $id');
      }

      final updated = session.markAsUnpaid();
      await _repository.update(updated);
      logInfo('Session marked as unpaid: $id');
    });
  }

  /// Mark session as completed
  Future<void> markSessionAsCompleted(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      logInfo('Marking session as completed: $id');

      final session = await _repository.getById(id);
      if (session == null) {
        throw Exception('Session not found: $id');
      }

      final updated = session.markAsCompleted();
      await _repository.update(updated);
      logInfo('Session marked as completed: $id');
    });
  }

  /// Mark session as skipped
  Future<void> markSessionAsSkipped(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      logInfo('Marking session as skipped: $id');

      final session = await _repository.getById(id);
      if (session == null) {
        throw Exception('Session not found: $id');
      }

      final updated = session.markAsSkipped();
      await _repository.update(updated);
      logInfo('Session marked as skipped: $id');
    });
  }

  /// Delete all sessions for a student (for cascade deletion)
  Future<void> deleteSessionsByStudentId(String studentId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      logInfo('Deleting all sessions for student: $studentId');
      await _repository.deleteByStudentId(studentId);
      logInfo('All sessions deleted for student: $studentId');
    });
  }
}
