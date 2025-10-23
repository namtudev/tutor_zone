import 'dart:io' show Directory;

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart' as sembast_io;
import 'package:sembast_web/sembast_web.dart' as sembast_web;
import 'package:tutor_zone/core/debug_log/logger.dart';

part 'sembast_db.g.dart';

/// Default database file name.
const _dbFileName = 'tutor_zone.db';

/// Current schema version.
const _schemaVersion = 1;

/// Store names as constants.
class StoreNames {
  /// Schema state store name
  static const schemaState = 'schema_state';

  /// Students store name
  static const students = 'students';

  /// Sessions store name
  static const sessions = 'sessions';

  /// Balance changes store name
  static const balanceChanges = 'balance_changes';

  /// Recurring schedules store name
  static const recurringSchedules = 'recurring_schedules';

  /// App preferences store name
  static const appPrefs = 'app_prefs';
}

/// Sembast database provider with schema initialization.
/// Let Riverpod handle caching - no manual global state.
@Riverpod(keepAlive: true)
Future<Database> sembastDatabase(Ref ref) async {
  final db = await _openDatabase();

  // Initialize schema on first boot
  await _initializeSchema(db);

  ref.onDispose(() async {
    logInfo('Closing Sembast database');
    await db.close();
  });

  return db;
}

/// Typed store references for type-safe access.
/// These are stateless singletons - safe to use as top-level constants.

/// Schema state store for tracking migrations.
final schemaStateStore = StoreRef<String, Map<String, Object?>>(StoreNames.schemaState);

/// Students store.
final studentsStore = StoreRef<String, Map<String, Object?>>(StoreNames.students);

/// Sessions store.
final sessionsStore = StoreRef<String, Map<String, Object?>>(StoreNames.sessions);

/// Balance changes store.
final balanceChangesStore = StoreRef<String, Map<String, Object?>>(StoreNames.balanceChanges);

/// Recurring schedules store.
final recurringSchedulesStore = StoreRef<String, Map<String, Object?>>(StoreNames.recurringSchedules);

/// App preferences store for generic key-value pairs.
final appPrefsStore = StoreRef<String, Map<String, Object?>>(StoreNames.appPrefs);

/// Open the database with platform-specific factory.
Future<Database> _openDatabase() async {
  final databasePath = await _resolveDatabasePath();
  logInfo('Opening Sembast database at $databasePath');

  final factory = kIsWeb ? sembast_web.databaseFactoryWeb : sembast_io.databaseFactoryIo;
  return factory.openDatabase(databasePath);
}

/// Resolve database path based on platform.
Future<String> _resolveDatabasePath() async {
  if (kIsWeb) {
    return _dbFileName;
  }

  final supportDir = await getApplicationSupportDirectory();
  final dbDir = Directory(p.join(supportDir.path, 'tutor_zone'));
  if (!await dbDir.exists()) {
    await dbDir.create(recursive: true);
  }

  return p.join(dbDir.path, _dbFileName);
}

/// Initialize schema version on first boot.
Future<void> _initializeSchema(Database db) async {
  final schemaRecord = await schemaStateStore.record('current').get(db);

  if (schemaRecord == null) {
    // First boot - initialize schema version
    logInfo('Initializing schema version $_schemaVersion');
    await schemaStateStore.record('current').put(db, {
      'version': _schemaVersion,
      'migratedAt': DateTime.now().toIso8601String(),
    });
  } else {
    final currentVersion = schemaRecord['version']! as int;
    logInfo('Schema version: $currentVersion');

    // Future: Run migrations here if currentVersion < _schemaVersion
    if (currentVersion < _schemaVersion) {
      logWarning('Schema migration needed: $currentVersion -> $_schemaVersion');
      await _runMigrations(db, currentVersion, _schemaVersion);
    }
  }
}

/// Run schema migrations sequentially.
Future<void> _runMigrations(Database db, int fromVersion, int toVersion) async {
  logInfo('Running migrations from version $fromVersion to $toVersion');

  // Future migrations will be added here as needed
  // Example:
  // if (fromVersion < 2) {
  //   await _migrateToV2(db);
  // }

  // Update schema version
  await schemaStateStore.record('current').put(db, {
    'version': toVersion,
    'migratedAt': DateTime.now().toIso8601String(),
  });

  logInfo('Migration completed successfully');
}
