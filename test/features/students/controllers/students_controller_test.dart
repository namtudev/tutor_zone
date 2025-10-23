import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tutor_zone/core/debug_log/logger.dart';
import 'package:tutor_zone/features/students/controllers/students_controller.dart';
import 'package:tutor_zone/features/students/models/data/student.dart';
import 'package:tutor_zone/features/students/models/repositories/student_repository.dart';

/// Mock StudentRepository
class MockStudentRepository extends Mock implements StudentRepository {}

void main() {
  setUpAll(() {
    initializeTalker();
    // Register fallback values for mocktail
    registerFallbackValue(
      Student.create(
        id: 'test-id',
        name: 'Test Student',
        hourlyRateCents: 5000,
      ),
    );
  });

  group('StudentsController Tests', () {
    late MockStudentRepository mockRepository;
    late ProviderContainer container;

    setUp(() {
      mockRepository = MockStudentRepository();
      // Use ProviderContainer.test() for automatic disposal
      container = ProviderContainer.test(
        overrides: [
          studentRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });

    group('createStudent', () {
      test('should create student successfully', () async {
        // Arrange
        final student = Student.create(
          id: 'student-1',
          name: 'John Doe',
          hourlyRateCents: 5000,
        );
        when(() => mockRepository.create(any())).thenAnswer((_) async => student);

        final controller = container.read(studentsControllerProvider.notifier);

        // Act
        await controller.createStudent(
          name: 'John Doe',
          hourlyRateCents: 5000,
        );

        // Assert
        final state = container.read(studentsControllerProvider);
        expect(state.hasError, false);
        expect(state.isLoading, false);
        verify(() => mockRepository.create(any())).called(1);
      });

      test('should create student with custom balance', () async {
        // Arrange
        final student = Student.create(
          id: 'student-1',
          name: 'Jane Doe',
          hourlyRateCents: 6000,
          balanceCents: 10000,
        );
        when(() => mockRepository.create(any())).thenAnswer((_) async => student);

        final controller = container.read(studentsControllerProvider.notifier);

        // Act
        await controller.createStudent(
          name: 'Jane Doe',
          hourlyRateCents: 6000,
          balanceCents: 10000,
        );

        // Assert
        final state = container.read(studentsControllerProvider);
        expect(state.hasError, false);
        verify(() => mockRepository.create(any())).called(1);
      });

      test('should handle creation error', () async {
        // Arrange
        when(() => mockRepository.create(any()))
            .thenThrow(Exception('Database error'));

        final controller = container.read(studentsControllerProvider.notifier);

        // Act
        await controller.createStudent(
          name: 'John Doe',
          hourlyRateCents: 5000,
        );

        // Assert
        final state = container.read(studentsControllerProvider);
        expect(state.hasError, true);
        expect(state.error.toString(), contains('Database error'));
      });
    });

    group('updateStudent', () {
      test('should update student successfully', () async {
        // Arrange
        final existingStudent = Student.create(
          id: 'student-1',
          name: 'John Doe',
          hourlyRateCents: 5000,
        );

        when(() => mockRepository.getById('student-1'))
            .thenAnswer((_) async => existingStudent);
        when(() => mockRepository.update(any())).thenAnswer((_) async => existingStudent);

        final controller = container.read(studentsControllerProvider.notifier);

        // Act
        await controller.updateStudent(
          id: 'student-1',
          name: 'Jane Doe',
          hourlyRateCents: 6000,
        );

        // Assert
        final state = container.read(studentsControllerProvider);
        expect(state.hasError, false);
        verify(() => mockRepository.getById('student-1')).called(1);
        verify(() => mockRepository.update(any())).called(1);
      });

      test('should throw when student not found', () async {
        // Arrange
        when(() => mockRepository.getById('student-1'))
            .thenAnswer((_) async => null);

        final controller = container.read(studentsControllerProvider.notifier);

        // Act
        await controller.updateStudent(
          id: 'student-1',
          name: 'Jane Doe',
        );

        // Assert
        final state = container.read(studentsControllerProvider);
        expect(state.hasError, true);
        expect(state.error.toString(), contains('Student not found'));
      });

      test('should handle update error', () async {
        // Arrange
        final existingStudent = Student.create(
          id: 'student-1',
          name: 'John Doe',
          hourlyRateCents: 5000,
        );

        when(() => mockRepository.getById('student-1'))
            .thenAnswer((_) async => existingStudent);
        when(() => mockRepository.update(any()))
            .thenThrow(Exception('Update failed'));

        final controller = container.read(studentsControllerProvider.notifier);

        // Act
        await controller.updateStudent(
          id: 'student-1',
          name: 'Jane Doe',
        );

        // Assert
        final state = container.read(studentsControllerProvider);
        expect(state.hasError, true);
        expect(state.error.toString(), contains('Update failed'));
      });
    });

    group('deleteStudent', () {
      test('should delete student successfully', () async {
        // Arrange
        when(() => mockRepository.delete('student-1'))
            .thenAnswer((_) async {});

        final controller = container.read(studentsControllerProvider.notifier);

        // Act
        await controller.deleteStudent('student-1');

        // Assert
        final state = container.read(studentsControllerProvider);
        expect(state.hasError, false);
        verify(() => mockRepository.delete('student-1')).called(1);
      });

      test('should handle deletion error', () async {
        // Arrange
        when(() => mockRepository.delete('student-1'))
            .thenThrow(Exception('Deletion failed'));

        final controller = container.read(studentsControllerProvider.notifier);

        // Act
        await controller.deleteStudent('student-1');

        // Assert
        final state = container.read(studentsControllerProvider);
        expect(state.hasError, true);
        expect(state.error.toString(), contains('Deletion failed'));
      });
    });
  });
}

