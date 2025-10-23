import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:tutor_zone/core/debug_log/logger.dart';
import 'package:tutor_zone/features/balance/models/data/balance_change.dart';
import 'package:tutor_zone/features/balance/models/data_sources/balance_change_local_data_source.dart';

void main() {
  group('BalanceChangeLocalDataSource Tests', () {
    late BalanceChangeLocalDataSource dataSource;

    setUpAll(() {
      // Initialize Talker for logging in tests
      initializeTalker();
    });

    setUp(() async {
      // Create in-memory database for testing (use unique name for each test)
      final db = await databaseFactoryMemory.openDatabase('test_${DateTime.now().millisecondsSinceEpoch}.db');
      dataSource = BalanceChangeLocalDataSource(db);
    });

    // Helper to create test balance change
    BalanceChange createTestBalanceChange({
      String id = 'balance-1',
      String studentId = 'student-1',
      int amountCents = 5000,
      bool isPayment = true,
    }) {
      if (isPayment) {
        return BalanceChange.payment(
          id: id,
          studentId: studentId,
          amountCents: amountCents,
        );
      } else {
        return BalanceChange.adjustment(
          id: id,
          studentId: studentId,
          amountCents: amountCents,
        );
      }
    }

    group('CRUD Operations', () {
      test('create should save balance change to database', () async {
        // Arrange
        final balanceChange = createTestBalanceChange();

        // Act
        final result = await dataSource.create(balanceChange);

        // Assert
        expect(result, balanceChange);
        final retrieved = await dataSource.getById(balanceChange.id);
        expect(retrieved, isNotNull);
        expect(retrieved!.id, balanceChange.id);
        expect(retrieved.studentId, balanceChange.studentId);
        expect(retrieved.amountCents, balanceChange.amountCents);
      });

      test('getById should return balance change when exists', () async {
        // Arrange
        final balanceChange = createTestBalanceChange();
        await dataSource.create(balanceChange);

        // Act
        final result = await dataSource.getById(balanceChange.id);

        // Assert
        expect(result, isNotNull);
        expect(result!.id, balanceChange.id);
      });

      test('getById should return null when balance change does not exist', () async {
        // Act
        final result = await dataSource.getById('non-existent');

        // Assert
        expect(result, isNull);
      });

      test('getAll should return all balance changes', () async {
        // Arrange
        final bc1 = createTestBalanceChange();
        final bc2 = createTestBalanceChange(id: 'balance-2');
        final bc3 = createTestBalanceChange(id: 'balance-3');
        await dataSource.create(bc1);
        await dataSource.create(bc2);
        await dataSource.create(bc3);

        // Act
        final result = await dataSource.getAll();

        // Assert
        expect(result.length, 3);
        expect(result.map((b) => b.id), containsAll(['balance-1', 'balance-2', 'balance-3']));
      });

      test('delete should remove balance change from database', () async {
        // Arrange
        final balanceChange = createTestBalanceChange();
        await dataSource.create(balanceChange);

        // Act
        await dataSource.delete(balanceChange.id);

        // Assert
        final retrieved = await dataSource.getById(balanceChange.id);
        expect(retrieved, isNull);
      });

      test('deleteByStudentId should remove all balance changes for student', () async {
        // Arrange
        await dataSource.create(createTestBalanceChange());
        await dataSource.create(createTestBalanceChange(id: 'balance-2'));
        await dataSource.create(createTestBalanceChange(id: 'balance-3', studentId: 'student-2'));

        // Act
        await dataSource.deleteByStudentId('student-1');

        // Assert
        final all = await dataSource.getAll();
        expect(all.length, 1);
        expect(all.first.id, 'balance-3');
      });

      test('deleteAll should remove all balance changes', () async {
        // Arrange
        await dataSource.create(createTestBalanceChange());
        await dataSource.create(createTestBalanceChange(id: 'balance-2'));
        await dataSource.create(createTestBalanceChange(id: 'balance-3'));

        // Act
        await dataSource.deleteAll();

        // Assert
        final result = await dataSource.getAll();
        expect(result, isEmpty);
      });
    });

    group('Query Operations', () {
      test('getByStudentId should return balance changes for specific student sorted by timestamp', () async {
        // Arrange
        await Future.delayed(const Duration(milliseconds: 10));
        await dataSource.create(createTestBalanceChange());
        await Future.delayed(const Duration(milliseconds: 10));
        await dataSource.create(createTestBalanceChange(id: 'balance-2'));
        await Future.delayed(const Duration(milliseconds: 10));
        await dataSource.create(createTestBalanceChange(id: 'balance-3', studentId: 'student-2'));

        // Act
        final result = await dataSource.getByStudentId('student-1');

        // Assert
        expect(result.length, 2);
        expect(result.map((b) => b.id), containsAll(['balance-1', 'balance-2']));
        // Most recent first (descending)
        expect(result[0].id, 'balance-2');
        expect(result[1].id, 'balance-1');
      });

      test('getByStudentIdAscending should return balance changes sorted oldest first', () async {
        // Arrange
        await Future.delayed(const Duration(milliseconds: 10));
        await dataSource.create(createTestBalanceChange());
        await Future.delayed(const Duration(milliseconds: 10));
        await dataSource.create(createTestBalanceChange(id: 'balance-2'));
        await Future.delayed(const Duration(milliseconds: 10));
        await dataSource.create(createTestBalanceChange(id: 'balance-3'));

        // Act
        final result = await dataSource.getByStudentIdAscending('student-1');

        // Assert
        expect(result.length, 3);
        // Oldest first (ascending)
        expect(result[0].id, 'balance-1');
        expect(result[1].id, 'balance-2');
        expect(result[2].id, 'balance-3');
      });

      test('getTotalAmountByStudentId should return sum of all balance changes', () async {
        // Arrange
        await dataSource.create(createTestBalanceChange());
        await dataSource.create(createTestBalanceChange(id: 'balance-2', amountCents: 3000));
        await dataSource.create(createTestBalanceChange(id: 'balance-3', amountCents: -2000, isPayment: false));
        await dataSource.create(createTestBalanceChange(id: 'balance-4', studentId: 'student-2', amountCents: 1000));

        // Act
        final result = await dataSource.getTotalAmountByStudentId('student-1');

        // Assert
        expect(result, 6000); // 5000 + 3000 - 2000
      });

      test('getTotalAmountByStudentId should return 0 when no balance changes exist', () async {
        // Act
        final result = await dataSource.getTotalAmountByStudentId('student-1');

        // Assert
        expect(result, 0);
      });
    });

    group('Utility Operations', () {
      test('exists should return true when balance change exists', () async {
        // Arrange
        final balanceChange = createTestBalanceChange();
        await dataSource.create(balanceChange);

        // Act
        final result = await dataSource.exists(balanceChange.id);

        // Assert
        expect(result, true);
      });

      test('exists should return false when balance change does not exist', () async {
        // Act
        final result = await dataSource.exists('non-existent');

        // Assert
        expect(result, false);
      });

      test('count should return correct number of balance changes', () async {
        // Arrange
        await dataSource.create(createTestBalanceChange());
        await dataSource.create(createTestBalanceChange(id: 'balance-2'));
        await dataSource.create(createTestBalanceChange(id: 'balance-3'));

        // Act
        final result = await dataSource.count();

        // Assert
        expect(result, 3);
      });

      test('countByStudentId should return correct number of balance changes for student', () async {
        // Arrange
        await dataSource.create(createTestBalanceChange());
        await dataSource.create(createTestBalanceChange(id: 'balance-2'));
        await dataSource.create(createTestBalanceChange(id: 'balance-3', studentId: 'student-2'));

        // Act
        final result = await dataSource.countByStudentId('student-1');

        // Assert
        expect(result, 2);
      });
    });

    group('Stream Operations', () {
      test('watchAll should emit all balance changes sorted by timestamp', () async {
        // Arrange
        await Future.delayed(const Duration(milliseconds: 10));
        await dataSource.create(createTestBalanceChange());
        await Future.delayed(const Duration(milliseconds: 10));
        await dataSource.create(createTestBalanceChange(id: 'balance-2'));
        await Future.delayed(const Duration(milliseconds: 10));
        await dataSource.create(createTestBalanceChange(id: 'balance-3'));

        // Act
        final stream = dataSource.watchAll();

        // Assert
        await expectLater(
          stream.first,
          completion(predicate<List<BalanceChange>>((changes) {
            return changes.length == 3 &&
                changes[0].id == 'balance-3' && // Most recent first
                changes[1].id == 'balance-2' &&
                changes[2].id == 'balance-1';
          })),
        );
      });

      test('watchById should emit balance change when exists', () async {
        // Arrange
        final balanceChange = createTestBalanceChange();
        await dataSource.create(balanceChange);

        // Act
        final stream = dataSource.watchById(balanceChange.id);

        // Assert
        await expectLater(
          stream.first,
          completion(predicate<BalanceChange?>((b) => b != null && b.id == balanceChange.id)),
        );
      });

      test('watchByStudentId should emit balance changes for specific student', () async {
        // Arrange
        await dataSource.create(createTestBalanceChange());
        await dataSource.create(createTestBalanceChange(id: 'balance-2'));
        await dataSource.create(createTestBalanceChange(id: 'balance-3', studentId: 'student-2'));

        // Act
        final stream = dataSource.watchByStudentId('student-1');

        // Assert
        await expectLater(
          stream.first,
          completion(predicate<List<BalanceChange>>((changes) {
            return changes.length == 2 &&
                changes.every((b) => b.studentId == 'student-1');
          })),
        );
      });
    });
  });
}

