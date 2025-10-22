import 'package:freezed_annotation/freezed_annotation.dart';

part 'student.freezed.dart';
part 'student.g.dart';

/// Student model representing a tutoring student.
/// 
/// Stores student profile information including contact details,
/// hourly rate, and current balance (in cents).
/// 
/// Schema: SCHEMA.md - students store
@freezed
abstract class Student with _$Student {
  const Student._();

  const factory Student({
    /// Unique identifier (UUID)
    required String id,
    
    /// Student's display name
    required String name,
    
    /// Hourly rate in cents (e.g., 4000 = $40.00/hr)
    required int hourlyRateCents,
    
    /// Current balance in cents
    /// Positive = prepaid credit, Negative = amount owed
    required int balanceCents,
    
    /// Timestamp when student was created (ISO8601)
    required String createdAt,
    
    /// Timestamp when student was last updated (ISO8601)
    required String updatedAt,
  }) = _Student;

  /// Create Student from JSON
  factory Student.fromJson(Map<String, dynamic> json) => _$StudentFromJson(json);

  /// Get hourly rate in dollars (for display)
  double get hourlyRateDollars => hourlyRateCents / 100.0;

  /// Get balance in dollars (for display)
  double get balanceDollars => balanceCents / 100.0;

  /// Check if student has a negative balance (owes money)
  bool get hasNegativeBalance => balanceCents < 0;

  /// Check if student has a positive balance (prepaid credit)
  bool get hasPositiveBalance => balanceCents > 0;

  /// Check if student is balanced (no credit, no debt)
  bool get isBalanced => balanceCents == 0;

  /// Get balance status text for UI
  String get balanceStatus {
    if (isBalanced) return 'Balanced';
    if (hasNegativeBalance) {
      final hours = (balanceCents.abs() / hourlyRateCents).toStringAsFixed(1);
      return '$hours hrs owed';
    }
    final hours = (balanceCents / hourlyRateCents).toStringAsFixed(1);
    return '$hours hrs credit';
  }

  /// Create a new student with current timestamps
  factory Student.create({
    required String id,
    required String name,
    required int hourlyRateCents,
    int balanceCents = 0,
  }) {
    final now = DateTime.now().toIso8601String();
    return Student(
      id: id,
      name: name,
      hourlyRateCents: hourlyRateCents,
      balanceCents: balanceCents,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Update student with new timestamp
  Student update({
    String? name,
    int? hourlyRateCents,
    int? balanceCents,
  }) {
    return copyWith(
      name: name ?? this.name,
      hourlyRateCents: hourlyRateCents ?? this.hourlyRateCents,
      balanceCents: balanceCents ?? this.balanceCents,
      updatedAt: DateTime.now().toIso8601String(),
    );
  }
}

