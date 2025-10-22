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

Database? _cachedDatabase;

@Riverpod(keepAlive: true)
Future<Database> sembastDatabase(Ref ref) async {
  if (_cachedDatabase != null) {
    return _cachedDatabase!;
  }

  final databasePath = await _resolveDatabasePath();
  logInfo('Opening Sembast database at $databasePath');

  final factory = kIsWeb ? sembast_web.databaseFactoryWeb : sembast_io.databaseFactoryIo;
  final db = await factory.openDatabase(databasePath);
  _cachedDatabase = db;

  ref.onDispose(() async {
    if (_cachedDatabase != null) {
      logInfo('Closing Sembast database');
      await _cachedDatabase!.close();
      _cachedDatabase = null;
    }
  });

  return db;
}

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
