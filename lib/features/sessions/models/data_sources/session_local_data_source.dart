import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sembast/sembast.dart';
import 'package:tutor_zone/core/debug_log/logger.dart';
import 'package:tutor_zone/core/local_storage/sembast_db.dart';
import 'package:tutor_zone/features/sessions/models/data/session.dart';

part 'session_local_data_source.g.dart';

/// Local data source for Session CRUD operations using Sembast.
@riverpod
SessionLocalDataSource sessionLocalDataSource(Ref ref) {
  final db = ref.watch(sembastDatabaseProvider).requireValue;
  return SessionLocalDataSource(db);
}

/// Provides CRUD operations for sessions in Sembast database.
class SessionLocalDataSource {
  final Database _db;

  SessionLocalDataSource(this._db);

  /// Create a new session
  Future<Session> create(Session session) async {
    try {
      logInfo('Creating session: ${session.id} for student ${session.studentId}');
      await sessionsStore.record(session.id).put(_db, session.toJson());
      return session;
    } catch (e, stack) {
      logError('Failed to create session', e, stack);
      rethrow;
    }
  }

  /// Get session by ID
  Future<Session?> getById(String id) async {
    try {
      final json = await sessionsStore.record(id).get(_db);
      if (json == null) return null;
      return Session.fromJson(json);
    } catch (e, stack) {
      logError('Failed to get session by ID: $id', e, stack);
      rethrow;
    }
  }

  /// Get all sessions
  Future<List<Session>> getAll() async {
    try {
      final records = await sessionsStore.find(_db);
      return records.map((record) => Session.fromJson(record.value)).toList();
    } catch (e, stack) {
      logError('Failed to get all sessions', e, stack);
      rethrow;
    }
  }

  /// Get sessions by student ID (sorted by start time, most recent first)
  Future<List<Session>> getByStudentId(String studentId) async {
    try {
      final finder = Finder(
        filter: Filter.equals('studentId', studentId),
        sortOrders: [SortOrder('start', false)], // Descending (most recent first)
      );
      final records = await sessionsStore.find(_db, finder: finder);
      return records.map((record) => Session.fromJson(record.value)).toList();
    } catch (e, stack) {
      logError('Failed to get sessions for student: $studentId', e, stack);
      rethrow;
    }
  }

  /// Get upcoming sessions (start >= now, sorted ascending)
  Future<List<Session>> getUpcomingSessions() async {
    try {
      final now = DateTime.now().toIso8601String();
      final finder = Finder(
        filter: Filter.greaterThanOrEquals('start', now),
        sortOrders: [SortOrder('start')], // Ascending (soonest first)
      );
      final records = await sessionsStore.find(_db, finder: finder);
      return records.map((record) => Session.fromJson(record.value)).toList();
    } catch (e, stack) {
      logError('Failed to get upcoming sessions', e, stack);
      rethrow;
    }
  }

  /// Get past sessions (end < now, sorted descending)
  Future<List<Session>> getPastSessions() async {
    try {
      final now = DateTime.now().toIso8601String();
      final finder = Finder(
        filter: Filter.lessThan('end', now),
        sortOrders: [SortOrder('start', false)], // Descending (most recent first)
      );
      final records = await sessionsStore.find(_db, finder: finder);
      return records.map((record) => Session.fromJson(record.value)).toList();
    } catch (e, stack) {
      logError('Failed to get past sessions', e, stack);
      rethrow;
    }
  }

  /// Get unpaid sessions
  Future<List<Session>> getUnpaidSessions() async {
    try {
      final finder = Finder(
        filter: Filter.equals('payStatus', 'unpaid'),
        sortOrders: [SortOrder('start', false)],
      );
      final records = await sessionsStore.find(_db, finder: finder);
      return records.map((record) => Session.fromJson(record.value)).toList();
    } catch (e, stack) {
      logError('Failed to get unpaid sessions', e, stack);
      rethrow;
    }
  }

  /// Get unpaid sessions for a specific student
  Future<List<Session>> getUnpaidSessionsByStudentId(String studentId) async {
    try {
      final finder = Finder(
        filter: Filter.and([
          Filter.equals('studentId', studentId),
          Filter.equals('payStatus', 'unpaid'),
        ]),
        sortOrders: [SortOrder('start', false)],
      );
      final records = await sessionsStore.find(_db, finder: finder);
      return records.map((record) => Session.fromJson(record.value)).toList();
    } catch (e, stack) {
      logError('Failed to get unpaid sessions for student: $studentId', e, stack);
      rethrow;
    }
  }

