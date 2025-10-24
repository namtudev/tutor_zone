import 'package:freezed_annotation/freezed_annotation.dart';

part 'balance_change.freezed.dart';
part 'balance_change.g.dart';

/// BalanceChange model representing a payment or balance adjustment.
///
/// Stores balance change information including student reference,
/// amount (positive for payments/prepaid, negative for adjustments),
/// and timestamp.
///
/// Schema: SCHEMA.md - balance_changes store
@freezed
abstract class BalanceChange with _$BalanceChange {
  const BalanceChange._();

  /// Creates a new [BalanceChange] instance.
  const factory BalanceChange({
    /// Unique identifier (UUID)
    required String id,

    /// Foreign key to students.id
    required String studentId,

    /// Amount in cents
    /// Positive = payment/prepaid credit
    /// Negative = adjustment/refund
    required int amountCents,

    /// Timestamp when balance change was created (ISO8601)
    required String createdAt,
  }) = _BalanceChange;

  /// Create BalanceChange from JSON
  factory BalanceChange.fromJson(Map<String, dynamic> json) => _$BalanceChangeFromJson(json);

  /// Get amount in dollars (for display)
  double get amountDollars => amountCents / 100.0;

  /// Check if this is a payment (positive amount)
  bool get isPayment => amountCents > 0;

  /// Check if this is an adjustment (negative amount)
  bool get isAdjustment => amountCents < 0;

  /// Get display text for the type of change
  String get changeType {
    if (amountCents > 0) return 'Payment';
    if (amountCents < 0) return 'Adjustment';
    return 'No Change';
  }

  /// Create a new balance change with current timestamp
  factory BalanceChange.create({
    required String id,
    required String studentId,
    required int amountCents,
  }) {
    return BalanceChange(
      id: id,
      studentId: studentId,
      amountCents: amountCents,
      createdAt: DateTime.now().toIso8601String(),
    );
  }

  /// Create a payment (positive amount)
  factory BalanceChange.payment({
    required String id,
    required String studentId,
    required int amountCents,
  }) {
    assert(amountCents > 0, 'Payment amount must be positive');
    return BalanceChange.create(
      id: id,
      studentId: studentId,
      amountCents: amountCents,
    );
  }

  /// Create an adjustment (negative amount)
  factory BalanceChange.adjustment({
    required String id,
    required String studentId,
    required int amountCents,
  }) {
    assert(amountCents < 0, 'Adjustment amount must be negative');
    return BalanceChange.create(
      id: id,
      studentId: studentId,
      amountCents: amountCents,
    );
  }
}
