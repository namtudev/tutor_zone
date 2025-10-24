import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tutor_zone/core/debug_log/logger.dart';
import 'package:tutor_zone/features/sessions/controllers/recurring_schedule_controller.dart';
import 'package:tutor_zone/features/sessions/domain/session_generation_service.dart';
import 'package:tutor_zone/features/sessions/models/data/recurring_schedule.dart';
import 'package:tutor_zone/features/sessions/models/data_sources/recurring_schedule_local_data_source.dart';

import 'recurring_schedule_controller_test.mocks.dart';

// Generate mocks
@GenerateNiceMocks([
  MockSpec<RecurringScheduleLocalDataSource>(),
  MockSpec<SessionGenerationService>(),
])

void main() {
  group('RecurringScheduleController Tests', () {
    late MockRecurringScheduleLocalDataSource mockDataSource;
    late MockSessionGenerationService mockGenerationService;
    late ProviderContainer container;

    setUpAll(() {
      // Initialize Talker for logging in tests
      initializeTalker();
    });

    setUp(() {
      mockDataSource = MockRecurringScheduleLocalDataSource();
      mockGenerationService = MockSessionGenerationService();

      // Use ProviderContainer.test() for automatic disposal
      container = ProviderContainer.test(
        overrides: [
          recurringScheduleLocalDataSourceProvider.overrideWithValue(mockDataSource),
          sessionGenerationServiceProvider.overrideWithValue(mockGenerationService),
        ],
      );
    });

    // Helper to create test recurring schedule
    RecurringSchedule createTestSchedule({
      String id = 'schedule-1',
      String studentId = 'student-1',
      int weekday = 1, // Monday
      String startLocal = '14:00',
      String endLocal = '15:00',
      int rateSnapshotCents = 4000,
      bool isActive = true,
    }) {
      return RecurringSchedule.create(
        id: id,
        studentId: studentId,
        weekday: weekday,
        startLocal: startLocal,
        endLocal: endLocal,
        rateSnapshotCents: rateSnapshotCents,
        isActive: isActive,
      );
    }

    group('createSchedule', () {
      test('should create active schedule and generate sessions', () async {
        // Arrange
        const studentId = 'student-1';
        const weekday = 1;
        const startLocal = '14:00';
        const endLocal = '15:00';
        const rateSnapshotCents = 4000;

        when(mockDataSource.create(any)).thenAnswer((_) async => createTestSchedule());
        when(mockDataSource.getById(any)).thenAnswer((_) async => createTestSchedule());
        when(mockGenerationService.generateSessionsForSchedule(any, weeksAhead: anyNamed('weeksAhead')))
            .thenAnswer((_) async => 8);

        // Act
        final controller = container.read(recurringScheduleControllerProvider.notifier);
        await controller.createSchedule(
          studentId: studentId,
          weekday: weekday,
          startLocal: startLocal,
          endLocal: endLocal,
          rateSnapshotCents: rateSnapshotCents,
        );

        // Assert
        verify(mockDataSource.create(argThat(isA<RecurringSchedule>()))).called(1);
        verify(mockDataSource.getById(any)).called(1);
        verify(mockGenerationService.generateSessionsForSchedule(any, weeksAhead: anyNamed('weeksAhead'))).called(1);
      });

      test('should create inactive schedule without generating sessions', () async {
        // Arrange
        const studentId = 'student-1';
        const weekday = 1;
        const startLocal = '14:00';
        const endLocal = '15:00';
        const rateSnapshotCents = 4000;

        when(mockDataSource.create(any)).thenAnswer((_) async => createTestSchedule(isActive: false));

        // Act
        final controller = container.read(recurringScheduleControllerProvider.notifier);
        await controller.createSchedule(
          studentId: studentId,
          weekday: weekday,
          startLocal: startLocal,
          endLocal: endLocal,
          rateSnapshotCents: rateSnapshotCents,
          isActive: false,
        );

        // Assert
        verify(mockDataSource.create(argThat(isA<RecurringSchedule>()))).called(1);
        verifyNever(mockDataSource.getById(any));
        verifyNever(mockGenerationService.generateSessionsForSchedule(any, weeksAhead: anyNamed('weeksAhead')));
      });

      test('should handle creation error gracefully', () {
        // Arrange
        const studentId = 'student-1';
        const weekday = 1;
        const startLocal = '14:00';
        const endLocal = '15:00';
        const rateSnapshotCents = 4000;

        when(mockDataSource.create(any)).thenThrow(Exception('Database error'));

        // Act & Assert
        final controller = container.read(recurringScheduleControllerProvider.notifier);
        expect(
          () => controller.createSchedule(
            studentId: studentId,
            weekday: weekday,
            startLocal: startLocal,
            endLocal: endLocal,
            rateSnapshotCents: rateSnapshotCents,
          ),
          throwsException,
        );
      });
    });

    group('updateSchedule', () {
      test('should update schedule successfully', () async {
        // Arrange
        const scheduleId = 'schedule-1';
        final existingSchedule = createTestSchedule();
        final updatedSchedule = existingSchedule.update(weekday: 2);

        when(mockDataSource.getById(scheduleId)).thenAnswer((_) async => existingSchedule);
        when(mockDataSource.update(any)).thenAnswer((_) async => updatedSchedule);
        when(mockGenerationService.deleteFutureSessionsForSchedule(scheduleId)).thenAnswer((_) async => 5);
        when(mockDataSource.getById(scheduleId)).thenAnswer((_) async => updatedSchedule);
        when(mockGenerationService.generateSessionsForSchedule(any, weeksAhead: anyNamed('weeksAhead')))
            .thenAnswer((_) async => 8);

        // Act
        final controller = container.read(recurringScheduleControllerProvider.notifier);
        await controller.updateSchedule(scheduleId: scheduleId, weekday: 2);

        // Assert
        verify(mockDataSource.getById(scheduleId)).called(greaterThanOrEqualTo(1));
        verify(mockDataSource.update(argThat(isA<RecurringSchedule>()))).called(1);
      });

      test('should regenerate sessions when time changes', () async {
        // Arrange
        const scheduleId = 'schedule-1';
        final existingSchedule = createTestSchedule();
        final updatedSchedule = existingSchedule.update(startLocal: '15:00');

        when(mockDataSource.getById(scheduleId)).thenAnswer((_) async => existingSchedule);
        when(mockDataSource.update(any)).thenAnswer((_) async => updatedSchedule);
        when(mockGenerationService.deleteFutureSessionsForSchedule(scheduleId)).thenAnswer((_) async => 5);
        when(mockDataSource.getById(scheduleId)).thenAnswer((_) async => updatedSchedule);
        when(mockGenerationService.generateSessionsForSchedule(any, weeksAhead: anyNamed('weeksAhead')))
            .thenAnswer((_) async => 8);

        // Act
        final controller = container.read(recurringScheduleControllerProvider.notifier);
        await controller.updateSchedule(scheduleId: scheduleId, startLocal: '15:00');

        // Assert
        verify(mockGenerationService.deleteFutureSessionsForSchedule(scheduleId)).called(1);
        verify(mockGenerationService.generateSessionsForSchedule(any, weeksAhead: anyNamed('weeksAhead'))).called(1);
      });

      test('should not regenerate sessions when only rate changes', () async {
        // Arrange
        const scheduleId = 'schedule-1';
        final existingSchedule = createTestSchedule();
        final updatedSchedule = existingSchedule.update(rateSnapshotCents: 5000);

        when(mockDataSource.getById(scheduleId)).thenAnswer((_) async => existingSchedule);
        when(mockDataSource.update(any)).thenAnswer((_) async => updatedSchedule);

        // Act
        final controller = container.read(recurringScheduleControllerProvider.notifier);
        await controller.updateSchedule(scheduleId: scheduleId, rateSnapshotCents: 5000);

        // Assert
        verify(mockDataSource.update(argThat(isA<RecurringSchedule>()))).called(1);
        verifyNever(mockGenerationService.deleteFutureSessionsForSchedule(any));
        verifyNever(mockGenerationService.generateSessionsForSchedule(any, weeksAhead: anyNamed('weeksAhead')));
      });

      test('should throw error when schedule not found', () {
        // Arrange
        const scheduleId = 'schedule-1';

        when(mockDataSource.getById(scheduleId)).thenAnswer((_) async => null);

        // Act & Assert
        final controller = container.read(recurringScheduleControllerProvider.notifier);
        expect(
          () => controller.updateSchedule(scheduleId: scheduleId, weekday: 2),
          throwsException,
        );
      });

      test('should handle update error gracefully', () {
        // Arrange
        const scheduleId = 'schedule-1';
        final existingSchedule = createTestSchedule();

        when(mockDataSource.getById(scheduleId)).thenAnswer((_) async => existingSchedule);
        when(mockDataSource.update(any)).thenThrow(Exception('Database error'));

        // Act & Assert
        final controller = container.read(recurringScheduleControllerProvider.notifier);
        expect(
          () => controller.updateSchedule(scheduleId: scheduleId, weekday: 2),
          throwsException,
        );
      });
    });

    group('deleteSchedule', () {
      test('should delete schedule and future sessions', () async {
        // Arrange
        const scheduleId = 'schedule-1';

        when(mockGenerationService.deleteFutureSessionsForSchedule(scheduleId)).thenAnswer((_) async => 5);
        when(mockDataSource.delete(scheduleId)).thenAnswer((_) async => {});

        // Act
        final controller = container.read(recurringScheduleControllerProvider.notifier);
        await controller.deleteSchedule(scheduleId);

        // Assert
        verify(mockGenerationService.deleteFutureSessionsForSchedule(scheduleId)).called(1);
        verify(mockDataSource.delete(scheduleId)).called(1);
      });

      test('should handle deletion error gracefully', () {
        // Arrange
        const scheduleId = 'schedule-1';

        when(mockGenerationService.deleteFutureSessionsForSchedule(scheduleId)).thenThrow(Exception('Database error'));

        // Act & Assert
        final controller = container.read(recurringScheduleControllerProvider.notifier);
        expect(
          () => controller.deleteSchedule(scheduleId),
          throwsException,
        );
      });
    });

    group('activateSchedule', () {
      test('should activate schedule and generate sessions', () async {
        // Arrange
        const scheduleId = 'schedule-1';
        final inactiveSchedule = createTestSchedule(isActive: false);
        final activeSchedule = inactiveSchedule.activate();

        when(mockDataSource.getById(scheduleId)).thenAnswer((_) async => inactiveSchedule);
        when(mockDataSource.update(any)).thenAnswer((_) async => activeSchedule);
        when(mockDataSource.getById(scheduleId)).thenAnswer((_) async => activeSchedule);
        when(mockGenerationService.generateSessionsForSchedule(any, weeksAhead: anyNamed('weeksAhead')))
            .thenAnswer((_) async => 8);

        // Act
        final controller = container.read(recurringScheduleControllerProvider.notifier);
        await controller.activateSchedule(scheduleId);

        // Assert
        verify(mockDataSource.getById(scheduleId)).called(greaterThanOrEqualTo(1));
        verify(mockDataSource.update(argThat(isA<RecurringSchedule>()))).called(1);
        verify(mockGenerationService.generateSessionsForSchedule(any, weeksAhead: anyNamed('weeksAhead'))).called(1);
      });

      test('should throw error when schedule not found', () {
        // Arrange
        const scheduleId = 'schedule-1';

        when(mockDataSource.getById(scheduleId)).thenAnswer((_) async => null);

        // Act & Assert
        final controller = container.read(recurringScheduleControllerProvider.notifier);
        expect(
          () => controller.activateSchedule(scheduleId),
          throwsException,
        );
      });

      test('should handle activation error gracefully', () {
        // Arrange
        const scheduleId = 'schedule-1';
        final inactiveSchedule = createTestSchedule(isActive: false);

        when(mockDataSource.getById(scheduleId)).thenAnswer((_) async => inactiveSchedule);
        when(mockDataSource.update(any)).thenThrow(Exception('Database error'));

        // Act & Assert
        final controller = container.read(recurringScheduleControllerProvider.notifier);
        expect(
          () => controller.activateSchedule(scheduleId),
          throwsException,
        );
      });
    });

    group('deactivateSchedule', () {
      test('should deactivate schedule and delete future sessions', () async {
        // Arrange
        const scheduleId = 'schedule-1';
        final activeSchedule = createTestSchedule();
        final inactiveSchedule = activeSchedule.deactivate();

        when(mockDataSource.getById(scheduleId)).thenAnswer((_) async => activeSchedule);
        when(mockGenerationService.deleteFutureSessionsForSchedule(scheduleId)).thenAnswer((_) async => 5);
        when(mockDataSource.update(any)).thenAnswer((_) async => inactiveSchedule);

        // Act
        final controller = container.read(recurringScheduleControllerProvider.notifier);
        await controller.deactivateSchedule(scheduleId);

        // Assert
        verify(mockDataSource.getById(scheduleId)).called(1);
        verify(mockGenerationService.deleteFutureSessionsForSchedule(scheduleId)).called(1);
        verify(mockDataSource.update(argThat(isA<RecurringSchedule>()))).called(1);
      });

      test('should throw error when schedule not found', () {
        // Arrange
        const scheduleId = 'schedule-1';

        when(mockDataSource.getById(scheduleId)).thenAnswer((_) async => null);

        // Act & Assert
        final controller = container.read(recurringScheduleControllerProvider.notifier);
        expect(
          () => controller.deactivateSchedule(scheduleId),
          throwsException,
        );
      });

      test('should handle deactivation error gracefully', () {
        // Arrange
        const scheduleId = 'schedule-1';
        final activeSchedule = createTestSchedule();

        when(mockDataSource.getById(scheduleId)).thenAnswer((_) async => activeSchedule);
        when(mockGenerationService.deleteFutureSessionsForSchedule(scheduleId)).thenThrow(Exception('Database error'));

        // Act & Assert
        final controller = container.read(recurringScheduleControllerProvider.notifier);
        expect(
          () => controller.deactivateSchedule(scheduleId),
          throwsException,
        );
      });
    });

    group('generateSessionsForSchedule', () {
      test('should generate sessions for schedule successfully', () async {
        // Arrange
        const scheduleId = 'schedule-1';
        final schedule = createTestSchedule();

        when(mockDataSource.getById(scheduleId)).thenAnswer((_) async => schedule);
        when(mockGenerationService.generateSessionsForSchedule(schedule, weeksAhead: anyNamed('weeksAhead')))
            .thenAnswer((_) async => 8);

        // Act
        final controller = container.read(recurringScheduleControllerProvider.notifier);
        final count = await controller.generateSessionsForSchedule(scheduleId);

        // Assert
        expect(count, 8);
        verify(mockDataSource.getById(scheduleId)).called(1);
        verify(mockGenerationService.generateSessionsForSchedule(schedule, weeksAhead: anyNamed('weeksAhead'))).called(1);
      });

      test('should generate sessions with custom weeks ahead', () async {
        // Arrange
        const scheduleId = 'schedule-1';
        final schedule = createTestSchedule();

        when(mockDataSource.getById(scheduleId)).thenAnswer((_) async => schedule);
        when(mockGenerationService.generateSessionsForSchedule(schedule, weeksAhead: 12))
            .thenAnswer((_) async => 12);

        // Act
        final controller = container.read(recurringScheduleControllerProvider.notifier);
        final count = await controller.generateSessionsForSchedule(scheduleId, weeksAhead: 12);

        // Assert
        expect(count, 12);
        verify(mockGenerationService.generateSessionsForSchedule(schedule, weeksAhead: 12)).called(1);
      });

      test('should throw error when schedule not found', () {
        // Arrange
        const scheduleId = 'schedule-1';

        when(mockDataSource.getById(scheduleId)).thenAnswer((_) async => null);

        // Act & Assert
        final controller = container.read(recurringScheduleControllerProvider.notifier);
        expect(
          () => controller.generateSessionsForSchedule(scheduleId),
          throwsException,
        );
      });

      test('should handle generation error gracefully', () {
        // Arrange
        const scheduleId = 'schedule-1';
        final schedule = createTestSchedule();

        when(mockDataSource.getById(scheduleId)).thenAnswer((_) async => schedule);
        when(mockGenerationService.generateSessionsForSchedule(schedule, weeksAhead: anyNamed('weeksAhead')))
            .thenThrow(Exception('Generation error'));

        // Act & Assert
        final controller = container.read(recurringScheduleControllerProvider.notifier);
        expect(
          () => controller.generateSessionsForSchedule(scheduleId),
          throwsException,
        );
      });
    });

    group('generateSessionsForStudent', () {
      test('should generate sessions for student successfully', () async {
        // Arrange
        const studentId = 'student-1';

        when(mockGenerationService.generateSessionsForStudent(studentId, weeksAhead: anyNamed('weeksAhead')))
            .thenAnswer((_) async => 16);

        // Act
        final controller = container.read(recurringScheduleControllerProvider.notifier);
        final count = await controller.generateSessionsForStudent(studentId);

        // Assert
        expect(count, 16);
        verify(mockGenerationService.generateSessionsForStudent(studentId, weeksAhead: anyNamed('weeksAhead'))).called(1);
      });

      test('should generate sessions with custom weeks ahead', () async {
        // Arrange
        const studentId = 'student-1';

        when(mockGenerationService.generateSessionsForStudent(studentId, weeksAhead: 12))
            .thenAnswer((_) async => 24);

        // Act
        final controller = container.read(recurringScheduleControllerProvider.notifier);
        final count = await controller.generateSessionsForStudent(studentId, weeksAhead: 12);

        // Assert
        expect(count, 24);
        verify(mockGenerationService.generateSessionsForStudent(studentId, weeksAhead: 12)).called(1);
      });

      test('should handle generation error gracefully', () {
        // Arrange
        const studentId = 'student-1';

        when(mockGenerationService.generateSessionsForStudent(studentId, weeksAhead: anyNamed('weeksAhead')))
            .thenThrow(Exception('Generation error'));

        // Act & Assert
        final controller = container.read(recurringScheduleControllerProvider.notifier);
        expect(
          () => controller.generateSessionsForStudent(studentId),
          throwsException,
        );
      });
    });

    group('generateAllSessions', () {
      test('should generate sessions for all active schedules successfully', () async {
        // Arrange
        when(mockGenerationService.generateAllSessions(weeksAhead: anyNamed('weeksAhead')))
            .thenAnswer((_) async => 32);

        // Act
        final controller = container.read(recurringScheduleControllerProvider.notifier);
        final count = await controller.generateAllSessions();

        // Assert
        expect(count, 32);
        verify(mockGenerationService.generateAllSessions(weeksAhead: anyNamed('weeksAhead'))).called(1);
      });

      test('should generate sessions with custom weeks ahead', () async {
        // Arrange
        when(mockGenerationService.generateAllSessions(weeksAhead: 12))
            .thenAnswer((_) async => 48);

        // Act
        final controller = container.read(recurringScheduleControllerProvider.notifier);
        final count = await controller.generateAllSessions(weeksAhead: 12);

        // Assert
        expect(count, 48);
        verify(mockGenerationService.generateAllSessions(weeksAhead: 12)).called(1);
      });

      test('should handle generation error gracefully', () {
        // Arrange
        when(mockGenerationService.generateAllSessions(weeksAhead: anyNamed('weeksAhead')))
            .thenThrow(Exception('Generation error'));

        // Act & Assert
        final controller = container.read(recurringScheduleControllerProvider.notifier);
        expect(
          () => controller.generateAllSessions(),
          throwsException,
        );
      });
    });

    group('regenerateSessionsForSchedule', () {
      test('should regenerate sessions successfully', () async {
        // Arrange
        const scheduleId = 'schedule-1';
        final schedule = createTestSchedule();

        when(mockGenerationService.deleteFutureSessionsForSchedule(scheduleId)).thenAnswer((_) async => 5);
        when(mockDataSource.getById(scheduleId)).thenAnswer((_) async => schedule);
        when(mockGenerationService.generateSessionsForSchedule(schedule, weeksAhead: anyNamed('weeksAhead')))
            .thenAnswer((_) async => 8);

        // Act
        final controller = container.read(recurringScheduleControllerProvider.notifier);
        final count = await controller.regenerateSessionsForSchedule(scheduleId);

        // Assert
        expect(count, 8);
        verify(mockGenerationService.deleteFutureSessionsForSchedule(scheduleId)).called(1);
        verify(mockDataSource.getById(scheduleId)).called(1);
        verify(mockGenerationService.generateSessionsForSchedule(schedule, weeksAhead: anyNamed('weeksAhead'))).called(1);
      });

      test('should regenerate sessions with custom weeks ahead', () async {
        // Arrange
        const scheduleId = 'schedule-1';
        final schedule = createTestSchedule();

        when(mockGenerationService.deleteFutureSessionsForSchedule(scheduleId)).thenAnswer((_) async => 5);
        when(mockDataSource.getById(scheduleId)).thenAnswer((_) async => schedule);
        when(mockGenerationService.generateSessionsForSchedule(schedule, weeksAhead: 12))
            .thenAnswer((_) async => 12);

        // Act
        final controller = container.read(recurringScheduleControllerProvider.notifier);
        final count = await controller.regenerateSessionsForSchedule(scheduleId, weeksAhead: 12);

        // Assert
        expect(count, 12);
        verify(mockGenerationService.generateSessionsForSchedule(schedule, weeksAhead: 12)).called(1);
      });

      test('should handle regeneration error gracefully', () {
        // Arrange
        const scheduleId = 'schedule-1';

        when(mockGenerationService.deleteFutureSessionsForSchedule(scheduleId)).thenThrow(Exception('Database error'));

        // Act & Assert
        final controller = container.read(recurringScheduleControllerProvider.notifier);
        expect(
          () => controller.regenerateSessionsForSchedule(scheduleId),
          throwsException,
        );
      });
    });
  });
}