  /// Get sessions in date range (for calendar view)
  Future<List<Session>> getSessionsInRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final finder = Finder(
        filter: Filter.and([
          Filter.greaterThanOrEquals('start', startDate.toIso8601String()),
          Filter.lessThanOrEquals('start', endDate.toIso8601String()),
        ]),
        sortOrders: [SortOrder('start')],
      );
      final records = await sessionsStore.find(_db, finder: finder);
      return records.map((record) => Session.fromJson(record.value)).toList();
    } catch (e, stack) {
      logError('Failed to get sessions in range', e, stack);
      rethrow;
    }
  }

  /// Update an existing session
  Future<Session> update(Session session) async {
    try {
      logInfo('Updating session: ${session.id}');

      // Verify session exists
      final exists = await sessionsStore.record(session.id).exists(_db);
      if (!exists) {
        throw Exception('Session not found: ${session.id}');
      }

      await sessionsStore.record(session.id).put(_db, session.toJson());
      return session;
    } catch (e, stack) {
      logError('Failed to update session', e, stack);
      rethrow;
    }
  }

  /// Update session payment status
  Future<void> updatePayStatus(String sessionId, String payStatus) async {
    try {
      logInfo('Updating payment status for session $sessionId: $payStatus');

      await sessionsStore.record(sessionId).update(_db, {
        'payStatus': payStatus,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e, stack) {
      logError('Failed to update session payment status', e, stack);
      rethrow;
    }
  }

  /// Delete a session by ID
  Future<void> delete(String id) async {
    try {
      logInfo('Deleting session: $id');
      await sessionsStore.record(id).delete(_db);
    } catch (e, stack) {
      logError('Failed to delete session', e, stack);
      rethrow;
    }
  }

  /// Delete all sessions for a student (for cascade deletion)
  Future<void> deleteByStudentId(String studentId) async {
    try {
      logInfo('Deleting all sessions for student: $studentId');
      final finder = Finder(filter: Filter.equals('studentId', studentId));
      await sessionsStore.delete(_db, finder: finder);
    } catch (e, stack) {
      logError('Failed to delete sessions for student: $studentId', e, stack);
      rethrow;
    }
  }

  /// Check if session exists
  Future<bool> exists(String id) async {
    try {
      return await sessionsStore.record(id).exists(_db);
    } catch (e, stack) {
      logError('Failed to check if session exists: $id', e, stack);
      rethrow;
    }
  }

  /// Get count of all sessions
  Future<int> count() async {
    try {
      return await sessionsStore.count(_db);
    } catch (e, stack) {
      logError('Failed to count sessions', e, stack);
      rethrow;
    }
  }

  /// Get count of sessions for a student
  Future<int> countByStudentId(String studentId) async {
    try {
      return await sessionsStore.count(_db, filter: Filter.equals('studentId', studentId));
    } catch (e, stack) {
      logError('Failed to count sessions for student: $studentId', e, stack);
      rethrow;
    }
  }

  /// Stream of all sessions (sorted by start time, most recent first)
  Stream<List<Session>> watchAll() {
    final finder = Finder(sortOrders: [SortOrder('start', false)]);
    return sessionsStore.query(finder: finder).onSnapshots(_db).map((snapshots) {
      return snapshots.map((snapshot) => Session.fromJson(snapshot.value)).toList();
    });
  }

  /// Stream of a single session by ID
  Stream<Session?> watchById(String id) {
    return sessionsStore.record(id).onSnapshot(_db).map((snapshot) {
      if (snapshot == null) return null;
      return Session.fromJson(snapshot.value);
    });
  }

  /// Stream of sessions for a specific student
  Stream<List<Session>> watchByStudentId(String studentId) {
    final finder = Finder(
      filter: Filter.equals('studentId', studentId),
      sortOrders: [SortOrder('start', false)],
    );
    return sessionsStore.query(finder: finder).onSnapshots(_db).map((snapshots) {
      return snapshots.map((snapshot) => Session.fromJson(snapshot.value)).toList();
    });
  }

  /// Stream of upcoming sessions
  Stream<List<Session>> watchUpcomingSessions() {
    final now = DateTime.now().toIso8601String();
    final finder = Finder(
      filter: Filter.greaterThanOrEquals('start', now),
      sortOrders: [SortOrder('start')],
    );
    return sessionsStore.query(finder: finder).onSnapshots(_db).map((snapshots) {
      return snapshots.map((snapshot) => Session.fromJson(snapshot.value)).toList();
    });
  }

  /// Stream of unpaid sessions
  Stream<List<Session>> watchUnpaidSessions() {
    final finder = Finder(
      filter: Filter.equals('payStatus', 'unpaid'),
      sortOrders: [SortOrder('start', false)],
    );
    return sessionsStore.query(finder: finder).onSnapshots(_db).map((snapshots) {
      return snapshots.map((snapshot) => Session.fromJson(snapshot.value)).toList();
    });
  }

  /// Delete all sessions (for testing/QA)
  Future<void> deleteAll() async {
    try {
      logWarning('Deleting all sessions');
      await sessionsStore.delete(_db);
    } catch (e, stack) {
      logError('Failed to delete all sessions', e, stack);
      rethrow;
    }
  }
}
