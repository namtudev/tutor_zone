import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tutor_zone/core/debug_log/logger.dart';
import 'package:tutor_zone/features/balance/domain/allocation_service.dart';
import 'package:tutor_zone/features/balance/models/data/balance_change.dart';
import 'package:tutor_zone/features/balance/models/repositories/balance_change_repository.dart';
import 'package:tutor_zone/features/balance/models/repositories/ledger_repository.dart';
import 'package:tutor_zone/features/students/models/repositories/student_repository.dart';
import 'package:uuid/uuid.dart';

part 'balance_controller.g.dart';

const _uuid = Uuid();

/// Stream provider for all balance changes
@riverpod
Stream<List<BalanceChange>> balanceChangesStream(Ref ref) {
  final repository = ref.watch(balanceChangeRepositoryProvider);
  return repository.watchAll();
}

/// Stream provider for a single balance change by ID
@riverpod
Stream<BalanceChange?> balanceChangeStream(Ref ref, String balanceChangeId) {
  final repository = ref.watch(balanceChangeRepositoryProvider);
  return repository.watchById(balanceChangeId);
}

/// Stream provider for balance changes by student ID
@riverpod
Stream<List<BalanceChange>> balanceChangesByStudentStream(
    Ref ref, String studentId) {
  final repository = ref.watch(balanceChangeRepositoryProvider);
  return repository.watchByStudentId(studentId);
}

/// Stream provider for ledger entries by student ID
@riverpod
Stream<List<LedgerEntry>> ledgerEntriesStream(Ref ref, String studentId) {
  final ledgerRepo = ref.watch(ledgerRepositoryProvider);
  return ledgerRepo.watchLedgerForStudent(studentId);
}

/// Provider for unpaid sessions total by student
@riverpod
Future<int> unpaidTotalByStudent(Ref ref, String studentId) async {
  final ledgerRepo = ref.watch(ledgerRepositoryProvider);
  return await ledgerRepo.getUnpaidTotal(studentId);
}

/// Provider for total payments by student
@riverpod
Future<int> totalPaymentsByStudent(Ref ref, String studentId) async {
  final ledgerRepo = ref.watch(ledgerRepositoryProvider);
  return await ledgerRepo.getTotalPayments(studentId);
}

/// Controller for balance change CRUD operations with UI-bindable state.
@riverpod
class BalanceController extends _$BalanceController {
  late final BalanceChangeRepository _balanceChangeRepo;
  late final StudentRepository _studentRepo;
  late final LedgerRepository _ledgerRepo;

  @override
  Future<void> build() async {
    _balanceChangeRepo = ref.read(balanceChangeRepositoryProvider);
    _studentRepo = ref.read(studentRepositoryProvider);
    _ledgerRepo = ref.read(ledgerRepositoryProvider);
  }

  /// Record a payment (positive balance change)
  Future<void> recordPayment({
    required String studentId,
    required int amountCents,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      if (amountCents <= 0) {
        throw Exception('Payment amount must be positive');
      }

      final balanceChange = BalanceChange.payment(
        id: _uuid.v4(),
        studentId: studentId,
        amountCents: amountCents,
      );

      logInfo('Recording payment: ${balanceChange.id} for student $studentId, amount: \$${balanceChange.amountDollars}');
      await _balanceChangeRepo.create(balanceChange);

      // Update student balance
      final student = await _studentRepo.getById(studentId);
      if (student != null) {
        final newBalance = student.balanceCents + amountCents;
        await _studentRepo.updateBalance(studentId, newBalance);
        logInfo('Updated student balance: $newBalance cents');
      }

      logInfo('Payment recorded successfully: ${balanceChange.id}');

      // Trigger allocation check
      final allocationService = ref.read(allocationServiceProvider);
      final allocated = await allocationService.runAllocationAfterBalanceChange(studentId);
      if (allocated) {
        logInfo('Auto-allocation performed for student $studentId');
      }
    });
  }

  /// Record an adjustment (can be positive or negative)
  Future<void> recordAdjustment({
    required String studentId,
    required int amountCents,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      if (amountCents == 0) {
        throw Exception('Adjustment amount cannot be zero');
      }

      final balanceChange = BalanceChange.create(
        id: _uuid.v4(),
        studentId: studentId,
        amountCents: amountCents,
      );

      logInfo('Recording adjustment: ${balanceChange.id} for student $studentId, amount: \$${balanceChange.amountDollars}');
      await _balanceChangeRepo.create(balanceChange);

      // Update student balance
      final student = await _studentRepo.getById(studentId);
      if (student != null) {
        final newBalance = student.balanceCents + amountCents;
        await _studentRepo.updateBalance(studentId, newBalance);
        logInfo('Updated student balance: $newBalance cents');
      }

      logInfo('Adjustment recorded successfully: ${balanceChange.id}');

      // Trigger allocation check (only for positive adjustments)
      if (amountCents > 0) {
        final allocationService = ref.read(allocationServiceProvider);
        final allocated = await allocationService.runAllocationAfterBalanceChange(studentId);
        if (allocated) {
          logInfo('Auto-allocation performed for student $studentId');
        }
      }
    });
  }

  /// Delete a balance change
  Future<void> deleteBalanceChange(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      logInfo('Deleting balance change: $id');

      // Get the balance change to reverse the student balance
      final balanceChange = await _balanceChangeRepo.getById(id);
      if (balanceChange != null) {
        final student = await _studentRepo.getById(balanceChange.studentId);
        if (student != null) {
          // Reverse the balance change
          final newBalance = student.balanceCents - balanceChange.amountCents;
          await _studentRepo.updateBalance(balanceChange.studentId, newBalance);
          logInfo('Reversed student balance: $newBalance cents');
        }
      }

      await _balanceChangeRepo.delete(id);
      logInfo('Balance change deleted successfully: $id');
    });
  }

  /// Delete all balance changes for a student (for cascade deletion)
  Future<void> deleteBalanceChangesByStudentId(String studentId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      logInfo('Deleting all balance changes for student: $studentId');
      await _balanceChangeRepo.deleteByStudentId(studentId);
      logInfo('All balance changes deleted for student: $studentId');
    });
  }

  /// Get current balance for a student from ledger
  Future<int> getCurrentBalance(String studentId) async {
    return await _ledgerRepo.calculateCurrentBalance(studentId);
  }

  /// Get unpaid sessions total for a student
  Future<int> getUnpaidTotal(String studentId) async {
    return await _ledgerRepo.getUnpaidTotal(studentId);
  }

  /// Get total payments for a student
  Future<int> getTotalPayments(String studentId) async {
    return await _ledgerRepo.getTotalPayments(studentId);
  }

  /// Get ledger entries for a student
  Future<List<LedgerEntry>> getLedgerEntries(String studentId) async {
    return await _ledgerRepo.getLedgerForStudentDescending(studentId);
  }
}

