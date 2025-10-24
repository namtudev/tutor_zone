import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tutor_zone/core/debug_log/logger.dart';
import 'package:tutor_zone/features/balance/models/data/balance_change.dart';
import 'package:tutor_zone/features/balance/models/repositories/balance_change_repository.dart';
import 'package:tutor_zone/features/sessions/models/data/session.dart';
import 'package:tutor_zone/features/sessions/models/repositories/session_repository.dart';
import 'package:tutor_zone/features/students/models/data/student.dart';
import 'package:tutor_zone/features/students/models/repositories/student_repository.dart';
import 'package:uuid/uuid.dart';

part 'fake_data_seeder.g.dart';

const _uuid = Uuid();

/// Service for seeding fake data into Sembast database (dev mode only)
@riverpod
FakeDataSeeder fakeDataSeeder(Ref ref) {
  final studentRepo = ref.watch(studentRepositoryProvider);
  final sessionRepo = ref.watch(sessionRepositoryProvider);
  final balanceChangeRepo = ref.watch(balanceChangeRepositoryProvider);

  return FakeDataSeeder(
    studentRepository: studentRepo,
    sessionRepository: sessionRepo,
    balanceChangeRepository: balanceChangeRepo,
  );
}

/// Provides methods to seed fake data for development and testing
class FakeDataSeeder {
  final StudentRepository _studentRepository;
  final SessionRepository _sessionRepository;
  final BalanceChangeRepository _balanceChangeRepository;

  /// Creates a new [FakeDataSeeder]
  FakeDataSeeder({
    required StudentRepository studentRepository,
    required SessionRepository sessionRepository,
    required BalanceChangeRepository balanceChangeRepository,
  }) : _studentRepository = studentRepository,
       _sessionRepository = sessionRepository,
       _balanceChangeRepository = balanceChangeRepository;

  /// Seed all fake data (students, sessions, balance changes)
  Future<void> seedAll() async {
    logInfo('Starting fake data seeding...');

    try {
      // Create students
      final students = await _seedStudents();
      logInfo('Created ${students.length} fake students');

      // Create sessions for students
      final sessions = await _seedSessions(students);
      logInfo('Created ${sessions.length} fake sessions');

      // Create balance changes (payments)
      final balanceChanges = await _seedBalanceChanges(students);
      logInfo('Created ${balanceChanges.length} fake balance changes');

      logInfo('Fake data seeding completed successfully');
    } catch (e, stack) {
      logError('Failed to seed fake data', e, stack);
      rethrow;
    }
  }

  /// Clear all data from database
  Future<void> clearAll() async {
    logInfo('Clearing all data from database...');

    try {
      // Get all students
      final students = await _studentRepository.getAll();

      // Delete all students (this should cascade delete sessions and balance changes)
      for (final student in students) {
        await _studentRepository.delete(student.id);
      }

      logInfo('All data cleared successfully');
    } catch (e, stack) {
      logError('Failed to clear data', e, stack);
      rethrow;
    }
  }

  /// Seed fake students
  Future<List<Student>> _seedStudents() async {
    final students = [
      Student.create(
        id: _uuid.v4(),
        name: 'Sarah Chen',
        hourlyRateCents: 4000, // $40/hr
        balanceCents: -3200, // Owes $32 (0.8 hrs)
      ),
      Student.create(
        id: _uuid.v4(),
        name: 'Mike Johnson',
        hourlyRateCents: 5000, // $50/hr
        // balanceCents: 0 is the default, omitted
      ),
      Student.create(
        id: _uuid.v4(),
        name: 'Emma Davis',
        hourlyRateCents: 4000, // $40/hr
        balanceCents: 8000, // $80 credit (2 hrs)
      ),
      Student.create(
        id: _uuid.v4(),
        name: 'Alex Martinez',
        hourlyRateCents: 4500, // $45/hr
        balanceCents: -9000, // Owes $90 (2 hrs)
      ),
      Student.create(
        id: _uuid.v4(),
        name: 'Jordan Lee',
        hourlyRateCents: 3500, // $35/hr
        balanceCents: 7000, // $70 credit (2 hrs)
      ),
    ];

    for (final student in students) {
      await _studentRepository.create(student);
    }

    return students;
  }

