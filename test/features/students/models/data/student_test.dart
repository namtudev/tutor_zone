import 'package:flutter_test/flutter_test.dart';
import 'package:tutor_zone/features/students/models/data/student.dart';

void main() {
  group('Student Model Tests', () {
    // Test data
    const testId = 'test-student-id-123';
    const testName = 'John Doe';
    const testHourlyRateCents = 4000; // $40.00/hr
    const testBalanceCents = 8000; // $80.00 credit
    const testCreatedAt = '2024-01-15T10:00:00.000Z';
    const testUpdatedAt = '2024-01-15T10:00:00.000Z';

    Student createTestStudent({
      String? id,
      String? name,
      int? hourlyRateCents,
      int? balanceCents,
      String? createdAt,
      String? updatedAt,
    }) {
      return Student(
        id: id ?? testId,
        name: name ?? testName,
        hourlyRateCents: hourlyRateCents ?? testHourlyRateCents,
        balanceCents: balanceCents ?? testBalanceCents,
        createdAt: createdAt ?? testCreatedAt,
        updatedAt: updatedAt ?? testUpdatedAt,
      );
    }

    group('Constructor & Factory', () {
      test('should create Student with all required fields', () {
        final student = createTestStudent();

        expect(student.id, testId);
        expect(student.name, testName);
        expect(student.hourlyRateCents, testHourlyRateCents);
        expect(student.balanceCents, testBalanceCents);
        expect(student.createdAt, testCreatedAt);
        expect(student.updatedAt, testUpdatedAt);
      });

      test('Student.create should generate timestamps automatically', () {
        final beforeCreate = DateTime.now();
        
        final student = Student.create(
          id: testId,
          name: testName,
          hourlyRateCents: testHourlyRateCents,
          balanceCents: testBalanceCents,
        );

        final afterCreate = DateTime.now();
        final createdTime = DateTime.parse(student.createdAt);

        expect(student.id, testId);
        expect(student.name, testName);
        expect(student.hourlyRateCents, testHourlyRateCents);
        expect(student.balanceCents, testBalanceCents);
        expect(createdTime.isAfter(beforeCreate.subtract(const Duration(seconds: 1))), true);
        expect(createdTime.isBefore(afterCreate.add(const Duration(seconds: 1))), true);
        expect(student.createdAt, student.updatedAt);
      });

      test('Student.create should default balanceCents to 0', () {
        final student = Student.create(
          id: testId,
          name: testName,
          hourlyRateCents: testHourlyRateCents,
        );

        expect(student.balanceCents, 0);
      });
    });

    group('JSON Serialization', () {
      test('should serialize to JSON correctly', () {
        final student = createTestStudent();
        final json = student.toJson();

        expect(json['id'], testId);
        expect(json['name'], testName);
        expect(json['hourlyRateCents'], testHourlyRateCents);
        expect(json['balanceCents'], testBalanceCents);
        expect(json['createdAt'], testCreatedAt);
        expect(json['updatedAt'], testUpdatedAt);
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'id': testId,
          'name': testName,
          'hourlyRateCents': testHourlyRateCents,
          'balanceCents': testBalanceCents,
          'createdAt': testCreatedAt,
          'updatedAt': testUpdatedAt,
        };

        final student = Student.fromJson(json);

        expect(student.id, testId);
        expect(student.name, testName);
        expect(student.hourlyRateCents, testHourlyRateCents);
        expect(student.balanceCents, testBalanceCents);
        expect(student.createdAt, testCreatedAt);
        expect(student.updatedAt, testUpdatedAt);
      });

      test('should complete JSON round-trip without data loss', () {
        final original = createTestStudent();
        final json = original.toJson();
        final deserialized = Student.fromJson(json);

        expect(deserialized, original);
      });
    });

    group('copyWith', () {
      test('should copy with new name', () {
        final student = createTestStudent();
        final updated = student.copyWith(name: 'Jane Smith');

        expect(updated.name, 'Jane Smith');
        expect(updated.id, student.id);
        expect(updated.hourlyRateCents, student.hourlyRateCents);
        expect(updated.balanceCents, student.balanceCents);
      });

      test('should copy with new hourlyRateCents', () {
        final student = createTestStudent();
        final updated = student.copyWith(hourlyRateCents: 5000);

        expect(updated.hourlyRateCents, 5000);
        expect(updated.name, student.name);
      });

      test('should copy with new balanceCents', () {
        final student = createTestStudent();
        final updated = student.copyWith(balanceCents: -2000);

        expect(updated.balanceCents, -2000);
        expect(updated.name, student.name);
      });

      test('should copy with multiple fields', () {
        final student = createTestStudent();
        final updated = student.copyWith(
          name: 'Jane Smith',
          hourlyRateCents: 5000,
          balanceCents: -2000,
        );

        expect(updated.name, 'Jane Smith');
        expect(updated.hourlyRateCents, 5000);
        expect(updated.balanceCents, -2000);
      });
    });

    group('update method', () {
      test('should update name and timestamp', () {
        final student = createTestStudent();
        final beforeUpdate = DateTime.now();
        
        final updated = student.update(name: 'Jane Smith');
        
        final afterUpdate = DateTime.now();
        final updatedTime = DateTime.parse(updated.updatedAt);

        expect(updated.name, 'Jane Smith');
        expect(updated.id, student.id);
        expect(updated.createdAt, student.createdAt);
        expect(updated.updatedAt, isNot(student.updatedAt));
        expect(updatedTime.isAfter(beforeUpdate.subtract(const Duration(seconds: 1))), true);
        expect(updatedTime.isBefore(afterUpdate.add(const Duration(seconds: 1))), true);
      });

      test('should update hourlyRateCents and timestamp', () {
        final student = createTestStudent();
        final updated = student.update(hourlyRateCents: 5000);

        expect(updated.hourlyRateCents, 5000);
        expect(updated.updatedAt, isNot(student.updatedAt));
      });

      test('should update balanceCents and timestamp', () {
        final student = createTestStudent();
        final updated = student.update(balanceCents: -2000);

        expect(updated.balanceCents, -2000);
        expect(updated.updatedAt, isNot(student.updatedAt));
      });

      test('should update multiple fields and timestamp', () {
        final student = createTestStudent();
        final updated = student.update(
          name: 'Jane Smith',
          hourlyRateCents: 5000,
          balanceCents: -2000,
        );

        expect(updated.name, 'Jane Smith');
        expect(updated.hourlyRateCents, 5000);
        expect(updated.balanceCents, -2000);
        expect(updated.updatedAt, isNot(student.updatedAt));
      });

      test('should preserve original values when no parameters provided', () {
        final student = createTestStudent();
        final updated = student.update();

        expect(updated.name, student.name);
        expect(updated.hourlyRateCents, student.hourlyRateCents);
        expect(updated.balanceCents, student.balanceCents);
        expect(updated.updatedAt, isNot(student.updatedAt));
      });
    });

    group('Computed Properties', () {
      test('hourlyRateDollars should convert cents to dollars', () {
        final student = createTestStudent(hourlyRateCents: 4000);
        expect(student.hourlyRateDollars, 40.0);
      });

      test('balanceDollars should convert cents to dollars', () {
        final student = createTestStudent(balanceCents: 8000);
        expect(student.balanceDollars, 80.0);
      });

      test('balanceDollars should handle negative balance', () {
        final student = createTestStudent(balanceCents: -5000);
        expect(student.balanceDollars, -50.0);
      });

      test('hasNegativeBalance should be true when balance < 0', () {
        final student = createTestStudent(balanceCents: -1000);
        expect(student.hasNegativeBalance, true);
      });

      test('hasNegativeBalance should be false when balance >= 0', () {
        final student1 = createTestStudent(balanceCents: 0);
        final student2 = createTestStudent(balanceCents: 1000);
        
        expect(student1.hasNegativeBalance, false);
        expect(student2.hasNegativeBalance, false);
      });

      test('hasPositiveBalance should be true when balance > 0', () {
        final student = createTestStudent(balanceCents: 1000);
        expect(student.hasPositiveBalance, true);
      });

      test('hasPositiveBalance should be false when balance <= 0', () {
        final student1 = createTestStudent(balanceCents: 0);
        final student2 = createTestStudent(balanceCents: -1000);
        
        expect(student1.hasPositiveBalance, false);
        expect(student2.hasPositiveBalance, false);
      });

      test('isBalanced should be true when balance == 0', () {
        final student = createTestStudent(balanceCents: 0);
        expect(student.isBalanced, true);
      });

      test('isBalanced should be false when balance != 0', () {
        final student1 = createTestStudent(balanceCents: 1000);
        final student2 = createTestStudent(balanceCents: -1000);
        
        expect(student1.isBalanced, false);
        expect(student2.isBalanced, false);
      });
    });

    group('balanceStatus', () {
      test('should return "Balanced" when balance is 0', () {
        final student = createTestStudent(
          balanceCents: 0,
          hourlyRateCents: 4000,
        );
        
        expect(student.balanceStatus, 'Balanced');
      });

      test('should return hours owed when balance is negative', () {
        final student = createTestStudent(
          balanceCents: -8000, // -$80.00
          hourlyRateCents: 4000, // $40.00/hr
        );
        
        expect(student.balanceStatus, '2.0 hrs owed');
      });

      test('should return hours credit when balance is positive', () {
        final student = createTestStudent(
          balanceCents: 12000, // $120.00
          hourlyRateCents: 4000, // $40.00/hr
        );
        
        expect(student.balanceStatus, '3.0 hrs credit');
      });

      test('should handle fractional hours for negative balance', () {
        final student = createTestStudent(
          balanceCents: -6000, // -$60.00
          hourlyRateCents: 4000, // $40.00/hr
        );
        
        expect(student.balanceStatus, '1.5 hrs owed');
      });

      test('should handle fractional hours for positive balance', () {
        final student = createTestStudent(
          balanceCents: 6000, // $60.00
          hourlyRateCents: 4000, // $40.00/hr
        );
        
        expect(student.balanceStatus, '1.5 hrs credit');
      });
    });

    group('Equality', () {
      test('should be equal when all fields match', () {
        final student1 = createTestStudent();
        final student2 = createTestStudent();

        expect(student1, student2);
      });

      test('should not be equal when id differs', () {
        final student1 = createTestStudent(id: 'id-1');
        final student2 = createTestStudent(id: 'id-2');

        expect(student1, isNot(student2));
      });

      test('should not be equal when name differs', () {
        final student1 = createTestStudent(name: 'John');
        final student2 = createTestStudent(name: 'Jane');

        expect(student1, isNot(student2));
      });

      test('should not be equal when balanceCents differs', () {
        final student1 = createTestStudent(balanceCents: 1000);
        final student2 = createTestStudent(balanceCents: 2000);

        expect(student1, isNot(student2));
      });
    });
  });
}

