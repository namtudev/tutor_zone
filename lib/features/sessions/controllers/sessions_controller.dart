import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tutor_zone/core/debug_log/logger.dart';
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
/// 
/// Uses AsyncNotifier<void> pattern:
/// - State provides loading/error feedback for UI
/// - Methods return AsyncValue<void> for inline error handling
/// - Data comes from stream providers (no duplication)
@riverpod
class SessionsController extends _$SessionsController {
  late final SessionRepository _repository;

  @override
  AsyncValue<void> build() {
    _repository = ref.watch(sessionRepositoryProvider);
    return const AsyncData(null); // Idle state
  }

  /// Create a new session
  /// 
  /// Returns AsyncValue<void> for inline error handling in UI.
  Future<AsyncValue<void>> createSession({
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
    return state;
  }

  /// Update an existing session
  /// 
  /// Returns AsyncValue<void> for inline error handling in UI.
  Future<AsyncValue<void>> updateSession({
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
    });
    return state;
  }

  /// Delete a session
  /// 
  /// Returns AsyncValue<void> for inline error handling in UI.
  Future<AsyncValue<void>> deleteSession(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      logInfo('Deleting session: $id');
      await _repository.delete(id);
      logInfo('Session deleted successfully: $id');
    });
    return state;
  }

  /// Mark session as paid
  /// 
  /// Returns AsyncValue<void> for inline error handling in UI.
  Future<AsyncValue<void>> markSessionAsPaid(String id) async {
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
    return state;
  }

  /// Mark session as unpaid
  /// 
  /// Returns AsyncValue<void> for inline error handling in UI.
  Future<AsyncValue<void>> markSessionAsUnpaid(String id) async {
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
    return state;
  }

  /// Mark session as completed
  /// 
  /// Returns AsyncValue<void> for inline error handling in UI.
  Future<AsyncValue<void>> markSessionAsCompleted(String id) async {
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
    return state;
  }

  /// Mark session as skipped
  /// 
  /// Returns AsyncValue<void> for inline error handling in UI.
  Future<AsyncValue<void>> markSessionAsSkipped(String id) async {
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
    return state;
  }

  /// Delete all sessions for a student (for cascade deletion)
  /// 
  /// Returns AsyncValue<void> for inline error handling in UI.
  Future<AsyncValue<void>> deleteSessionsByStudentId(String studentId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      logInfo('Deleting all sessions for student: $studentId');
      await _repository.deleteByStudentId(studentId);
      logInfo('All sessions deleted for student: $studentId');
    });
    return state;
  }
}
