import 'package:flutter_test/flutter_test.dart';
import 'package:tutor_zone/features/sessions/models/data/recurring_schedule.dart';

void main() {
  group('RecurringSchedule Model Tests', () {
    // Test data
    const testId = 'test-schedule-id-123';
    const testStudentId = 'test-student-id-456';
    const testWeekday = 2; // Tuesday
    const testStartLocal = '14:00'; // 2:00 PM
    const testEndLocal = '15:30'; // 3:30 PM (1.5 hours)
    const testRateSnapshotCents = 4000; // $40.00/hr
    const testIsActive = true;
    const testCreatedAt = '2024-01-15T10:00:00.000Z';
    const testUpdatedAt = '2024-01-15T10:00:00.000Z';

    RecurringSchedule createTestSchedule({
      String? id,
      String? studentId,
      int? weekday,
      String? startLocal,
      String? endLocal,
      int? rateSnapshotCents,
      bool? isActive,
      String? createdAt,
      String? updatedAt,
    }) {
      return RecurringSchedule(
        id: id ?? testId,
        studentId: studentId ?? testStudentId,
        weekday: weekday ?? testWeekday,
        startLocal: startLocal ?? testStartLocal,
        endLocal: endLocal ?? testEndLocal,
        rateSnapshotCents: rateSnapshotCents ?? testRateSnapshotCents,
        isActive: isActive ?? testIsActive,
        createdAt: createdAt ?? testCreatedAt,
        updatedAt: updatedAt ?? testUpdatedAt,
      );
    }

    group('Constructor & Factory', () {
      test('should create RecurringSchedule with all required fields', () {
        final schedule = createTestSchedule();

        expect(schedule.id, testId);
        expect(schedule.studentId, testStudentId);
        expect(schedule.weekday, testWeekday);
        expect(schedule.startLocal, testStartLocal);
        expect(schedule.endLocal, testEndLocal);
        expect(schedule.rateSnapshotCents, testRateSnapshotCents);
        expect(schedule.isActive, testIsActive);
        expect(schedule.createdAt, testCreatedAt);
        expect(schedule.updatedAt, testUpdatedAt);
      });

      test('RecurringSchedule.create should generate timestamps automatically', () {
        final beforeCreate = DateTime.now();

        final schedule = RecurringSchedule.create(
          id: testId,
          studentId: testStudentId,
          weekday: testWeekday,
          startLocal: testStartLocal,
          endLocal: testEndLocal,
          rateSnapshotCents: testRateSnapshotCents,
        );

        final afterCreate = DateTime.now();
        final createdTime = DateTime.parse(schedule.createdAt);

        expect(schedule.id, testId);
        expect(schedule.isActive, true); // Default
        expect(createdTime.isAfter(beforeCreate.subtract(const Duration(seconds: 1))), true);
        expect(createdTime.isBefore(afterCreate.add(const Duration(seconds: 1))), true);
        expect(schedule.createdAt, schedule.updatedAt);
      });

      test('RecurringSchedule.create should allow custom isActive', () {
        final schedule = RecurringSchedule.create(
          id: testId,
          studentId: testStudentId,
          weekday: testWeekday,
          startLocal: testStartLocal,
          endLocal: testEndLocal,
          rateSnapshotCents: testRateSnapshotCents,
          isActive: false,
        );

        expect(schedule.isActive, false);
      });

      test('RecurringSchedule.create should validate weekday range', () {
        expect(
          () => RecurringSchedule.create(
            id: testId,
            studentId: testStudentId,
            weekday: 0, // Invalid
            startLocal: testStartLocal,
            endLocal: testEndLocal,
            rateSnapshotCents: testRateSnapshotCents,
          ),
          throwsA(isA<AssertionError>()),
        );

        expect(
          () => RecurringSchedule.create(
            id: testId,
            studentId: testStudentId,
            weekday: 8, // Invalid
            startLocal: testStartLocal,
            endLocal: testEndLocal,
            rateSnapshotCents: testRateSnapshotCents,
          ),
          throwsA(isA<AssertionError>()),
        );
      });

      test('RecurringSchedule.create should validate time format', () {
        expect(
          () => RecurringSchedule.create(
            id: testId,
            studentId: testStudentId,
            weekday: testWeekday,
            startLocal: '25:00', // Invalid hour
            endLocal: testEndLocal,
            rateSnapshotCents: testRateSnapshotCents,
          ),
          throwsA(isA<AssertionError>()),
        );

        expect(
          () => RecurringSchedule.create(
            id: testId,
            studentId: testStudentId,
            weekday: testWeekday,
            startLocal: testStartLocal,
            endLocal: '14:60', // Invalid minute
            rateSnapshotCents: testRateSnapshotCents,
          ),
          throwsA(isA<AssertionError>()),
        );

        expect(
          () => RecurringSchedule.create(
            id: testId,
            studentId: testStudentId,
            weekday: testWeekday,
            startLocal: '2:00', // Missing leading zero
            endLocal: testEndLocal,
            rateSnapshotCents: testRateSnapshotCents,
          ),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('JSON Serialization', () {
      test('should serialize to JSON correctly', () {
        final schedule = createTestSchedule();
        final json = schedule.toJson();

        expect(json['id'], testId);
        expect(json['studentId'], testStudentId);
        expect(json['weekday'], testWeekday);
        expect(json['startLocal'], testStartLocal);
        expect(json['endLocal'], testEndLocal);
        expect(json['rateSnapshotCents'], testRateSnapshotCents);
        expect(json['isActive'], testIsActive);
        expect(json['createdAt'], testCreatedAt);
        expect(json['updatedAt'], testUpdatedAt);
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'id': testId,
          'studentId': testStudentId,
          'weekday': testWeekday,
          'startLocal': testStartLocal,
          'endLocal': testEndLocal,
          'rateSnapshotCents': testRateSnapshotCents,
          'isActive': testIsActive,
          'createdAt': testCreatedAt,
          'updatedAt': testUpdatedAt,
        };

        final schedule = RecurringSchedule.fromJson(json);

        expect(schedule.id, testId);
        expect(schedule.studentId, testStudentId);
        expect(schedule.weekday, testWeekday);
        expect(schedule.startLocal, testStartLocal);
        expect(schedule.endLocal, testEndLocal);
        expect(schedule.rateSnapshotCents, testRateSnapshotCents);
        expect(schedule.isActive, testIsActive);
        expect(schedule.createdAt, testCreatedAt);
        expect(schedule.updatedAt, testUpdatedAt);
      });

      test('should complete JSON round-trip without data loss', () {
        final original = createTestSchedule();
        final json = original.toJson();
        final deserialized = RecurringSchedule.fromJson(json);

        expect(deserialized, original);
      });
    });

    group('copyWith', () {
      test('should copy with new weekday', () {
        final schedule = createTestSchedule();
        final updated = schedule.copyWith(weekday: 5);

        expect(updated.weekday, 5);
        expect(updated.id, schedule.id);
      });

      test('should copy with new isActive', () {
        final schedule = createTestSchedule();
        final updated = schedule.copyWith(isActive: false);

        expect(updated.isActive, false);
        expect(updated.id, schedule.id);
      });

      test('should copy with new rateSnapshotCents', () {
        final schedule = createTestSchedule();
        final updated = schedule.copyWith(rateSnapshotCents: 5000);

        expect(updated.rateSnapshotCents, 5000);
        expect(updated.id, schedule.id);
      });
    });

    group('update method', () {
      test('should update weekday and timestamp', () {
        final schedule = createTestSchedule();
        final updated = schedule.update(weekday: 5);

        expect(updated.weekday, 5);
        expect(updated.updatedAt, isNot(schedule.updatedAt));
      });

      test('should update startLocal and timestamp', () {
        final schedule = createTestSchedule();
        final updated = schedule.update(startLocal: '16:00');

        expect(updated.startLocal, '16:00');
        expect(updated.updatedAt, isNot(schedule.updatedAt));
      });

      test('should update endLocal and timestamp', () {
        final schedule = createTestSchedule();
        final updated = schedule.update(endLocal: '17:00');

        expect(updated.endLocal, '17:00');
        expect(updated.updatedAt, isNot(schedule.updatedAt));
      });

      test('should update rateSnapshotCents and timestamp', () {
        final schedule = createTestSchedule();
        final updated = schedule.update(rateSnapshotCents: 5000);

        expect(updated.rateSnapshotCents, 5000);
        expect(updated.updatedAt, isNot(schedule.updatedAt));
      });

      test('should update isActive and timestamp', () {
        final schedule = createTestSchedule();
        final updated = schedule.update(isActive: false);

        expect(updated.isActive, false);
        expect(updated.updatedAt, isNot(schedule.updatedAt));
      });

      test('should validate weekday in update', () {
        final schedule = createTestSchedule();
        
        expect(
          () => schedule.update(weekday: 0),
          throwsA(isA<AssertionError>()),
        );
      });

      test('should validate time format in update', () {
        final schedule = createTestSchedule();
        
        expect(
          () => schedule.update(startLocal: '25:00'),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('Status Methods', () {
      test('activate should set isActive to true', () {
        final schedule = createTestSchedule(isActive: false);
        final updated = schedule.activate();

        expect(updated.isActive, true);
        expect(updated.updatedAt, isNot(schedule.updatedAt));
      });

      test('deactivate should set isActive to false', () {
        final schedule = createTestSchedule(isActive: true);
        final updated = schedule.deactivate();

        expect(updated.isActive, false);
        expect(updated.updatedAt, isNot(schedule.updatedAt));
      });
    });

    group('Computed Properties', () {
      test('rateSnapshotDollars should convert cents to dollars', () {
        final schedule = createTestSchedule(rateSnapshotCents: 4000);
        expect(schedule.rateSnapshotDollars, 40.0);
      });

      test('weekdayName should return correct day names', () {
        expect(createTestSchedule(weekday: 1).weekdayName, 'Monday');
        expect(createTestSchedule(weekday: 2).weekdayName, 'Tuesday');
        expect(createTestSchedule(weekday: 3).weekdayName, 'Wednesday');
        expect(createTestSchedule(weekday: 4).weekdayName, 'Thursday');
        expect(createTestSchedule(weekday: 5).weekdayName, 'Friday');
        expect(createTestSchedule(weekday: 6).weekdayName, 'Saturday');
        expect(createTestSchedule(weekday: 7).weekdayName, 'Sunday');
      });

      test('weekdayName should return "Invalid" for out-of-range values', () {
        expect(createTestSchedule(weekday: 0).weekdayName, 'Invalid');
        expect(createTestSchedule(weekday: 8).weekdayName, 'Invalid');
      });

      test('weekdayShort should return correct short names', () {
        expect(createTestSchedule(weekday: 1).weekdayShort, 'Mon');
        expect(createTestSchedule(weekday: 2).weekdayShort, 'Tue');
        expect(createTestSchedule(weekday: 3).weekdayShort, 'Wed');
        expect(createTestSchedule(weekday: 4).weekdayShort, 'Thu');
        expect(createTestSchedule(weekday: 5).weekdayShort, 'Fri');
        expect(createTestSchedule(weekday: 6).weekdayShort, 'Sat');
        expect(createTestSchedule(weekday: 7).weekdayShort, 'Sun');
      });

      test('weekdayShort should return "N/A" for out-of-range values', () {
        expect(createTestSchedule(weekday: 0).weekdayShort, 'N/A');
        expect(createTestSchedule(weekday: 8).weekdayShort, 'N/A');
      });

      test('formattedTimeRange should format time correctly', () {
        final schedule = createTestSchedule(
          startLocal: '14:00',
          endLocal: '15:30',
        );
        expect(schedule.formattedTimeRange, '2:00 PM - 3:30 PM');
      });

      test('formattedTimeRange should handle AM times', () {
        final schedule = createTestSchedule(
          startLocal: '09:00',
          endLocal: '10:30',
        );
        expect(schedule.formattedTimeRange, '9:00 AM - 10:30 AM');
      });

      test('formattedTimeRange should handle midnight', () {
        final schedule = createTestSchedule(
          startLocal: '00:00',
          endLocal: '01:00',
        );
        expect(schedule.formattedTimeRange, '12:00 AM - 1:00 AM');
      });

      test('formattedTimeRange should handle noon', () {
        final schedule = createTestSchedule(
          startLocal: '12:00',
          endLocal: '13:00',
        );
        expect(schedule.formattedTimeRange, '12:00 PM - 1:00 PM');
      });

      test('durationHours should calculate correct duration', () {
        final schedule = createTestSchedule(
          startLocal: '14:00',
          endLocal: '15:30',
        );
        expect(schedule.durationHours, 1.5);
      });

      test('durationHours should handle different durations', () {
        expect(createTestSchedule(startLocal: '09:00', endLocal: '10:00').durationHours, 1.0);
        expect(createTestSchedule(startLocal: '09:00', endLocal: '11:00').durationHours, 2.0);
        expect(createTestSchedule(startLocal: '09:00', endLocal: '09:30').durationHours, 0.5);
      });

      test('estimatedAmountCents should calculate correctly', () {
        final schedule = createTestSchedule(
          startLocal: '14:00',
          endLocal: '15:30', // 1.5 hours
          rateSnapshotCents: 4000, // $40/hr
        );
        expect(schedule.estimatedAmountCents, 6000); // 1.5 × 4000 = 6000
      });

      test('estimatedAmountDollars should convert cents to dollars', () {
        final schedule = createTestSchedule(
          startLocal: '14:00',
          endLocal: '15:30', // 1.5 hours
          rateSnapshotCents: 4000, // $40/hr
        );
        expect(schedule.estimatedAmountDollars, 60.0); // $60
      });
    });

    group('Equality', () {
      test('should be equal when all fields match', () {
        final schedule1 = createTestSchedule();
        final schedule2 = createTestSchedule();

        expect(schedule1, schedule2);
      });

      test('should not be equal when id differs', () {
        final schedule1 = createTestSchedule(id: 'id-1');
        final schedule2 = createTestSchedule(id: 'id-2');

        expect(schedule1, isNot(schedule2));
      });

      test('should not be equal when weekday differs', () {
        final schedule1 = createTestSchedule(weekday: 1);
        final schedule2 = createTestSchedule(weekday: 2);

        expect(schedule1, isNot(schedule2));
      });

      test('should not be equal when isActive differs', () {
        final schedule1 = createTestSchedule(isActive: true);
        final schedule2 = createTestSchedule(isActive: false);

        expect(schedule1, isNot(schedule2));
      });
    });

    group('Edge Cases', () {
      test('should handle all valid weekdays (1-7)', () {
        for (var day = 1; day <= 7; day++) {
          final schedule = RecurringSchedule.create(
            id: testId,
            studentId: testStudentId,
            weekday: day,
            startLocal: testStartLocal,
            endLocal: testEndLocal,
            rateSnapshotCents: testRateSnapshotCents,
          );
          expect(schedule.weekday, day);
        }
      });

      test('should handle various time formats', () {
        final times = ['00:00', '06:30', '12:00', '18:45', '23:59'];
        for (final time in times) {
          final schedule = RecurringSchedule.create(
            id: testId,
            studentId: testStudentId,
            weekday: testWeekday,
            startLocal: time,
            endLocal: '23:59',
            rateSnapshotCents: testRateSnapshotCents,
          );
          expect(schedule.startLocal, time);
        }
      });

      test('should handle very short sessions (15 minutes)', () {
        final schedule = createTestSchedule(
          startLocal: '14:00',
          endLocal: '14:15',
          rateSnapshotCents: 4000,
        );
        expect(schedule.durationHours, 0.25);
        expect(schedule.estimatedAmountCents, 1000); // 0.25 × 4000
      });

      test('should handle very long sessions (8 hours)', () {
        final schedule = createTestSchedule(
          startLocal: '09:00',
          endLocal: '17:00',
          rateSnapshotCents: 4000,
        );
        expect(schedule.durationHours, 8.0);
        expect(schedule.estimatedAmountCents, 32000); // 8 × 4000
      });
    });
  });
}