  /// Seed fake sessions for students
  Future<List<Session>> _seedSessions(List<Student> students) async {
    final sessions = <Session>[];
    final now = DateTime.now();

    // Sarah Chen - 3 sessions this month (1 unpaid)
    if (students.isNotEmpty) {
      final sarah = students[0];
      sessions.addAll([
        Session.create(
          id: _uuid.v4(),
          studentId: sarah.id,
          start: now.subtract(const Duration(days: 20)),
          end: now.subtract(const Duration(days: 20, hours: -1, minutes: -30)),
          rateSnapshotCents: sarah.hourlyRateCents,
          payStatus: PaymentStatus.paid,
        ),
        Session.create(
          id: _uuid.v4(),
          studentId: sarah.id,
          start: now.subtract(const Duration(days: 10)),
          end: now.subtract(const Duration(days: 10, hours: -2)),
          rateSnapshotCents: sarah.hourlyRateCents,
          payStatus: PaymentStatus.paid,
        ),
        Session.create(
          id: _uuid.v4(),
          studentId: sarah.id,
          start: now.subtract(const Duration(days: 2)),
          end: now.subtract(const Duration(days: 2, hours: -1, minutes: -30)),
          rateSnapshotCents: sarah.hourlyRateCents,
          // payStatus: PaymentStatus.unpaid is the default, omitted
        ),
      ]);
    }

    // Mike Johnson - 2 sessions this month (all paid)
    if (students.length > 1) {
      final mike = students[1];
      sessions.addAll([
        Session.create(
          id: _uuid.v4(),
          studentId: mike.id,
          start: now.subtract(const Duration(days: 15)),
          end: now.subtract(const Duration(days: 15, hours: -2)),
          rateSnapshotCents: mike.hourlyRateCents,
          payStatus: PaymentStatus.paid,
        ),
        Session.create(
          id: _uuid.v4(),
          studentId: mike.id,
          start: now.subtract(const Duration(days: 5)),
          end: now.subtract(const Duration(days: 5, hours: -2)),
          rateSnapshotCents: mike.hourlyRateCents,
          payStatus: PaymentStatus.paid,
        ),
      ]);
    }

    // Emma Davis - 2 sessions this month (1 upcoming)
    if (students.length > 2) {
      final emma = students[2];
      sessions.addAll([
        Session.create(
          id: _uuid.v4(),
          studentId: emma.id,
          start: now.subtract(const Duration(days: 12)),
          end: now.subtract(const Duration(days: 12, hours: -1)),
          rateSnapshotCents: emma.hourlyRateCents,
          payStatus: PaymentStatus.paid,
        ),
        Session.create(
          id: _uuid.v4(),
          studentId: emma.id,
          start: now.add(const Duration(days: 2)),
          end: now.add(const Duration(days: 2, hours: 1)),
          rateSnapshotCents: emma.hourlyRateCents,
          // payStatus: PaymentStatus.unpaid is the default, omitted
        ),
      ]);
    }

    // Alex Martinez - 4 sessions this month (2 unpaid)
    if (students.length > 3) {
      final alex = students[3];
      sessions.addAll([
        Session.create(
          id: _uuid.v4(),
          studentId: alex.id,
          start: now.subtract(const Duration(days: 25)),
          end: now.subtract(const Duration(days: 25, hours: -1, minutes: -30)),
          rateSnapshotCents: alex.hourlyRateCents,
          payStatus: PaymentStatus.paid,
        ),
        Session.create(
          id: _uuid.v4(),
          studentId: alex.id,
          start: now.subtract(const Duration(days: 18)),
          end: now.subtract(const Duration(days: 18, hours: -1, minutes: -30)),
          rateSnapshotCents: alex.hourlyRateCents,
          payStatus: PaymentStatus.paid,
        ),
        Session.create(
          id: _uuid.v4(),
          studentId: alex.id,
          start: now.subtract(const Duration(days: 8)),
          end: now.subtract(const Duration(days: 8, hours: -2)),
          rateSnapshotCents: alex.hourlyRateCents,
          // payStatus: PaymentStatus.unpaid is the default, omitted
        ),
        Session.create(
          id: _uuid.v4(),
          studentId: alex.id,
          start: now.subtract(const Duration(days: 3)),
          end: now.subtract(const Duration(days: 3, hours: -2)),
          rateSnapshotCents: alex.hourlyRateCents,
          // payStatus: PaymentStatus.unpaid is the default, omitted
        ),
      ]);
    }

    // Jordan Lee - 1 session this month (paid)
    if (students.length > 4) {
      final jordan = students[4];
      sessions.add(
        Session.create(
          id: _uuid.v4(),
          studentId: jordan.id,
          start: now.subtract(const Duration(days: 7)),
          end: now.subtract(const Duration(days: 7, hours: -1, minutes: -30)),
          rateSnapshotCents: jordan.hourlyRateCents,
          payStatus: PaymentStatus.paid,
        ),
      );
    }

    for (final session in sessions) {
      await _sessionRepository.create(session);
    }

    return sessions;
  }

  /// Seed fake balance changes (payments)
  Future<List<BalanceChange>> _seedBalanceChanges(List<Student> students) async {
    final balanceChanges = <BalanceChange>[];

    // Sarah Chen - 1 payment
    if (students.isNotEmpty) {
      balanceChanges.add(
        BalanceChange.payment(
          id: _uuid.v4(),
          studentId: students[0].id,
          amountCents: 12000, // $120 payment
        ),
      );
    }

    // Mike Johnson - 2 payments
    if (students.length > 1) {
      balanceChanges.addAll([
        BalanceChange.payment(
          id: _uuid.v4(),
          studentId: students[1].id,
          amountCents: 10000, // $100 payment
        ),
        BalanceChange.payment(
          id: _uuid.v4(),
          studentId: students[1].id,
          amountCents: 10000, // $100 payment
        ),
      ]);
    }

    // Emma Davis - 1 large prepayment
    if (students.length > 2) {
      balanceChanges.add(
        BalanceChange.payment(
          id: _uuid.v4(),
          studentId: students[2].id,
          amountCents: 20000, // $200 prepayment
        ),
      );
    }

    for (final balanceChange in balanceChanges) {
      await _balanceChangeRepository.create(balanceChange);
    }

    return balanceChanges;
  }
}
