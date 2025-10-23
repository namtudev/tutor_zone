import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tutor_zone/core/debug_log/logger.dart';
import 'package:tutor_zone/features/balance/domain/allocation_service.dart';
import 'package:tutor_zone/features/sessions/controllers/sessions_controller.dart';
import 'package:tutor_zone/features/sessions/models/data/session.dart';
import 'package:tutor_zone/features/sessions/models/repositories/session_repository.dart';

/// Mock SessionRepository
class MockSessionRepository extends Mock implements SessionRepository {}

/// Mock AllocationService
class MockAllocationService extends Mock implements AllocationService {}

void main() {
  setUpAll(() {
    initializeTalker();
    // Register fallback values for mocktail
    registerFallbackValue(
      Session.create(
        id: 'test-id',
        studentId: 'student-1',
        start: DateTime(2025, 1, 15, 10, 0),
        end: DateTime(2025, 1, 15, 11, 0),
        rateSnapshotCents: 5000,
      ),
    );
  });

  group('SessionsController Tests', () {
    late MockSessionRepository mockRepository;
    late MockAllocationService mockAllocationService;
    late ProviderContainer container;

    setUp(() {
      mockRepository = MockSessionRepository();
      mockAllocationService = MockAllocationService();
      container = ProviderContainer(
        overrides: [
          sessionRepositoryProvider.overrideWithValue(mockRepository),
          allocationServiceProvider.overrideWithValue(mockAllocationService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('createSession', () {
      test('should create session successfully', () async {
        // Arrange
        final session = Session.create(
          id: 'session-1',
          studentId: 'student-1',
          start: DateTime(2025, 1, 15, 10, 0),
          end: DateTime(2025, 1, 15, 11, 0),
          rateSnapshotCents: 5000,
        );
        when(() => mockRepository.create(any())).thenAnswer((_) async => session);

        final controller = container.read(sessionsControllerProvider.notifier);

        // Act
        await controller.createSession(
          studentId: 'student-1',
          start: DateTime(2025, 1, 15, 10, 0),
          end: DateTime(2025, 1, 15, 11, 0),
          rateSnapshotCents: 5000,
        );

        // Assert
        final state = container.read(sessionsControllerProvider);
        expect(state.hasError, false);
        verify(() => mockRepository.create(any())).called(1);
      });

      test('should handle creation error', () async {
        // Arrange
        when(() => mockRepository.create(any()))
            .thenThrow(Exception('Database error'));

        final controller = container.read(sessionsControllerProvider.notifier);

        // Act
        await controller.createSession(
          studentId: 'student-1',
          start: DateTime(2025, 1, 15, 10, 0),
          end: DateTime(2025, 1, 15, 11, 0),
          rateSnapshotCents: 5000,
        );

        // Assert
        final state = container.read(sessionsControllerProvider);
        expect(state.hasError, true);
        expect(state.error.toString(), contains('Database error'));
      });
    });

    group('updateSession', () {
      test('should update session successfully', () async {
        // Arrange
        final existingSession = Session.create(
          id: 'session-1',
          studentId: 'student-1',
          start: DateTime(2025, 1, 15, 10, 0),
          end: DateTime(2025, 1, 15, 11, 0),
          rateSnapshotCents: 5000,
        );

        when(() => mockRepository.getById('session-1'))
            .thenAnswer((_) async => existingSession);
        when(() => mockRepository.update(any())).thenAnswer((_) async => existingSession);
        when(() => mockAllocationService.runAllocationAfterSessionSave(any()))
            .thenAnswer((_) async => false);

        final controller = container.read(sessionsControllerProvider.notifier);

        // Act
        await controller.updateSession(
          id: 'session-1',
          studentId: 'student-1',
          start: DateTime(2025, 1, 15, 11, 0),
          end: DateTime(2025, 1, 15, 12, 0),
          rateSnapshotCents: 5000,
        );

        // Assert
        final state = container.read(sessionsControllerProvider);
        expect(state.hasError, false);
        verify(() => mockRepository.update(any())).called(1);
      });

      test('should throw when session not found', () async {
        // Arrange
        when(() => mockRepository.getById('session-1'))
            .thenAnswer((_) async => null);

        final controller = container.read(sessionsControllerProvider.notifier);

        // Act
        await controller.updateSession(
          id: 'session-1',
          studentId: 'student-1',
          start: DateTime(2025, 1, 15, 10, 0),
          end: DateTime(2025, 1, 15, 11, 0),
          rateSnapshotCents: 5000,
        );

        // Assert
        final state = container.read(sessionsControllerProvider);
        expect(state.hasError, true);
        expect(state.error.toString(), contains('Session not found'));
      });
    });

    group('deleteSession', () {
      test('should delete session successfully', () async {
        // Arrange
        when(() => mockRepository.delete('session-1'))
            .thenAnswer((_) async {});

        final controller = container.read(sessionsControllerProvider.notifier);

        // Act
        await controller.deleteSession('session-1');

        // Assert
        final state = container.read(sessionsControllerProvider);
        expect(state.hasError, false);
        verify(() => mockRepository.delete('session-1')).called(1);
      });
    });

    group('markSessionAsPaid', () {
      test('should mark session as paid successfully', () async {
        // Arrange
        final session = Session.create(
          id: 'session-1',
          studentId: 'student-1',
          start: DateTime(2025, 1, 15, 10, 0),
          end: DateTime(2025, 1, 15, 11, 0),
          rateSnapshotCents: 5000,
        );

        when(() => mockRepository.getById('session-1'))
            .thenAnswer((_) async => session);
        when(() => mockRepository.update(any())).thenAnswer((_) async => session);

        final controller = container.read(sessionsControllerProvider.notifier);

        // Act
        await controller.markSessionAsPaid('session-1');

        // Assert
        final state = container.read(sessionsControllerProvider);
        expect(state.hasError, false);
        verify(() => mockRepository.update(any())).called(1);
      });

      test('should throw when session not found', () async {
        // Arrange
        when(() => mockRepository.getById('session-1'))
            .thenAnswer((_) async => null);

        final controller = container.read(sessionsControllerProvider.notifier);

        // Act
        await controller.markSessionAsPaid('session-1');

        // Assert
        final state = container.read(sessionsControllerProvider);
        expect(state.hasError, true);
        expect(state.error.toString(), contains('Session not found'));
      });
    });

    group('markSessionAsUnpaid', () {
      test('should mark session as unpaid successfully', () async {
        // Arrange
        final session = Session.create(
          id: 'session-1',
          studentId: 'student-1',
          start: DateTime(2025, 1, 15, 10, 0),
          end: DateTime(2025, 1, 15, 11, 0),
          rateSnapshotCents: 5000,
          payStatus: PaymentStatus.paid,
        );

        when(() => mockRepository.getById('session-1'))
            .thenAnswer((_) async => session);
        when(() => mockRepository.update(any())).thenAnswer((_) async => session);

        final controller = container.read(sessionsControllerProvider.notifier);

        // Act
        await controller.markSessionAsUnpaid('session-1');

        // Assert
        final state = container.read(sessionsControllerProvider);
        expect(state.hasError, false);
        verify(() => mockRepository.update(any())).called(1);
      });
    });

    group('markSessionAsCompleted', () {
      test('should mark session as completed successfully', () async {
        // Arrange
        final session = Session.create(
          id: 'session-1',
          studentId: 'student-1',
          start: DateTime(2025, 1, 15, 10, 0),
          end: DateTime(2025, 1, 15, 11, 0),
          rateSnapshotCents: 5000,
        );

        when(() => mockRepository.getById('session-1'))
            .thenAnswer((_) async => session);
        when(() => mockRepository.update(any())).thenAnswer((_) async => session);

        final controller = container.read(sessionsControllerProvider.notifier);

        // Act
        await controller.markSessionAsCompleted('session-1');

        // Assert
        final state = container.read(sessionsControllerProvider);
        expect(state.hasError, false);
        verify(() => mockRepository.update(any())).called(1);
      });
    });

    group('markSessionAsSkipped', () {
      test('should mark session as skipped successfully', () async {
        // Arrange
        final session = Session.create(
          id: 'session-1',
          studentId: 'student-1',
          start: DateTime(2025, 1, 15, 10, 0),
          end: DateTime(2025, 1, 15, 11, 0),
          rateSnapshotCents: 5000,
        );

        when(() => mockRepository.getById('session-1'))
            .thenAnswer((_) async => session);
        when(() => mockRepository.update(any())).thenAnswer((_) async => session);

        final controller = container.read(sessionsControllerProvider.notifier);

        // Act
        await controller.markSessionAsSkipped('session-1');

        // Assert
        final state = container.read(sessionsControllerProvider);
        expect(state.hasError, false);
        verify(() => mockRepository.update(any())).called(1);
      });
    });
  });
}

