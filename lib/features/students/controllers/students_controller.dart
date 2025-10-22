import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tutor_zone/core/debug_log/logger.dart';
import 'package:tutor_zone/features/students/models/data/student.dart';
import 'package:tutor_zone/features/students/models/repositories/student_repository.dart';
import 'package:uuid/uuid.dart';

part 'students_controller.g.dart';

const _uuid = Uuid();

/// Provider for students list stream
@riverpod
Stream<List<Student>> studentsStream(Ref ref) {
  final repository = ref.watch(studentRepositoryProvider);
  return repository.watchAll();
}

/// Provider for single student stream
@riverpod
Stream<Student?> studentStream(Ref ref, String studentId) {
  final repository = ref.watch(studentRepositoryProvider);
  return repository.watchById(studentId);
}

/// Provider for students with negative balance stream
@riverpod
Stream<List<Student>> studentsWithNegativeBalanceStream(Ref ref) {
  final repository = ref.watch(studentRepositoryProvider);
  return repository.watchStudentsWithNegativeBalance();
}


@riverpod
class StudentsController extends _$StudentsController {
  StudentRepository get _repository => ref.read(studentRepositoryProvider);

  @override
  Future<void> build() async {}

  Future<void> createStudent({
    required String name,
    required int hourlyRateCents,
    int balanceCents = 0,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final student = Student.create(
        id: _uuid.v4(),
        name: name,
        hourlyRateCents: hourlyRateCents,
        balanceCents: balanceCents,
      );
      logInfo('Creating student: ${student.name}');
      await _repository.create(student);
      logInfo('Student created successfully: ${student.id}');
    });
  }

  Future<void> updateStudent({
    required String id,
    String? name,
    int? hourlyRateCents,
    int? balanceCents,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      logInfo('Updating student: $id');

      final current = await _repository.getById(id);
      if (current == null) {
        throw Exception('Student not found: $id');
      }

      final updated = current.update(
        name: name,
        hourlyRateCents: hourlyRateCents,
        balanceCents: balanceCents,
      );

      await _repository.update(updated);
      logInfo('Student updated successfully: $id');
    });
  }

  Future<void> deleteStudent(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      logInfo('Deleting student: $id');
      await _repository.delete(id);
      logInfo('Student deleted successfully: $id');
    });
  }
}
