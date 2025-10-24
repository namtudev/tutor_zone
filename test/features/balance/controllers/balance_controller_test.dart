import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tutor_zone/core/debug_log/logger.dart';
import 'package:tutor_zone/features/balance/controllers/balance_controller.dart';
import 'package:tutor_zone/features/balance/domain/allocation_service.dart';
import 'package:tutor_zone/features/balance/models/data/balance_change.dart';
import 'package:tutor_zone/features/balance/models/repositories/balance_change_repository.dart';
import 'package:tutor_zone/features/balance/models/repositories/ledger_repository.dart';
import 'package:tutor_zone/features/students/models/data/student.dart';
import 'package:tutor_zone/features/students/models/repositories/student_repository.dart';

// Generate mocks using Mockito
@GenerateNiceMocks([
  MockSpec<BalanceChangeRepository>(),
  MockSpec<StudentRepository>(),
  MockSpec<LedgerRepository>(),
  MockSpec<AllocationService>(),
])
import 'balance_controller_test.mocks.dart';

void main() {
  group('BalanceController Tests', () {
    late MockBalanceChangeRepository mockBalanceChangeRepo;
    late MockStudentRepository mockStudentRepo;
    late MockLedgerRepository mockLedgerRepo;
    late MockAllocationService mockAllocationService;
    late ProviderContainer container;

    setUpAll(() {
      // Initialize Talker for logging in tests
      initializeTalker();
    });

    setUp(() {
      mockBalanceChangeRepo = MockBalanceChangeRepository();
      mockStudentRepo = MockStudentRepository();
      mockLedgerRepo = MockLedgerRepository();
      mockAllocationService = MockAllocationService();

      // Use ProviderContainer.test() for automatic disposal
      container = ProviderContainer.test(
        overrides: [
          balanceChangeRepositoryProvider.overrideWithValue(mockBalanceChangeRepo),
          studentRepositoryProvider.overrideWithValue(mockStudentRepo),
          ledgerRepositoryProvider.overrideWithValue(mockLedgerRepo),
          allocationServiceProvider.overrideWithValue(mockAllocationService),
        ],
      );
    });

    // Helper to create test student
    Student createTestStudent({
      String id = 'student-1',
      String name = 'John Doe',
      int balanceCents = 0,
    }) {
      return Student.create(
        id: id,
        name: name,
        hourlyRateCents: 4000,
        balanceCents: balanceCents,
      );
    }

    group('recordPayment', () {
      test('should record payment successfully', () async {
        // Arrange
        const studentId = 'student-1';
        const amountCents = 5000;
        final student = createTestStudent();

        when(mockBalanceChangeRepo.create(any)).thenAnswer((_) async => BalanceChange.payment(
          id: 'balance-1',
          studentId: studentId,
          amountCents: amountCents,
        ));
        when(mockStudentRepo.getById(studentId)).thenAnswer((_) async => student);
        when(mockStudentRepo.updateBalance(studentId, amountCents)).thenAnswer((_) async => {});
        when(mockAllocationService.runAllocationAfterBalanceChange(studentId)).thenAnswer((_) async => false);

        // Act
        final controller = container.read(balanceControllerProvider.notifier);
        await controller.recordPayment(studentId: studentId, amountCents: amountCents);

        // Assert
        final state = container.read(balanceControllerProvider);
        expect(state.hasError, false);
        expect(state.isLoading, false);

        verify(mockBalanceChangeRepo.create(argThat(isA<BalanceChange>()))).called(1);
        verify(mockStudentRepo.getById(studentId)).called(1);
        verify(mockStudentRepo.updateBalance(studentId, amountCents)).called(1);
        verify(mockAllocationService.runAllocationAfterBalanceChange(studentId)).called(1);
      });

      test('should throw error when payment amount is zero', () async {
        // Arrange
        const studentId = 'student-1';
        const amountCents = 0;

        // Act
        final controller = container.read(balanceControllerProvider.notifier);
        await controller.recordPayment(studentId: studentId, amountCents: amountCents);

        // Assert
        final state = container.read(balanceControllerProvider);
        expect(state.hasError, true);
        expect(state.error.toString(), contains('Payment amount must be positive'));

        verifyNever(mockBalanceChangeRepo.create(any));
        verifyNever(mockStudentRepo.updateBalance(any, any));
      });

      test('should throw error when payment amount is negative', () async {
        // Arrange
        const studentId = 'student-1';
        const amountCents = -5000;

        // Act
        final controller = container.read(balanceControllerProvider.notifier);
        await controller.recordPayment(studentId: studentId, amountCents: amountCents);

        // Assert
        final state = container.read(balanceControllerProvider);
        expect(state.hasError, true);
        expect(state.error.toString(), contains('Payment amount must be positive'));

        verifyNever(mockBalanceChangeRepo.create(any));
        verifyNever(mockStudentRepo.updateBalance(any, any));
      });

      test('should trigger allocation after payment', () async {
        // Arrange
        const studentId = 'student-1';
        const amountCents = 5000;
        final student = createTestStudent();

        when(mockBalanceChangeRepo.create(any)).thenAnswer((_) async => BalanceChange.payment(
          id: 'balance-1',
          studentId: studentId,
          amountCents: amountCents,
        ));
        when(mockStudentRepo.getById(studentId)).thenAnswer((_) async => student);
        when(mockStudentRepo.updateBalance(studentId, amountCents)).thenAnswer((_) async => {});
        when(mockAllocationService.runAllocationAfterBalanceChange(studentId)).thenAnswer((_) async => true);

        // Act
        final controller = container.read(balanceControllerProvider.notifier);
        await controller.recordPayment(studentId: studentId, amountCents: amountCents);

        // Assert
        verify(mockAllocationService.runAllocationAfterBalanceChange(studentId)).called(1);
      });

      test('should handle payment error gracefully', () async {
        // Arrange
        const studentId = 'student-1';
        const amountCents = 5000;

        when(mockBalanceChangeRepo.create(any)).thenThrow(Exception('Database error'));

        // Act
        final controller = container.read(balanceControllerProvider.notifier);
        await controller.recordPayment(studentId: studentId, amountCents: amountCents);

        // Assert
        final state = container.read(balanceControllerProvider);
        expect(state.hasError, true);
        expect(state.error.toString(), contains('Database error'));
      });
    });

    group('recordAdjustment', () {
      test('should record positive adjustment successfully', () async {
        // Arrange
        const studentId = 'student-1';
        const amountCents = 3000;
        final student = createTestStudent();

        when(mockBalanceChangeRepo.create(any)).thenAnswer((_) async => BalanceChange.create(
          id: 'balance-1',
          studentId: studentId,
          amountCents: amountCents,
        ));
        when(mockStudentRepo.getById(studentId)).thenAnswer((_) async => student);
        when(mockStudentRepo.updateBalance(studentId, amountCents)).thenAnswer((_) async => {});
        when(mockAllocationService.runAllocationAfterBalanceChange(studentId)).thenAnswer((_) async => false);

        // Act
        final controller = container.read(balanceControllerProvider.notifier);
        await controller.recordAdjustment(studentId: studentId, amountCents: amountCents);

        // Assert
        final state = container.read(balanceControllerProvider);
        expect(state.hasError, false);
        expect(state.isLoading, false);

        verify(mockBalanceChangeRepo.create(argThat(isA<BalanceChange>()))).called(1);
        verify(mockStudentRepo.getById(studentId)).called(1);
        verify(mockStudentRepo.updateBalance(studentId, amountCents)).called(1);
        verify(mockAllocationService.runAllocationAfterBalanceChange(studentId)).called(1);
      });

      test('should record negative adjustment successfully', () async {
        // Arrange
        const studentId = 'student-1';
        const amountCents = -3000;
        final student = createTestStudent(balanceCents: 5000);

        when(mockBalanceChangeRepo.create(any)).thenAnswer((_) async => BalanceChange.create(
          id: 'balance-1',
          studentId: studentId,
          amountCents: amountCents,
        ));
        when(mockStudentRepo.getById(studentId)).thenAnswer((_) async => student);
        when(mockStudentRepo.updateBalance(studentId, 2000)).thenAnswer((_) async => {});

        // Act
        final controller = container.read(balanceControllerProvider.notifier);
        await controller.recordAdjustment(studentId: studentId, amountCents: amountCents);

        // Assert
        final state = container.read(balanceControllerProvider);
        expect(state.hasError, false);
        expect(state.isLoading, false);

        verify(mockBalanceChangeRepo.create(argThat(isA<BalanceChange>()))).called(1);
        verify(mockStudentRepo.getById(studentId)).called(1);
        verify(mockStudentRepo.updateBalance(studentId, 2000)).called(1);
        // Should NOT trigger allocation for negative adjustment
        verifyNever(mockAllocationService.runAllocationAfterBalanceChange(any));
      });

      test('should throw error when adjustment amount is zero', () async {
        // Arrange
        const studentId = 'student-1';
        const amountCents = 0;

        // Act
        final controller = container.read(balanceControllerProvider.notifier);
        await controller.recordAdjustment(studentId: studentId, amountCents: amountCents);

        // Assert
        final state = container.read(balanceControllerProvider);
        expect(state.hasError, true);
        expect(state.error.toString(), contains('Adjustment amount cannot be zero'));

        verifyNever(mockBalanceChangeRepo.create(any));
        verifyNever(mockStudentRepo.updateBalance(any, any));
      });

      test('should trigger allocation only for positive adjustments', () async {
        // Arrange
        const studentId = 'student-1';
        const amountCents = 3000;
        final student = createTestStudent();

        when(mockBalanceChangeRepo.create(any)).thenAnswer((_) async => BalanceChange.create(
          id: 'balance-1',
          studentId: studentId,
          amountCents: amountCents,
        ));
        when(mockStudentRepo.getById(studentId)).thenAnswer((_) async => student);
        when(mockStudentRepo.updateBalance(studentId, amountCents)).thenAnswer((_) async => {});
        when(mockAllocationService.runAllocationAfterBalanceChange(studentId)).thenAnswer((_) async => true);

        // Act
        final controller = container.read(balanceControllerProvider.notifier);
        await controller.recordAdjustment(studentId: studentId, amountCents: amountCents);

        // Assert
        verify(mockAllocationService.runAllocationAfterBalanceChange(studentId)).called(1);
      });
    });

    group('deleteBalanceChange', () {
      test('should delete balance change and reverse student balance', () async {
        // Arrange
        const balanceChangeId = 'balance-1';
        const studentId = 'student-1';
        const amountCents = 5000;
        final balanceChange = BalanceChange.payment(
          id: balanceChangeId,
          studentId: studentId,
          amountCents: amountCents,
        );
        final student = createTestStudent(balanceCents: 5000);

        when(mockBalanceChangeRepo.getById(balanceChangeId)).thenAnswer((_) async => balanceChange);
        when(mockStudentRepo.getById(studentId)).thenAnswer((_) async => student);
        when(mockStudentRepo.updateBalance(studentId, 0)).thenAnswer((_) async => {});
        when(mockBalanceChangeRepo.delete(balanceChangeId)).thenAnswer((_) async => {});

        // Act
        final controller = container.read(balanceControllerProvider.notifier);
        await controller.deleteBalanceChange(balanceChangeId);

        // Assert
        final state = container.read(balanceControllerProvider);
        expect(state.hasError, false);
        expect(state.isLoading, false);

        verify(mockBalanceChangeRepo.getById(balanceChangeId)).called(1);
        verify(mockStudentRepo.getById(studentId)).called(1);
        verify(mockStudentRepo.updateBalance(studentId, 0)).called(1);
        verify(mockBalanceChangeRepo.delete(balanceChangeId)).called(1);
      });

      test('should handle deletion when balance change not found', () async {
        // Arrange
        const balanceChangeId = 'balance-1';

        when(mockBalanceChangeRepo.getById(balanceChangeId)).thenAnswer((_) async => null);
        when(mockBalanceChangeRepo.delete(balanceChangeId)).thenAnswer((_) async => {});

        // Act
        final controller = container.read(balanceControllerProvider.notifier);
        await controller.deleteBalanceChange(balanceChangeId);

        // Assert
        final state = container.read(balanceControllerProvider);
        expect(state.hasError, false);

        verify(mockBalanceChangeRepo.getById(balanceChangeId)).called(1);
        verify(mockBalanceChangeRepo.delete(balanceChangeId)).called(1);
        verifyNever(mockStudentRepo.getById(any));
        verifyNever(mockStudentRepo.updateBalance(any, any));
      });

      test('should handle deletion error gracefully', () async {
        // Arrange
        const balanceChangeId = 'balance-1';

        when(mockBalanceChangeRepo.getById(balanceChangeId)).thenThrow(Exception('Database error'));

        // Act
        final controller = container.read(balanceControllerProvider.notifier);
        await controller.deleteBalanceChange(balanceChangeId);

        // Assert
        final state = container.read(balanceControllerProvider);
        expect(state.hasError, true);
        expect(state.error.toString(), contains('Database error'));
      });
    });

    group('deleteBalanceChangesByStudentId', () {
      test('should delete all balance changes for student', () async {
        // Arrange
        const studentId = 'student-1';

        when(mockBalanceChangeRepo.deleteByStudentId(studentId)).thenAnswer((_) async => {});

        // Act
        final controller = container.read(balanceControllerProvider.notifier);
        await controller.deleteBalanceChangesByStudentId(studentId);

        // Assert
        final state = container.read(balanceControllerProvider);
        expect(state.hasError, false);
        expect(state.isLoading, false);

        verify(mockBalanceChangeRepo.deleteByStudentId(studentId)).called(1);
      });

      test('should handle deletion error gracefully', () async {
        // Arrange
        const studentId = 'student-1';

        when(mockBalanceChangeRepo.deleteByStudentId(studentId)).thenThrow(Exception('Database error'));

        // Act
        final controller = container.read(balanceControllerProvider.notifier);
        await controller.deleteBalanceChangesByStudentId(studentId);

        // Assert
        final state = container.read(balanceControllerProvider);
        expect(state.hasError, true);
        expect(state.error.toString(), contains('Database error'));
      });
    });

    group('Helper Methods', () {
      test('getCurrentBalance should return current balance from ledger', () async {
        // Arrange
        const studentId = 'student-1';
        const currentBalance = 8000;

        when(mockLedgerRepo.calculateCurrentBalance(studentId)).thenAnswer((_) async => currentBalance);

        // Act
        final controller = container.read(balanceControllerProvider.notifier);
        final balance = await controller.getCurrentBalance(studentId);

        // Assert
        expect(balance, currentBalance);
        verify(mockLedgerRepo.calculateCurrentBalance(studentId)).called(1);
      });

      test('getUnpaidTotal should return unpaid sessions total', () async {
        // Arrange
        const studentId = 'student-1';
        const unpaidTotal = 12000;

        when(mockLedgerRepo.getUnpaidTotal(studentId)).thenAnswer((_) async => unpaidTotal);

        // Act
        final controller = container.read(balanceControllerProvider.notifier);
        final total = await controller.getUnpaidTotal(studentId);

        // Assert
        expect(total, unpaidTotal);
        verify(mockLedgerRepo.getUnpaidTotal(studentId)).called(1);
      });

      test('getTotalPayments should return total payments', () async {
        // Arrange
        const studentId = 'student-1';
        const totalPayments = 20000;

        when(mockLedgerRepo.getTotalPayments(studentId)).thenAnswer((_) async => totalPayments);

        // Act
        final controller = container.read(balanceControllerProvider.notifier);
        final total = await controller.getTotalPayments(studentId);

        // Assert
        expect(total, totalPayments);
        verify(mockLedgerRepo.getTotalPayments(studentId)).called(1);
      });

      test('getLedgerEntries should return ledger entries', () async {
        // Arrange
        const studentId = 'student-1';
        final ledgerEntries = <LedgerEntry>[];

        when(mockLedgerRepo.getLedgerForStudentDescending(studentId)).thenAnswer((_) async => ledgerEntries);

        // Act
        final controller = container.read(balanceControllerProvider.notifier);
        final entries = await controller.getLedgerEntries(studentId);

        // Assert
        expect(entries, ledgerEntries);
        verify(mockLedgerRepo.getLedgerForStudentDescending(studentId)).called(1);
      });
    });
  });
}

