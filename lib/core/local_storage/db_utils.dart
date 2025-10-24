import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:tutor_zone/core/debug_log/logger.dart';

/// Database utilities for development and QA.
class DbUtils {
  /// Get the database file path for the current platform.
  /// Returns null on web (uses IndexedDB).
  static Future<String?> getDatabasePath() async {
    if (kIsWeb) {
      return null; // Web uses IndexedDB
    }

    final supportDir = await getApplicationSupportDirectory();
    final dbDir = Directory(p.join(supportDir.path, 'tutor_zone'));
    return p.join(dbDir.path, 'tutor_zone.db');
  }

  /// Delete the database file (for QA resets).
  /// Only works on non-web platforms.
  ///
  /// Usage:
  /// ```dart
  /// await DbUtils.deleteDatabaseFile();
  /// ```
  static Future<bool> deleteDatabaseFile() async {
    if (kIsWeb) {
      logWarning('Cannot delete database file on web platform');
      return false;
    }

    try {
      final dbPath = await getDatabasePath();
      if (dbPath == null) return false;

      final file = File(dbPath);
      if (await file.exists()) {
        await file.delete();
        logInfo('Database file deleted: $dbPath');
        return true;
      } else {
        logInfo('Database file does not exist: $dbPath');
        return false;
      }
    } catch (e, stack) {
      logError('Failed to delete database file', e, stack);
      return false;
    }
  }

  /// Get database file size in bytes.
  /// Returns null on web or if file doesn't exist.
  static Future<int?> getDatabaseSize() async {
    if (kIsWeb) return null;

    try {
      final dbPath = await getDatabasePath();
      if (dbPath == null) return null;

      final file = File(dbPath);
      if (await file.exists()) {
        return await file.length();
      }
      return null;
    } catch (e, stack) {
      logError('Failed to get database size', e, stack);
      return null;
    }
  }

  /// Format bytes to human-readable string.
  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// Log database statistics (for debug builds).
  static Future<void> logDatabaseStats() async {
    if (!kDebugMode) return;

    final path = await getDatabasePath();
    final size = await getDatabaseSize();

    logInfo('=== Database Stats ===');
    logInfo('Path: ${path ?? "IndexedDB (web)"}');
    if (size != null) {
      logInfo('Size: ${formatBytes(size)}');
    }
    logInfo('======================');
  }
}
