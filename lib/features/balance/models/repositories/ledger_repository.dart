import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tutor_zone/features/balance/models/data/balance_change.dart';
import 'package:tutor_zone/features/balance/models/repositories/balance_change_repository.dart';
import 'package:tutor_zone/features/sessions/models/data/session.dart';
import 'package:tutor_zone/features/sessions/models/repositories/session_repository.dart';

part 'ledger_repository.freezed.dart';
part 'ledger_repository.g.dart';

/// Ledger repository provider
@riverpod
LedgerRepository ledgerRepository(Ref ref) {
  final sessionRepo = ref.watch(sessionRepositoryProvider);
  final balanceChangeRepo = ref.watch(balanceChangeRepositoryProvider);
  return LedgerRepository(sessionRepo, balanceChangeRepo);
}

/// Ledger entry type
enum LedgerEntryType {
  /// Session entry (debit)
  session,

  /// Balance change entry (credit/adjustment)
  balanceChange,
}

/// Ledger entry combining sessions and balance changes
@freezed
sealed class LedgerEntry with _$LedgerEntry {
  const LedgerEntry._();

  /// Session entry (debit - reduces balance)
  const factory LedgerEntry.session({
    required Session session,
    required DateTime timestamp,
    required int amountCents,
    required int runningBalanceCents,
  }) = SessionEntry;

  /// Balance change entry (credit - increases balance)
  const factory LedgerEntry.balanceChange({
    required BalanceChange balanceChange,
    required DateTime timestamp,
    required int amountCents,
    required int runningBalanceCents,
  }) = BalanceChangeEntry;

  /// Get the timestamp for sorting
  DateTime get entryTimestamp => switch (this) {
        SessionEntry(:final timestamp) => timestamp,
        BalanceChangeEntry(:final timestamp) => timestamp,
      };

  /// Get the amount for this entry
  int get entryAmount => switch (this) {
        SessionEntry(:final amountCents) => amountCents,
        BalanceChangeEntry(:final amountCents) => amountCents,
      };

  /// Get the running balance
  int get runningBalance => switch (this) {
        SessionEntry(:final runningBalanceCents) => runningBalanceCents,
        BalanceChangeEntry(:final runningBalanceCents) => runningBalanceCents,
      };

  /// Get entry type
  LedgerEntryType get entryType => switch (this) {
        SessionEntry() => LedgerEntryType.session,
        BalanceChangeEntry() => LedgerEntryType.balanceChange,
      };

  /// Get display description
  String get description => switch (this) {
        SessionEntry(:final session) =>
          'Session: ${session.durationHours.toStringAsFixed(1)}h',
        BalanceChangeEntry(:final balanceChange) => balanceChange.changeType,
      };
}

/// Repository for combining sessions and balance changes into a ledger view
class LedgerRepository {
  final SessionRepository _sessionRepo;
  final BalanceChangeRepository _balanceChangeRepo;

  /// Creates a new [LedgerRepository] with the given repositories.
  LedgerRepository(this._sessionRepo, this._balanceChangeRepo);

  /// Get ledger entries for a student (chronological order, oldest first)
  Future<List<LedgerEntry>> getLedgerForStudent(String studentId) async {
    // Fetch sessions and balance changes
    final sessions = await _sessionRepo.getByStudentId(studentId);
    final balanceChanges =
        await _balanceChangeRepo.getByStudentIdAscending(studentId);

    // Combine and sort by timestamp
    final entries = <LedgerEntry>[];
    var runningBalance = 0;

    // Create a combined list with timestamps
    final allItems = <({DateTime timestamp, dynamic item})>[
      ...sessions.map((s) => (timestamp: DateTime.parse(s.start), item: s)),
      ...balanceChanges
          .map((bc) => (timestamp: DateTime.parse(bc.createdAt), item: bc)),
    ];

    // Sort by timestamp (oldest first)
    allItems.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Build ledger with running balance
    for (final item in allItems) {
      if (item.item is Session) {
        final session = item.item as Session;
        // Sessions reduce balance (negative impact)
        runningBalance -= session.amountCents;
        entries.add(LedgerEntry.session(
          session: session,
          timestamp: item.timestamp,
          amountCents: -session.amountCents, // Negative for debit
          runningBalanceCents: runningBalance,
        ));
      } else if (item.item is BalanceChange) {
        final balanceChange = item.item as BalanceChange;
        // Balance changes add to balance (positive impact)
        runningBalance += balanceChange.amountCents;
        entries.add(LedgerEntry.balanceChange(
          balanceChange: balanceChange,
          timestamp: item.timestamp,
          amountCents: balanceChange.amountCents,
          runningBalanceCents: runningBalance,
        ));
      }
    }

    return entries;
  }

  /// Get ledger entries for a student (reverse chronological order, most recent first)
  Future<List<LedgerEntry>> getLedgerForStudentDescending(
      String studentId) async {
    final entries = await getLedgerForStudent(studentId);
    return entries.reversed.toList();
  }

  /// Calculate current balance for a student from ledger
  Future<int> calculateCurrentBalance(String studentId) async {
    final entries = await getLedgerForStudent(studentId);
    if (entries.isEmpty) return 0;
    return entries.last.runningBalance;
  }

  /// Get unpaid sessions total for a student
  Future<int> getUnpaidTotal(String studentId) async {
    final unpaidSessions =
        await _sessionRepo.getUnpaidSessionsByStudentId(studentId);
    return unpaidSessions.fold<int>(
      0,
      (sum, session) => sum + session.amountCents,
    );
  }

  /// Get total payments for a student
  Future<int> getTotalPayments(String studentId) async {
    return await _balanceChangeRepo.getTotalAmountByStudentId(studentId);
  }

  /// Stream of ledger entries for a student
  Stream<List<LedgerEntry>> watchLedgerForStudent(String studentId) async* {
    // Combine streams from sessions and balance changes
    await for (final _ in _sessionRepo.watchByStudentId(studentId)) {
      // Whenever sessions change, recalculate ledger
      yield await getLedgerForStudentDescending(studentId);
    }
  }
}

