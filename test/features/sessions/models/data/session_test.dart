import 'package:flutter_test/flutter_test.dart';
import 'package:tutor_zone/features/sessions/models/data/session.dart';

void main() {
  group('Session Model Tests', () {
    // Test data
    const testId = 'test-session-id-123';
    const testStudentId = 'test-student-id-456';
    const testStart = '2024-01-15T14:00:00.000Z'; // 2:00 PM
    const testEnd = '2024-01-15T15:30:00.000Z'; // 3:30 PM (1.5 hours)
    const testRateSnapshotCents = 4000; // $40.00/hr
    const testAmountCents = 6000; // $60.00 (1.5 hrs × $40/hr)
    const testCreatedAt = '2024-01-15T10:00:00.000Z';
    const testUpdatedAt = '2024-01-15T10:00:00.000Z';

    Session createTestSession({
      String? id,
      String? studentId,
      String? start,
      String? end,
      SessionAttendance? attendance,
      int? rateSnapshotCents,
      int? amountCents,
      PaymentStatus? payStatus,
      String? createdAt,
      String? updatedAt,
    }) {
      return Session(
        id: id ?? testId,
        studentId: studentId ?? testStudentId,
        start: start ?? testStart,
        end: end ?? testEnd,
        attendance: attendance ?? SessionAttendance.completed,
        rateSnapshotCents: rateSnapshotCents ?? testRateSnapshotCents,
        amountCents: amountCents ?? testAmountCents,
        payStatus: payStatus ?? PaymentStatus.unpaid,
        createdAt: createdAt ?? testCreatedAt,
        updatedAt: updatedAt ?? testUpdatedAt,
      );
    }

    group('Enums', () {
      test('SessionAttendance should have correct JSON values', () {
        expect(SessionAttendance.completed.name, 'completed');
        expect(SessionAttendance.skipped.name, 'skipped');
      });

      test('PaymentStatus should have correct JSON values', () {
        expect(PaymentStatus.paid.name, 'paid');
        expect(PaymentStatus.unpaid.name, 'unpaid');
      });
    });

    group('Constructor & Factory', () {
      test('should create Session with all required fields', () {
        final session = createTestSession();

        expect(session.id, testId);
        expect(session.studentId, testStudentId);
        expect(session.start, testStart);
        expect(session.end, testEnd);
        expect(session.attendance, SessionAttendance.completed);
        expect(session.rateSnapshotCents, testRateSnapshotCents);
        expect(session.amountCents, testAmountCents);
        expect(session.payStatus, PaymentStatus.unpaid);
        expect(session.createdAt, testCreatedAt);
        expect(session.updatedAt, testUpdatedAt);
      });

      test('Session.create should generate timestamps and calculate amount', () {
        final startTime = DateTime(2024, 1, 15, 14); // 2:00 PM
        final endTime = DateTime(2024, 1, 15, 15, 30); // 3:30 PM (1.5 hours)
        final beforeCreate = DateTime.now();

        final session = Session.create(
          id: testId,
          studentId: testStudentId,
          start: startTime,
          end: endTime,
          rateSnapshotCents: testRateSnapshotCents,
        );

        final afterCreate = DateTime.now();
        final createdTime = DateTime.parse(session.createdAt);

        expect(session.id, testId);
        expect(session.studentId, testStudentId);
        expect(session.rateSnapshotCents, testRateSnapshotCents);
        expect(session.amountCents, 6000); // 1.5 hrs × $40/hr = $60
        expect(session.attendance, SessionAttendance.completed);
        expect(session.payStatus, PaymentStatus.unpaid);
        expect(createdTime.isAfter(beforeCreate.subtract(const Duration(seconds: 1))), true);
        expect(createdTime.isBefore(afterCreate.add(const Duration(seconds: 1))), true);
        expect(session.createdAt, session.updatedAt);
      });

      test('Session.create should allow custom attendance and payStatus', () {
        final startTime = DateTime(2024, 1, 15, 14);
        final endTime = DateTime(2024, 1, 15, 15, 30);

        final session = Session.create(
          id: testId,
          studentId: testStudentId,
          start: startTime,
          end: endTime,
          rateSnapshotCents: testRateSnapshotCents,
          attendance: SessionAttendance.skipped,
          payStatus: PaymentStatus.paid,
        );

        expect(session.attendance, SessionAttendance.skipped);
        expect(session.payStatus, PaymentStatus.paid);
      });

      test('Session.create should calculate amount for different durations', () {
        final startTime = DateTime(2024, 1, 15, 14);
        
        // 1 hour session
        final session1 = Session.create(
          id: testId,
          studentId: testStudentId,
          start: startTime,
          end: startTime.add(const Duration(hours: 1)),
          rateSnapshotCents: 4000,
        );
        expect(session1.amountCents, 4000); // 1 hr × $40/hr = $40

        // 2 hour session
        final session2 = Session.create(
          id: testId,
          studentId: testStudentId,
          start: startTime,
          end: startTime.add(const Duration(hours: 2)),
          rateSnapshotCents: 4000,
        );
        expect(session2.amountCents, 8000); // 2 hrs × $40/hr = $80

        // 30 minute session
        final session3 = Session.create(
          id: testId,
          studentId: testStudentId,
          start: startTime,
          end: startTime.add(const Duration(minutes: 30)),
          rateSnapshotCents: 4000,
        );
        expect(session3.amountCents, 2000); // 0.5 hrs × $40/hr = $20
      });
    });

    group('JSON Serialization', () {
      test('should serialize to JSON correctly', () {
        final session = createTestSession();
        final json = session.toJson();

        expect(json['id'], testId);
        expect(json['studentId'], testStudentId);
        expect(json['start'], testStart);
        expect(json['end'], testEnd);
        expect(json['attendance'], 'completed');
        expect(json['rateSnapshotCents'], testRateSnapshotCents);
        expect(json['amountCents'], testAmountCents);
        expect(json['payStatus'], 'unpaid');
        expect(json['createdAt'], testCreatedAt);
        expect(json['updatedAt'], testUpdatedAt);
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'id': testId,
          'studentId': testStudentId,
          'start': testStart,
          'end': testEnd,
          'attendance': 'completed',
          'rateSnapshotCents': testRateSnapshotCents,
          'amountCents': testAmountCents,
          'payStatus': 'unpaid',
          'createdAt': testCreatedAt,
          'updatedAt': testUpdatedAt,
        };

        final session = Session.fromJson(json);

        expect(session.id, testId);
        expect(session.studentId, testStudentId);
        expect(session.start, testStart);
        expect(session.end, testEnd);
        expect(session.attendance, SessionAttendance.completed);
        expect(session.rateSnapshotCents, testRateSnapshotCents);
        expect(session.amountCents, testAmountCents);
        expect(session.payStatus, PaymentStatus.unpaid);
        expect(session.createdAt, testCreatedAt);
        expect(session.updatedAt, testUpdatedAt);
      });

      test('should complete JSON round-trip without data loss', () {
        final original = createTestSession();
        final json = original.toJson();
        final deserialized = Session.fromJson(json);

        expect(deserialized, original);
      });

      test('should serialize skipped attendance correctly', () {
        final session = createTestSession(attendance: SessionAttendance.skipped);
        final json = session.toJson();

        expect(json['attendance'], 'skipped');
      });

      test('should serialize paid status correctly', () {
        final session = createTestSession(payStatus: PaymentStatus.paid);
        final json = session.toJson();

        expect(json['payStatus'], 'paid');
      });
    });

    group('copyWith', () {
      test('should copy with new attendance', () {
        final session = createTestSession();
        final updated = session.copyWith(attendance: SessionAttendance.skipped);

        expect(updated.attendance, SessionAttendance.skipped);
        expect(updated.id, session.id);
        expect(updated.studentId, session.studentId);
      });

      test('should copy with new payStatus', () {
        final session = createTestSession();
        final updated = session.copyWith(payStatus: PaymentStatus.paid);

        expect(updated.payStatus, PaymentStatus.paid);
        expect(updated.id, session.id);
      });

      test('should copy with new amountCents', () {
        final session = createTestSession();
        final updated = session.copyWith(amountCents: 8000);

        expect(updated.amountCents, 8000);
        expect(updated.id, session.id);
      });
    });

    group('update method', () {
      test('should update start time and recalculate amount', () {
        final session = createTestSession();
        final newStart = DateTime.parse(testStart).add(const Duration(hours: 1));
        
        final updated = session.update(start: newStart);

        expect(DateTime.parse(updated.start), newStart);
        expect(updated.updatedAt, isNot(session.updatedAt));
        // Duration changed from 1.5 hrs to 0.5 hrs, so amount should be 2000 (0.5 × 4000)
        expect(updated.amountCents, 2000);
      });

      test('should update end time and recalculate amount', () {
        final session = createTestSession();
        final newEnd = DateTime.parse(testEnd).add(const Duration(hours: 1));
        
        final updated = session.update(end: newEnd);

        expect(DateTime.parse(updated.end), newEnd);
        expect(updated.updatedAt, isNot(session.updatedAt));
        // Duration changed from 1.5 hrs to 2.5 hrs, so amount should be 10000 (2.5 × 4000)
        expect(updated.amountCents, 10000);
      });

      test('should update rate and recalculate amount', () {
        final session = createTestSession();
        
        final updated = session.update(rateSnapshotCents: 5000);

        expect(updated.rateSnapshotCents, 5000);
        expect(updated.updatedAt, isNot(session.updatedAt));
        // Duration is still 1.5 hrs, but rate is now $50/hr, so amount should be 7500
        expect(updated.amountCents, 7500);
      });

      test('should update attendance', () {
        final session = createTestSession();
        
        final updated = session.update(attendance: SessionAttendance.skipped);

        expect(updated.attendance, SessionAttendance.skipped);
        expect(updated.updatedAt, isNot(session.updatedAt));
      });

      test('should update payStatus', () {
        final session = createTestSession();
        
        final updated = session.update(payStatus: PaymentStatus.paid);

        expect(updated.payStatus, PaymentStatus.paid);
        expect(updated.updatedAt, isNot(session.updatedAt));
      });
    });

    group('Status Methods', () {
      test('markAsPaid should update payStatus to paid', () {
        final session = createTestSession(payStatus: PaymentStatus.unpaid);
        final updated = session.markAsPaid();

        expect(updated.payStatus, PaymentStatus.paid);
        expect(updated.updatedAt, isNot(session.updatedAt));
      });

      test('markAsUnpaid should update payStatus to unpaid', () {
        final session = createTestSession(payStatus: PaymentStatus.paid);
        final updated = session.markAsUnpaid();

        expect(updated.payStatus, PaymentStatus.unpaid);
        expect(updated.updatedAt, isNot(session.updatedAt));
      });

      test('markAsCompleted should update attendance to completed', () {
        final session = createTestSession(attendance: SessionAttendance.skipped);
        final updated = session.markAsCompleted();

        expect(updated.attendance, SessionAttendance.completed);
        expect(updated.updatedAt, isNot(session.updatedAt));
      });

      test('markAsSkipped should update attendance and set amount to 0', () {
        final session = createTestSession(
          attendance: SessionAttendance.completed,
          amountCents: 6000,
        );
        final updated = session.markAsSkipped();

        expect(updated.attendance, SessionAttendance.skipped);
        expect(updated.amountCents, 0);
        expect(updated.updatedAt, isNot(session.updatedAt));
      });
    });

    group('Computed Properties', () {
      test('rateSnapshotDollars should convert cents to dollars', () {
        final session = createTestSession(rateSnapshotCents: 4000);
        expect(session.rateSnapshotDollars, 40.0);
      });

      test('amountDollars should convert cents to dollars', () {
        final session = createTestSession(amountCents: 6000);
        expect(session.amountDollars, 60.0);
      });

      test('durationHours should calculate correct duration', () {
        final session = createTestSession(); // 1.5 hours
        expect(session.durationHours, 1.5);
      });

      test('isCompleted should be true when attendance is completed', () {
        final session = createTestSession(attendance: SessionAttendance.completed);
        expect(session.isCompleted, true);
      });

      test('isCompleted should be false when attendance is skipped', () {
        final session = createTestSession(attendance: SessionAttendance.skipped);
        expect(session.isCompleted, false);
      });

      test('isSkipped should be true when attendance is skipped', () {
        final session = createTestSession(attendance: SessionAttendance.skipped);
        expect(session.isSkipped, true);
      });

      test('isSkipped should be false when attendance is completed', () {
        final session = createTestSession(attendance: SessionAttendance.completed);
        expect(session.isSkipped, false);
      });

      test('isPaid should be true when payStatus is paid', () {
        final session = createTestSession(payStatus: PaymentStatus.paid);
        expect(session.isPaid, true);
      });

      test('isPaid should be false when payStatus is unpaid', () {
        final session = createTestSession(payStatus: PaymentStatus.unpaid);
        expect(session.isPaid, false);
      });

      test('isUnpaid should be true when payStatus is unpaid', () {
        final session = createTestSession(payStatus: PaymentStatus.unpaid);
        expect(session.isUnpaid, true);
      });

      test('isUnpaid should be false when payStatus is paid', () {
        final session = createTestSession(payStatus: PaymentStatus.paid);
        expect(session.isUnpaid, false);
      });

      test('isFuture should be true for future sessions', () {
        final futureStart = DateTime.now().add(const Duration(days: 1)).toIso8601String();
        final futureEnd = DateTime.now().add(const Duration(days: 1, hours: 1)).toIso8601String();
        final session = createTestSession(start: futureStart, end: futureEnd);

        expect(session.isFuture, true);
      });

      test('isFuture should be false for past sessions', () {
        final pastStart = DateTime.now().subtract(const Duration(days: 1)).toIso8601String();
        final pastEnd = DateTime.now().subtract(const Duration(days: 1, hours: -1)).toIso8601String();
        final session = createTestSession(start: pastStart, end: pastEnd);

        expect(session.isFuture, false);
      });

      test('isPast should be true for past sessions', () {
        final pastStart = DateTime.now().subtract(const Duration(days: 1)).toIso8601String();
        final pastEnd = DateTime.now().subtract(const Duration(hours: 23)).toIso8601String();
        final session = createTestSession(start: pastStart, end: pastEnd);

        expect(session.isPast, true);
      });

      test('isPast should be false for future sessions', () {
        final futureStart = DateTime.now().add(const Duration(days: 1)).toIso8601String();
        final futureEnd = DateTime.now().add(const Duration(days: 1, hours: 1)).toIso8601String();
        final session = createTestSession(start: futureStart, end: futureEnd);

        expect(session.isPast, false);
      });

      test('formattedDate should format date correctly', () {
        final session = createTestSession(start: '2024-01-15T14:00:00.000Z');
        expect(session.formattedDate, 'Jan 15, 2024');
      });

      test('formattedTimeRange should format time range correctly', () {
        // 2:00 PM - 3:30 PM
        final session = createTestSession(
          start: '2024-01-15T14:00:00.000Z',
          end: '2024-01-15T15:30:00.000Z',
        );
        expect(session.formattedTimeRange, '2:00 PM - 3:30 PM');
      });

      test('formattedTimeRange should handle AM times', () {
        // 9:00 AM - 10:30 AM
        final session = createTestSession(
          start: '2024-01-15T09:00:00.000Z',
          end: '2024-01-15T10:30:00.000Z',
        );
        expect(session.formattedTimeRange, '9:00 AM - 10:30 AM');
      });

      test('formattedTimeRange should handle midnight', () {
        // 12:00 AM - 1:00 AM
        final session = createTestSession(
          start: '2024-01-15T00:00:00.000Z',
          end: '2024-01-15T01:00:00.000Z',
        );
        expect(session.formattedTimeRange, '12:00 AM - 1:00 AM');
      });

      test('formattedTimeRange should handle noon', () {
        // 12:00 PM - 1:00 PM
        final session = createTestSession(
          start: '2024-01-15T12:00:00.000Z',
          end: '2024-01-15T13:00:00.000Z',
        );
        expect(session.formattedTimeRange, '12:00 PM - 1:00 PM');
      });
    });

    group('Equality', () {
      test('should be equal when all fields match', () {
        final session1 = createTestSession();
        final session2 = createTestSession();

        expect(session1, session2);
      });

      test('should not be equal when id differs', () {
        final session1 = createTestSession(id: 'id-1');
        final session2 = createTestSession(id: 'id-2');

        expect(session1, isNot(session2));
      });

      test('should not be equal when studentId differs', () {
        final session1 = createTestSession(studentId: 'student-1');
        final session2 = createTestSession(studentId: 'student-2');

        expect(session1, isNot(session2));
      });

      test('should not be equal when attendance differs', () {
        final session1 = createTestSession(attendance: SessionAttendance.completed);
        final session2 = createTestSession(attendance: SessionAttendance.skipped);

        expect(session1, isNot(session2));
      });

      test('should not be equal when payStatus differs', () {
        final session1 = createTestSession(payStatus: PaymentStatus.paid);
        final session2 = createTestSession(payStatus: PaymentStatus.unpaid);

        expect(session1, isNot(session2));
      });
    });
  });
}

