import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tutor_zone/features/sessions/models/data/session.dart';
import 'package:tutor_zone/features/sessions/models/data_sources/session_local_data_source.dart';

part 'session_repository.g.dart';

/// Provider for SessionRepository (local implementation)
@riverpod
SessionRepository sessionRepository(Ref ref) {
  final dataSource = ref.watch(sessionLocalDataSourceProvider);
  return SessionRepositoryLocal(dataSource);
}

/// Repository interface for Session operations.
///
/// Abstracts data source implementation (local Sembast vs. cloud Firestore).
abstract class SessionRepository {
  /// Create a new session
  Future<Session> create(Session session);

  /// Get session by ID
  Future<Session?> getById(String id);

  /// Get all sessions
  Future<List<Session>> getAll();

  /// Get sessions by student ID (sorted by start time, most recent first)
  Future<List<Session>> getByStudentId(String studentId);

  /// Get upcoming sessions (start >= now, sorted ascending)
  Future<List<Session>> getUpcomingSessions();

  /// Get past sessions (end < now, sorted descending)
  Future<List<Session>> getPastSessions();

  /// Get unpaid sessions
  Future<List<Session>> getUnpaidSessions();

  /// Get unpaid sessions for a specific student
  Future<List<Session>> getUnpaidSessionsByStudentId(String studentId);

  /// Get sessions in date range (for calendar view)
  Future<List<Session>> getSessionsInRange({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Update an existing session
  Future<Session> update(Session session);

  /// Update session payment status (used by allocation engine)
  Future<void> updatePayStatus(String sessionId, String payStatus);

  /// Delete a session by ID
  Future<void> delete(String id);

  /// Delete all sessions for a student (for cascade deletion)
  Future<void> deleteByStudentId(String studentId);

  /// Check if session exists
  Future<bool> exists(String id);

  /// Get count of all sessions
  Future<int> count();

  /// Get count of sessions for a student
  Future<int> countByStudentId(String studentId);

  /// Stream of all sessions (sorted by start time, most recent first)
  Stream<List<Session>> watchAll();

  /// Stream of a single session by ID
  Stream<Session?> watchById(String id);

  /// Stream of sessions for a specific student
  Stream<List<Session>> watchByStudentId(String studentId);

  /// Stream of upcoming sessions
  Stream<List<Session>> watchUpcomingSessions();

  /// Stream of unpaid sessions
  Stream<List<Session>> watchUnpaidSessions();
}

/// Local implementation using Sembast
class SessionRepositoryLocal implements SessionRepository {
  final SessionLocalDataSource _dataSource;

  /// Creates a new [SessionRepositoryLocal] with the given data source.
  SessionRepositoryLocal(this._dataSource);

  @override
  Future<Session> create(Session session) => _dataSource.create(session);

  @override
  Future<Session?> getById(String id) => _dataSource.getById(id);

  @override
  Future<List<Session>> getAll() => _dataSource.getAll();

  @override
  Future<List<Session>> getByStudentId(String studentId) => _dataSource.getByStudentId(studentId);

  @override
  Future<List<Session>> getUpcomingSessions() => _dataSource.getUpcomingSessions();

  @override
  Future<List<Session>> getPastSessions() => _dataSource.getPastSessions();

  @override
  Future<List<Session>> getUnpaidSessions() => _dataSource.getUnpaidSessions();

  @override
  Future<List<Session>> getUnpaidSessionsByStudentId(String studentId) => _dataSource.getUnpaidSessionsByStudentId(studentId);

  @override
  Future<List<Session>> getSessionsInRange({
    required DateTime startDate,
    required DateTime endDate,
  }) => _dataSource.getSessionsInRange(
    startDate: startDate,
    endDate: endDate,
  );

  @override
  Future<Session> update(Session session) => _dataSource.update(session);

  @override
  Future<void> updatePayStatus(String sessionId, String payStatus) => _dataSource.updatePayStatus(sessionId, payStatus);

  @override
  Future<void> delete(String id) => _dataSource.delete(id);

  @override
  Future<void> deleteByStudentId(String studentId) => _dataSource.deleteByStudentId(studentId);

  @override
  Future<bool> exists(String id) => _dataSource.exists(id);

  @override
  Future<int> count() => _dataSource.count();

  @override
  Future<int> countByStudentId(String studentId) => _dataSource.countByStudentId(studentId);

  @override
  Stream<List<Session>> watchAll() => _dataSource.watchAll();

  @override
  Stream<Session?> watchById(String id) => _dataSource.watchById(id);

  @override
  Stream<List<Session>> watchByStudentId(String studentId) => _dataSource.watchByStudentId(studentId);

  @override
  Stream<List<Session>> watchUpcomingSessions() => _dataSource.watchUpcomingSessions();

  @override
  Stream<List<Session>> watchUnpaidSessions() => _dataSource.watchUnpaidSessions();
}
