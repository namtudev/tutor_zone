import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:tutor_zone/core/debug_log/logger.dart';
import 'package:tutor_zone/features/students/models/data/student.dart';
import 'package:tutor_zone/features/students/models/data_sources/student_local_data_source.dart';

void main() {
  group('StudentLocalDataSource Tests', () {
    late Database db;
    late StudentLocalDataSource dataSource;

    setUpAll(() {
      // Initialize Talker for logging in tests
      initializeTalker();
    });

    setUp(() async {
      // Create in-memory database for testing (use unique name for each test)
      db = await databaseFactoryMemory.openDatabase('test_${DateTime.now().millisecondsSinceEpoch}.db');
      dataSource = StudentLocalDataSource(db);
    });

    tearDown(() async {
      await db.close();
    });

    // Helper to create test student
    Student createTestStudent({
      String id = 'student-1',
      String name = 'John Doe',
      int hourlyRateCents = 4000,
      int balanceCents = 0,
    }) {
      return Student.create(
        id: id,
        name: name,
        hourlyRateCents: hourlyRateCents,
        balanceCents: balanceCents,
      );
    }

    group('CRUD Operations', () {
      test('create should save student to database', () async {
        // Arrange
        final student = createTestStudent();

        // Act
        final result = await dataSource.create(student);

        // Assert
        expect(result, student);
        final retrieved = await dataSource.getById(student.id);
        expect(retrieved, isNotNull);
        expect(retrieved!.id, student.id);
        expect(retrieved.name, student.name);
      });

      test('getById should return student when exists', () async {
        // Arrange
        final student = createTestStudent();
        await dataSource.create(student);

        // Act
        final result = await dataSource.getById(student.id);

        // Assert
        expect(result, isNotNull);
        expect(result!.id, student.id);
        expect(result.name, student.name);
      });

      test('getById should return null when student does not exist', () async {
        // Act
        final result = await dataSource.getById('non-existent');

        // Assert
        expect(result, isNull);
      });

      test('getAll should return all students', () async {
        // Arrange
        final student1 = createTestStudent(name: 'Alice');
        final student2 = createTestStudent(id: 'student-2', name: 'Bob');
        final student3 = createTestStudent(id: 'student-3', name: 'Charlie');
        await dataSource.create(student1);
        await dataSource.create(student2);
        await dataSource.create(student3);

        // Act
        final result = await dataSource.getAll();

        // Assert
        expect(result.length, 3);
        expect(result.map((s) => s.id), containsAll(['student-1', 'student-2', 'student-3']));
      });

      test('getAllSorted should return students sorted by name', () async {
        // Arrange
        final student1 = createTestStudent(name: 'Charlie');
        final student2 = createTestStudent(id: 'student-2', name: 'Alice');
        final student3 = createTestStudent(id: 'student-3', name: 'Bob');
        await dataSource.create(student1);
        await dataSource.create(student2);
        await dataSource.create(student3);

        // Act
        final result = await dataSource.getAllSorted();

        // Assert
        expect(result.length, 3);
        expect(result[0].name, 'Alice');
        expect(result[1].name, 'Bob');
        expect(result[2].name, 'Charlie');
      });

      test('update should modify existing student', () async {
        // Arrange
        final student = createTestStudent();
        await dataSource.create(student);
        final updated = student.copyWith(name: 'Jane Doe', hourlyRateCents: 5000);

        // Act
        final result = await dataSource.update(updated);

        // Assert
        expect(result.name, 'Jane Doe');
        expect(result.hourlyRateCents, 5000);

        final retrieved = await dataSource.getById(student.id);
        expect(retrieved!.name, 'Jane Doe');
        expect(retrieved.hourlyRateCents, 5000);
      });

      test('update should throw when student does not exist', () {
        // Arrange
        final student = createTestStudent();

        // Act & Assert
        expect(
          () => dataSource.update(student),
          throwsA(isA<Exception>()),
        );
      });

      test('updateBalance should update student balance', () async {
        // Arrange
        final student = createTestStudent(balanceCents: 1000);
        await dataSource.create(student);

        // Act
        await dataSource.updateBalance(student.id, 5000);

        // Assert
        final retrieved = await dataSource.getById(student.id);
        expect(retrieved!.balanceCents, 5000);
      });

      test('delete should remove student from database', () async {
        // Arrange
        final student = createTestStudent();
        await dataSource.create(student);

        // Act
        await dataSource.delete(student.id);

        // Assert
        final retrieved = await dataSource.getById(student.id);
        expect(retrieved, isNull);
      });

      test('deleteAll should remove all students', () async {
        // Arrange
        await dataSource.create(createTestStudent());
        await dataSource.create(createTestStudent(id: 'student-2'));
        await dataSource.create(createTestStudent(id: 'student-3'));

        // Act
        await dataSource.deleteAll();

        // Assert
        final result = await dataSource.getAll();
        expect(result, isEmpty);
      });
    });

    group('Query Operations', () {
      test('searchByName should return matching students (case-insensitive)', () async {
        // Arrange
        await dataSource.create(createTestStudent(name: 'Alice Johnson'));
        await dataSource.create(createTestStudent(id: 'student-2', name: 'Bob Smith'));
        await dataSource.create(createTestStudent(id: 'student-3', name: 'Alice Brown'));

        // Act
        final result = await dataSource.searchByName('alice');

        // Assert
        expect(result.length, 2);
        expect(result.map((s) => s.name), containsAll(['Alice Johnson', 'Alice Brown']));
      });

      test('searchByName should return all students when query is empty', () async {
        // Arrange
        await dataSource.create(createTestStudent(name: 'Alice'));
        await dataSource.create(createTestStudent(id: 'student-2', name: 'Bob'));

        // Act
        final result = await dataSource.searchByName('');

        // Assert
        expect(result.length, 2);
      });

      test('getStudentsWithNegativeBalance should return only students with negative balance', () async {
        // Arrange
        await dataSource.create(createTestStudent(balanceCents: -5000));
        await dataSource.create(createTestStudent(id: 'student-2', balanceCents: 1000));
        await dataSource.create(createTestStudent(id: 'student-3', balanceCents: -2000));
        await dataSource.create(createTestStudent(id: 'student-4'));

        // Act
        final result = await dataSource.getStudentsWithNegativeBalance();

        // Assert
        expect(result.length, 2);
        expect(result.map((s) => s.id), containsAll(['student-1', 'student-3']));
        // Most negative first
        expect(result[0].balanceCents, -5000);
        expect(result[1].balanceCents, -2000);
      });

      test('getStudentsWithPositiveBalance should return only students with positive balance', () async {
        // Arrange
        await dataSource.create(createTestStudent(balanceCents: 5000));
        await dataSource.create(createTestStudent(id: 'student-2', balanceCents: -1000));
        await dataSource.create(createTestStudent(id: 'student-3', balanceCents: 2000));
        await dataSource.create(createTestStudent(id: 'student-4'));

        // Act
        final result = await dataSource.getStudentsWithPositiveBalance();

        // Assert
        expect(result.length, 2);
        expect(result.map((s) => s.id), containsAll(['student-1', 'student-3']));
        // Highest first
        expect(result[0].balanceCents, 5000);
        expect(result[1].balanceCents, 2000);
      });
    });

    group('Utility Operations', () {
      test('exists should return true when student exists', () async {
        // Arrange
        final student = createTestStudent();
        await dataSource.create(student);

        // Act
        final result = await dataSource.exists(student.id);

        // Assert
        expect(result, true);
      });

      test('exists should return false when student does not exist', () async {
        // Act
        final result = await dataSource.exists('non-existent');

        // Assert
        expect(result, false);
      });

      test('count should return correct number of students', () async {
        // Arrange
        await dataSource.create(createTestStudent());
        await dataSource.create(createTestStudent(id: 'student-2'));
        await dataSource.create(createTestStudent(id: 'student-3'));

        // Act
        final result = await dataSource.count();

        // Assert
        expect(result, 3);
      });

      test('count should return 0 when no students exist', () async {
        // Act
        final result = await dataSource.count();

        // Assert
        expect(result, 0);
      });
    });

    group('Stream Operations', () {
      test('watchAll should emit all students sorted by name', () async {
        // Arrange
        await dataSource.create(createTestStudent(name: 'Charlie'));
        await dataSource.create(createTestStudent(id: 'student-2', name: 'Alice'));
        await dataSource.create(createTestStudent(id: 'student-3', name: 'Bob'));

        // Act
        final stream = dataSource.watchAll();

        // Assert
        await expectLater(
          stream.first,
          completion(predicate<List<Student>>((students) {
            return students.length == 3 &&
                students[0].name == 'Alice' &&
                students[1].name == 'Bob' &&
                students[2].name == 'Charlie';
          })),
        );
      });

      test('watchById should emit student when exists', () async {
        // Arrange
        final student = createTestStudent();
        await dataSource.create(student);

        // Act
        final stream = dataSource.watchById(student.id);

        // Assert
        await expectLater(
          stream.first,
          completion(predicate<Student?>((s) => s != null && s.id == student.id)),
        );
      });

      test('watchById should emit null when student does not exist', () async {
        // Act
        final stream = dataSource.watchById('non-existent');

        // Assert
        await expectLater(stream.first, completion(isNull));
      });

      test('watchStudentsWithNegativeBalance should emit only students with negative balance', () async {
        // Arrange
        await dataSource.create(createTestStudent(balanceCents: -5000));
        await dataSource.create(createTestStudent(id: 'student-2', balanceCents: 1000));
        await dataSource.create(createTestStudent(id: 'student-3', balanceCents: -2000));

        // Act
        final stream = dataSource.watchStudentsWithNegativeBalance();

        // Assert
        await expectLater(
          stream.first,
          completion(predicate<List<Student>>((students) {
            return students.length == 2 &&
                students.every((s) => s.balanceCents < 0) &&
                students[0].balanceCents == -5000 && // Most negative first
                students[1].balanceCents == -2000;
          })),
        );
      });

      test('watchAll should emit updates when student is added', () async {
        // Arrange
        final stream = dataSource.watchAll();
        final emittedValues = <List<Student>>[];

        // Act
        final subscription = stream.listen(emittedValues.add);
        await Future.delayed(const Duration(milliseconds: 50)); // Wait for initial emit

        await dataSource.create(createTestStudent(name: 'Alice'));
        await Future.delayed(const Duration(milliseconds: 50)); // Wait for update

        await subscription.cancel();

        // Assert
        expect(emittedValues.length, greaterThanOrEqualTo(2));
        expect(emittedValues.first, isEmpty); // Initial state
        expect(emittedValues.last.length, 1); // After adding student
        expect(emittedValues.last.first.name, 'Alice');
      });

      test('watchById should emit updates when student is modified', () async {
        // Arrange
        final student = createTestStudent();
        await dataSource.create(student);

        final stream = dataSource.watchById(student.id);
        final emittedValues = <Student?>[];

        // Act
        final subscription = stream.listen(emittedValues.add);
        await Future.delayed(const Duration(milliseconds: 50)); // Wait for initial emit

        await dataSource.update(student.copyWith(name: 'Jane Doe'));
        await Future.delayed(const Duration(milliseconds: 50)); // Wait for update

        await subscription.cancel();

        // Assert
        expect(emittedValues.length, greaterThanOrEqualTo(2));
        expect(emittedValues.first!.name, 'John Doe'); // Initial state
        expect(emittedValues.last!.name, 'Jane Doe'); // After update
      });
    });
  });
}

