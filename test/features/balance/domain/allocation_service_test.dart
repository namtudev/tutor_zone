import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:tutor_zone/core/debug_log/logger.dart';
import 'package:tutor_zone/features/balance/domain/allocation_service.dart';
import 'package:tutor_zone/features/sessions/models/data/session.dart';
import 'package:tutor_zone/features/sessions/models/data_sources/session_local_data_source.dart';
import 'package:tutor_zone/features/students/models/data/student.dart';
import 'package:tutor_zone/features/students/models/data_sources/student_local_data_source.dart';

void main() {
  group('AllocationService Tests', () {
    late Database db;
    late StudentLocalDataSource studentDataSource;
    late SessionLocalDataSource sessionDataSource;
    late AllocationService allocationService;

    setUpAll(() {
      // Initialize Talker for logging in tests
      initializeTalker();
    });

    setUp(() async {
      // Create in-memory database for testing (use unique name for each test)
      db = await databaseFactoryMemory.openDatabase('test_${DateTime.now().millisecondsSinceEpoch}.db');
      studentDataSource = StudentLocalDataSource(db);
      sessionDataSource = SessionLocalDataSource(db);
      allocationService = AllocationService(db, studentDataSource, sessionDataSource);
    });

    tearDown(() async {
      await db.close();
    });

    // Helper to create test student
    Future<Student> createStudent({
      required String id,
      required String name,
      required int balanceCents,
      int hourlyRateCents = 4000,
    }) async {
      final student = Student.create(
        id: id,
        name: name,
        hourlyRateCents: hourlyRateCents,
        balanceCents: balanceCents,
      );
      await studentDataSource.create(student);
      return student;
    }

    // Helper to create test session
    Future<Session> createSession({
      required String id,
      required String studentId,
      required DateTime start,
      required DateTime end,
      required int amountCents,
      PaymentStatus payStatus = PaymentStatus.unpaid,
    }) async {
      final session = Session.create(
        id: id,
        studentId: studentId,
        start: start,
        end: end,
        rateSnapshotCents: 4000,
      ).copyWith(
        amountCents: amountCents,
        payStatus: payStatus,
      );
      await sessionDataSource.create(session);
      return session;
    }

    group('Exact Match Allocation', () {
      test('should allocate when balance exactly matches session amount', () async {
        // Arrange
        const studentId = 'student-1';
        const sessionId = 'session-1';
        const amount = 6000; // $60

        await createStudent(id: studentId, name: 'John Doe', balanceCents: amount);
        await createSession(
          id: sessionId,
          studentId: studentId,
          start: DateTime.now().add(const Duration(days: 1)),
          end: DateTime.now().add(const Duration(days: 1, hours: 1)),
          amountCents: amount,
        );

        // Act
        final allocated = await allocationService.runAllocation(studentId);

        // Assert
        expect(allocated, true);

        // Verify student balance is 0
        final student = await studentDataSource.getById(studentId);
        expect(student!.balanceCents, 0);

        // Verify session is paid
        final session = await sessionDataSource.getById(sessionId);
        expect(session!.payStatus, PaymentStatus.paid);
      });

      test('should allocate oldest session first (FIFO)', () async {
        // Arrange
        const studentId = 'student-1';
        const amount = 6000;

        await createStudent(id: studentId, name: 'John Doe', balanceCents: amount);

        // Create 3 unpaid sessions with different dates
        final now = DateTime.now();
        await createSession(
          id: 'session-3',
          studentId: studentId,
          start: now.add(const Duration(days: 3)),
          end: now.add(const Duration(days: 3, hours: 1)),
          amountCents: amount,
        );
        await createSession(
          id: 'session-1',
          studentId: studentId,
          start: now.add(const Duration(days: 1)), // Oldest
          end: now.add(const Duration(days: 1, hours: 1)),
          amountCents: amount,
        );
        await createSession(
          id: 'session-2',
          studentId: studentId,
          start: now.add(const Duration(days: 2)),
          end: now.add(const Duration(days: 2, hours: 1)),
          amountCents: amount,
        );

        // Act
        final allocated = await allocationService.runAllocation(studentId);

        // Assert
        expect(allocated, true);

        // Verify oldest session (session-1) is paid
        final session1 = await sessionDataSource.getById('session-1');
        expect(session1!.payStatus, PaymentStatus.paid);

        // Verify other sessions are still unpaid
        final session2 = await sessionDataSource.getById('session-2');
        final session3 = await sessionDataSource.getById('session-3');
        expect(session2!.payStatus, PaymentStatus.unpaid);
        expect(session3!.payStatus, PaymentStatus.unpaid);
      });

      test('should handle multiple exact matches in sequence', () async {
        // Arrange
        const studentId = 'student-1';
        const sessionAmount = 4000; // $40
        const initialBalance = 4000; // Start with balance for first session

        // Create student with initial balance
        final student = await createStudent(id: studentId, name: 'John Doe', balanceCents: initialBalance);

        final now = DateTime.now();
        await createSession(
          id: 'session-1',
          studentId: studentId,
          start: now.add(const Duration(days: 1)),
          end: now.add(const Duration(days: 1, hours: 1)),
          amountCents: sessionAmount,
        );
        await createSession(
          id: 'session-2',
          studentId: studentId,
          start: now.add(const Duration(days: 2)),
          end: now.add(const Duration(days: 2, hours: 1)),
          amountCents: sessionAmount,
        );
        await createSession(
          id: 'session-3',
          studentId: studentId,
          start: now.add(const Duration(days: 3)),
          end: now.add(const Duration(days: 3, hours: 1)),
          amountCents: sessionAmount,
        );

        // Act - First allocation
        var allocated = await allocationService.runAllocation(studentId);
        expect(allocated, true);

        // Add more balance for second session
        await studentDataSource.update(student.copyWith(balanceCents: 4000));
        allocated = await allocationService.runAllocation(studentId);
        expect(allocated, true);

        // Add more balance for third session
        await studentDataSource.update(student.copyWith(balanceCents: 4000));
        allocated = await allocationService.runAllocation(studentId);
        expect(allocated, true);

        // Verify all sessions are paid
        final session1 = await sessionDataSource.getById('session-1');
        final session2 = await sessionDataSource.getById('session-2');
        final session3 = await sessionDataSource.getById('session-3');
        expect(session1!.payStatus, PaymentStatus.paid);
        expect(session2!.payStatus, PaymentStatus.paid);
        expect(session3!.payStatus, PaymentStatus.paid);

        // Verify balance is 0
        final finalStudent = await studentDataSource.getById(studentId);
        expect(finalStudent!.balanceCents, 0);
      });
    });

    group('No Allocation Scenarios', () {
      test('should NOT allocate when balance is less than session amount (underpay)', () async {
        // Arrange
        const studentId = 'student-1';
        const balance = 5000; // $50
        const sessionAmount = 6000; // $60

        await createStudent(id: studentId, name: 'John Doe', balanceCents: balance);
        await createSession(
          id: 'session-1',
          studentId: studentId,
          start: DateTime.now().add(const Duration(days: 1)),
          end: DateTime.now().add(const Duration(days: 1, hours: 1)),
          amountCents: sessionAmount,
        );

        // Act
        final allocated = await allocationService.runAllocation(studentId);

        // Assert
        expect(allocated, false);

        // Verify student balance unchanged
        final student = await studentDataSource.getById(studentId);
        expect(student!.balanceCents, balance);

        // Verify session still unpaid
        final session = await sessionDataSource.getById('session-1');
        expect(session!.payStatus, PaymentStatus.unpaid);
      });

      test('should NOT allocate when balance is more than session amount (overpay)', () async {
        // Arrange
        const studentId = 'student-1';
        const balance = 7000; // $70
        const sessionAmount = 6000; // $60

        await createStudent(id: studentId, name: 'John Doe', balanceCents: balance);
        await createSession(
          id: 'session-1',
          studentId: studentId,
          start: DateTime.now().add(const Duration(days: 1)),
          end: DateTime.now().add(const Duration(days: 1, hours: 1)),
          amountCents: sessionAmount,
        );

        // Act
        final allocated = await allocationService.runAllocation(studentId);

        // Assert
        expect(allocated, false);

        // Verify student balance unchanged
        final student = await studentDataSource.getById(studentId);
        expect(student!.balanceCents, balance);

        // Verify session still unpaid
        final session = await sessionDataSource.getById('session-1');
        expect(session!.payStatus, PaymentStatus.unpaid);
      });

      test('should NOT allocate when balance is zero', () async {
        // Arrange
        const studentId = 'student-1';

        await createStudent(id: studentId, name: 'John Doe', balanceCents: 0);
        await createSession(
          id: 'session-1',
          studentId: studentId,
          start: DateTime.now().add(const Duration(days: 1)),
          end: DateTime.now().add(const Duration(days: 1, hours: 1)),
          amountCents: 6000,
        );

        // Act
        final allocated = await allocationService.runAllocation(studentId);

        // Assert
        expect(allocated, false);
      });

      test('should NOT allocate when balance is negative', () async {
        // Arrange
        const studentId = 'student-1';

        await createStudent(id: studentId, name: 'John Doe', balanceCents: -5000);
        await createSession(
          id: 'session-1',
          studentId: studentId,
          start: DateTime.now().add(const Duration(days: 1)),
          end: DateTime.now().add(const Duration(days: 1, hours: 1)),
          amountCents: 6000,
        );

        // Act
        final allocated = await allocationService.runAllocation(studentId);

        // Assert
        expect(allocated, false);
      });

      test('should NOT allocate when no unpaid sessions exist', () async {
        // Arrange
        const studentId = 'student-1';

        await createStudent(id: studentId, name: 'John Doe', balanceCents: 6000);
        // No sessions created

        // Act
        final allocated = await allocationService.runAllocation(studentId);

        // Assert
        expect(allocated, false);
      });

      test('should NOT allocate when all sessions are already paid', () async {
        // Arrange
        const studentId = 'student-1';

        await createStudent(id: studentId, name: 'John Doe', balanceCents: 6000);
        await createSession(
          id: 'session-1',
          studentId: studentId,
          start: DateTime.now().add(const Duration(days: 1)),
          end: DateTime.now().add(const Duration(days: 1, hours: 1)),
          amountCents: 6000,
          payStatus: PaymentStatus.paid, // Already paid
        );

        // Act
        final allocated = await allocationService.runAllocation(studentId);

        // Assert
        expect(allocated, false);
      });

      test('should NOT allocate when student does not exist', () async {
        // Act
        final allocated = await allocationService.runAllocation('non-existent-student');

        // Assert
        expect(allocated, false);
      });
    });

    group('Helper Methods', () {
      test('wouldAllocate should return true for exact match', () async {
        // Arrange
        const studentId = 'student-1';
        const amount = 6000;

        await createStudent(id: studentId, name: 'John Doe', balanceCents: 0);
        await createSession(
          id: 'session-1',
          studentId: studentId,
          start: DateTime.now().add(const Duration(days: 1)),
          end: DateTime.now().add(const Duration(days: 1, hours: 1)),
          amountCents: amount,
        );

        // Act
        final wouldAllocate = await allocationService.wouldAllocate(studentId, amount);

        // Assert
        expect(wouldAllocate, true);
      });

      test('wouldAllocate should return false for non-exact match', () async {
        // Arrange
        const studentId = 'student-1';

        await createStudent(id: studentId, name: 'John Doe', balanceCents: 0);
        await createSession(
          id: 'session-1',
          studentId: studentId,
          start: DateTime.now().add(const Duration(days: 1)),
          end: DateTime.now().add(const Duration(days: 1, hours: 1)),
          amountCents: 6000,
        );

        // Act
        final wouldAllocate = await allocationService.wouldAllocate(studentId, 5000);

        // Assert
        expect(wouldAllocate, false);
      });

      test('wouldAllocate should return false when no unpaid sessions', () async {
        // Arrange
        const studentId = 'student-1';

        await createStudent(id: studentId, name: 'John Doe', balanceCents: 0);

        // Act
        final wouldAllocate = await allocationService.wouldAllocate(studentId, 6000);

        // Assert
        expect(wouldAllocate, false);
      });

      test('getNextAllocationTarget should return oldest unpaid session', () async {
        // Arrange
        const studentId = 'student-1';

        await createStudent(id: studentId, name: 'John Doe', balanceCents: 0);

        final now = DateTime.now();
        await createSession(
          id: 'session-2',
          studentId: studentId,
          start: now.add(const Duration(days: 2)),
          end: now.add(const Duration(days: 2, hours: 1)),
          amountCents: 6000,
        );
        await createSession(
          id: 'session-1',
          studentId: studentId,
          start: now.add(const Duration(days: 1)), // Oldest
          end: now.add(const Duration(days: 1, hours: 1)),
          amountCents: 6000,
        );

        // Act
        final target = await allocationService.getNextAllocationTarget(studentId);

        // Assert
        expect(target, isNotNull);
        expect(target!.id, 'session-1');
      });

      test('getNextAllocationTarget should return null when no unpaid sessions', () async {
        // Arrange
        const studentId = 'student-1';

        await createStudent(id: studentId, name: 'John Doe', balanceCents: 0);

        // Act
        final target = await allocationService.getNextAllocationTarget(studentId);

        // Assert
        expect(target, isNull);
      });
    });

    group('Batch Operations', () {
      test('runAllocationForStudents should allocate for multiple students', () async {
        // Arrange
        const amount = 6000;

        await createStudent(id: 'student-1', name: 'John', balanceCents: amount);
        await createSession(
          id: 'session-1',
          studentId: 'student-1',
          start: DateTime.now().add(const Duration(days: 1)),
          end: DateTime.now().add(const Duration(days: 1, hours: 1)),
          amountCents: amount,
        );

        await createStudent(id: 'student-2', name: 'Jane', balanceCents: amount);
        await createSession(
          id: 'session-2',
          studentId: 'student-2',
          start: DateTime.now().add(const Duration(days: 1)),
          end: DateTime.now().add(const Duration(days: 1, hours: 1)),
          amountCents: amount,
        );

        await createStudent(id: 'student-3', name: 'Bob', balanceCents: 5000); // No match
        await createSession(
          id: 'session-3',
          studentId: 'student-3',
          start: DateTime.now().add(const Duration(days: 1)),
          end: DateTime.now().add(const Duration(days: 1, hours: 1)),
          amountCents: amount,
        );

        // Act
        final results = await allocationService.runAllocationForStudents([
          'student-1',
          'student-2',
          'student-3',
        ]);

        // Assert
        expect(results['student-1'], true);
        expect(results['student-2'], true);
        expect(results['student-3'], false);
      });

      test('runAllocationForAllStudents should allocate for all eligible students', () async {
        // Arrange
        const amount = 6000;

        await createStudent(id: 'student-1', name: 'John', balanceCents: amount);
        await createSession(
          id: 'session-1',
          studentId: 'student-1',
          start: DateTime.now().add(const Duration(days: 1)),
          end: DateTime.now().add(const Duration(days: 1, hours: 1)),
          amountCents: amount,
        );

        await createStudent(id: 'student-2', name: 'Jane', balanceCents: amount);
        await createSession(
          id: 'session-2',
          studentId: 'student-2',
          start: DateTime.now().add(const Duration(days: 1)),
          end: DateTime.now().add(const Duration(days: 1, hours: 1)),
          amountCents: amount,
        );

        await createStudent(id: 'student-3', name: 'Bob', balanceCents: 0); // No balance

        // Act
        final allocatedCount = await allocationService.runAllocationForAllStudents();

        // Assert
        expect(allocatedCount, 2);

        // Verify allocations
        final student1 = await studentDataSource.getById('student-1');
        final student2 = await studentDataSource.getById('student-2');
        expect(student1!.balanceCents, 0);
        expect(student2!.balanceCents, 0);
      });

      test('runAllocationForAllStudents should return 0 when no students have balance', () async {
        // Arrange
        await createStudent(id: 'student-1', name: 'John', balanceCents: 0);
        await createStudent(id: 'student-2', name: 'Jane', balanceCents: -1000);

        // Act
        final allocatedCount = await allocationService.runAllocationForAllStudents();

        // Assert
        expect(allocatedCount, 0);
      });
    });

    group('Trigger Methods', () {
      test('runAllocationAfterBalanceChange should trigger allocation', () async {
        // Arrange
        const studentId = 'student-1';
        const amount = 6000;

        await createStudent(id: studentId, name: 'John Doe', balanceCents: amount);
        await createSession(
          id: 'session-1',
          studentId: studentId,
          start: DateTime.now().add(const Duration(days: 1)),
          end: DateTime.now().add(const Duration(days: 1, hours: 1)),
          amountCents: amount,
        );

        // Act
        final allocated = await allocationService.runAllocationAfterBalanceChange(studentId);

        // Assert
        expect(allocated, true);
      });

      test('runAllocationAfterSessionSave should trigger allocation', () async {
        // Arrange
        const studentId = 'student-1';
        const amount = 6000;

        await createStudent(id: studentId, name: 'John Doe', balanceCents: amount);
        await createSession(
          id: 'session-1',
          studentId: studentId,
          start: DateTime.now().add(const Duration(days: 1)),
          end: DateTime.now().add(const Duration(days: 1, hours: 1)),
          amountCents: amount,
        );

        // Act
        final allocated = await allocationService.runAllocationAfterSessionSave(studentId);

        // Assert
        expect(allocated, true);
      });

      test('runAllocationAfterGeneration should allocate multiple sessions', () async {
        // Arrange
        const studentId = 'student-1';
        const sessionAmount = 4000;
        const initialBalance = 4000; // Start with exact match for first session

        await createStudent(id: studentId, name: 'John Doe', balanceCents: initialBalance);

        final now = DateTime.now();
        await createSession(
          id: 'session-1',
          studentId: studentId,
          start: now.add(const Duration(days: 1)),
          end: now.add(const Duration(days: 1, hours: 1)),
          amountCents: sessionAmount,
        );

        // Act - Should allocate 1 session
        final allocatedCount = await allocationService.runAllocationAfterGeneration(studentId);

        // Assert
        expect(allocatedCount, 1);

        // Verify session is paid
        final session1 = await sessionDataSource.getById('session-1');
        expect(session1!.payStatus, PaymentStatus.paid);

        // Verify balance is 0
        final student = await studentDataSource.getById(studentId);
        expect(student!.balanceCents, 0);
      });
    });

    group('Atomicity', () {
      test('allocation should be atomic (both student and session updated together)', () async {
        // Arrange
        const studentId = 'student-1';
        const sessionId = 'session-1';
        const amount = 6000;

        await createStudent(id: studentId, name: 'John Doe', balanceCents: amount);
        await createSession(
          id: sessionId,
          studentId: studentId,
          start: DateTime.now().add(const Duration(days: 1)),
          end: DateTime.now().add(const Duration(days: 1, hours: 1)),
          amountCents: amount,
        );

        // Act
        await allocationService.runAllocation(studentId);

        // Assert - Both should be updated
        final student = await studentDataSource.getById(studentId);
        final session = await sessionDataSource.getById(sessionId);

        expect(student!.balanceCents, 0);
        expect(session!.payStatus, PaymentStatus.paid);
      });
    });
  });
}

