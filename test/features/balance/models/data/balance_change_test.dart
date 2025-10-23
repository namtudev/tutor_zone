import 'package:flutter_test/flutter_test.dart';
import 'package:tutor_zone/features/balance/models/data/balance_change.dart';

void main() {
  group('BalanceChange Model Tests', () {
    // Test data
    const testId = 'test-balance-change-id-123';
    const testStudentId = 'test-student-id-456';
    const testAmountCents = 8000; // $80.00 payment
    const testCreatedAt = '2024-01-15T10:00:00.000Z';

    BalanceChange createTestBalanceChange({
      String? id,
      String? studentId,
      int? amountCents,
      String? createdAt,
    }) {
      return BalanceChange(
        id: id ?? testId,
        studentId: studentId ?? testStudentId,
        amountCents: amountCents ?? testAmountCents,
        createdAt: createdAt ?? testCreatedAt,
      );
    }

    group('Constructor & Factory', () {
      test('should create BalanceChange with all required fields', () {
        final balanceChange = createTestBalanceChange();

        expect(balanceChange.id, testId);
        expect(balanceChange.studentId, testStudentId);
        expect(balanceChange.amountCents, testAmountCents);
        expect(balanceChange.createdAt, testCreatedAt);
      });

      test('BalanceChange.create should generate timestamp automatically', () {
        final beforeCreate = DateTime.now();

        final balanceChange = BalanceChange.create(
          id: testId,
          studentId: testStudentId,
          amountCents: testAmountCents,
        );

        final afterCreate = DateTime.now();
        final createdTime = DateTime.parse(balanceChange.createdAt);

        expect(balanceChange.id, testId);
        expect(balanceChange.studentId, testStudentId);
        expect(balanceChange.amountCents, testAmountCents);
        expect(createdTime.isAfter(beforeCreate.subtract(const Duration(seconds: 1))), true);
        expect(createdTime.isBefore(afterCreate.add(const Duration(seconds: 1))), true);
      });

      test('BalanceChange.payment should create payment with positive amount', () {
        final balanceChange = BalanceChange.payment(
          id: testId,
          studentId: testStudentId,
          amountCents: 5000,
        );

        expect(balanceChange.amountCents, 5000);
        expect(balanceChange.isPayment, true);
        expect(balanceChange.isAdjustment, false);
      });

      test('BalanceChange.payment should assert positive amount', () {
        expect(
          () => BalanceChange.payment(
            id: testId,
            studentId: testStudentId,
            amountCents: -1000, // Negative amount should fail
          ),
          throwsA(isA<AssertionError>()),
        );
      });

      test('BalanceChange.adjustment should create adjustment with negative amount', () {
        final balanceChange = BalanceChange.adjustment(
          id: testId,
          studentId: testStudentId,
          amountCents: -3000,
        );

        expect(balanceChange.amountCents, -3000);
        expect(balanceChange.isPayment, false);
        expect(balanceChange.isAdjustment, true);
      });

      test('BalanceChange.adjustment should assert negative amount', () {
        expect(
          () => BalanceChange.adjustment(
            id: testId,
            studentId: testStudentId,
            amountCents: 1000, // Positive amount should fail
          ),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('JSON Serialization', () {
      test('should serialize to JSON correctly', () {
        final balanceChange = createTestBalanceChange();
        final json = balanceChange.toJson();

        expect(json['id'], testId);
        expect(json['studentId'], testStudentId);
        expect(json['amountCents'], testAmountCents);
        expect(json['createdAt'], testCreatedAt);
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'id': testId,
          'studentId': testStudentId,
          'amountCents': testAmountCents,
          'createdAt': testCreatedAt,
        };

        final balanceChange = BalanceChange.fromJson(json);

        expect(balanceChange.id, testId);
        expect(balanceChange.studentId, testStudentId);
        expect(balanceChange.amountCents, testAmountCents);
        expect(balanceChange.createdAt, testCreatedAt);
      });

      test('should complete JSON round-trip without data loss', () {
        final original = createTestBalanceChange();
        final json = original.toJson();
        final deserialized = BalanceChange.fromJson(json);

        expect(deserialized, original);
      });

      test('should serialize negative amounts correctly', () {
        final balanceChange = createTestBalanceChange(amountCents: -5000);
        final json = balanceChange.toJson();

        expect(json['amountCents'], -5000);
      });
    });

    group('copyWith', () {
      test('should copy with new amountCents', () {
        final balanceChange = createTestBalanceChange();
        final updated = balanceChange.copyWith(amountCents: 10000);

        expect(updated.amountCents, 10000);
        expect(updated.id, balanceChange.id);
        expect(updated.studentId, balanceChange.studentId);
      });

      test('should copy with new studentId', () {
        final balanceChange = createTestBalanceChange();
        final updated = balanceChange.copyWith(studentId: 'new-student-id');

        expect(updated.studentId, 'new-student-id');
        expect(updated.amountCents, balanceChange.amountCents);
      });
    });

    group('Computed Properties', () {
      test('amountDollars should convert cents to dollars', () {
        final balanceChange = createTestBalanceChange(amountCents: 8000);
        expect(balanceChange.amountDollars, 80.0);
      });

      test('amountDollars should handle negative amounts', () {
        final balanceChange = createTestBalanceChange(amountCents: -5000);
        expect(balanceChange.amountDollars, -50.0);
      });

      test('isPayment should be true for positive amounts', () {
        final balanceChange = createTestBalanceChange(amountCents: 1000);
        expect(balanceChange.isPayment, true);
      });

      test('isPayment should be false for negative amounts', () {
        final balanceChange = createTestBalanceChange(amountCents: -1000);
        expect(balanceChange.isPayment, false);
      });

      test('isPayment should be false for zero amount', () {
        final balanceChange = createTestBalanceChange(amountCents: 0);
        expect(balanceChange.isPayment, false);
      });

      test('isAdjustment should be true for negative amounts', () {
        final balanceChange = createTestBalanceChange(amountCents: -1000);
        expect(balanceChange.isAdjustment, true);
      });

      test('isAdjustment should be false for positive amounts', () {
        final balanceChange = createTestBalanceChange(amountCents: 1000);
        expect(balanceChange.isAdjustment, false);
      });

      test('isAdjustment should be false for zero amount', () {
        final balanceChange = createTestBalanceChange(amountCents: 0);
        expect(balanceChange.isAdjustment, false);
      });

      test('changeType should return "Payment" for positive amounts', () {
        final balanceChange = createTestBalanceChange(amountCents: 5000);
        expect(balanceChange.changeType, 'Payment');
      });

      test('changeType should return "Adjustment" for negative amounts', () {
        final balanceChange = createTestBalanceChange(amountCents: -3000);
        expect(balanceChange.changeType, 'Adjustment');
      });

      test('changeType should return "No Change" for zero amount', () {
        final balanceChange = createTestBalanceChange(amountCents: 0);
        expect(balanceChange.changeType, 'No Change');
      });
    });

    group('Equality', () {
      test('should be equal when all fields match', () {
        final balanceChange1 = createTestBalanceChange();
        final balanceChange2 = createTestBalanceChange();

        expect(balanceChange1, balanceChange2);
      });

      test('should not be equal when id differs', () {
        final balanceChange1 = createTestBalanceChange(id: 'id-1');
        final balanceChange2 = createTestBalanceChange(id: 'id-2');

        expect(balanceChange1, isNot(balanceChange2));
      });

      test('should not be equal when studentId differs', () {
        final balanceChange1 = createTestBalanceChange(studentId: 'student-1');
        final balanceChange2 = createTestBalanceChange(studentId: 'student-2');

        expect(balanceChange1, isNot(balanceChange2));
      });

      test('should not be equal when amountCents differs', () {
        final balanceChange1 = createTestBalanceChange(amountCents: 1000);
        final balanceChange2 = createTestBalanceChange(amountCents: 2000);

        expect(balanceChange1, isNot(balanceChange2));
      });

      test('should not be equal when createdAt differs', () {
        final balanceChange1 = createTestBalanceChange(createdAt: '2024-01-15T10:00:00.000Z');
        final balanceChange2 = createTestBalanceChange(createdAt: '2024-01-16T10:00:00.000Z');

        expect(balanceChange1, isNot(balanceChange2));
      });
    });

    group('Edge Cases', () {
      test('should handle very large positive amounts', () {
        final balanceChange = createTestBalanceChange(amountCents: 1000000); // $10,000
        expect(balanceChange.amountDollars, 10000.0);
        expect(balanceChange.isPayment, true);
      });

      test('should handle very large negative amounts', () {
        final balanceChange = createTestBalanceChange(amountCents: -1000000); // -$10,000
        expect(balanceChange.amountDollars, -10000.0);
        expect(balanceChange.isAdjustment, true);
      });

      test('should handle zero amount', () {
        final balanceChange = createTestBalanceChange(amountCents: 0);
        expect(balanceChange.amountDollars, 0.0);
        expect(balanceChange.isPayment, false);
        expect(balanceChange.isAdjustment, false);
        expect(balanceChange.changeType, 'No Change');
      });
    });
  });
}

