import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutor_zone/core/debug_log/logger.dart';

part 'app_access_mode.g.dart';

/// Supported access modes for the application.
enum AppAccessMode {
  local,
  cloud,
}

const _prefsKey = 'app_access_mode';

/// Reads the persisted access mode before the widget tree is mounted.
Future<AppAccessMode> loadInitialAccessMode() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefsKey);
    final mode = AppAccessMode.values.firstWhere(
      (value) => value.name == stored,
      orElse: () => AppAccessMode.local,
    );
    logInfo('Loaded persisted access mode: ${mode.name}');
    return mode;
  } catch (error, stackTrace) {
    logError('Failed to load access mode, defaulting to local', error, stackTrace);
    return AppAccessMode.local;
  }
}

@Riverpod(keepAlive: true)
class AppAccessModeNotifier extends _$AppAccessModeNotifier {
  SharedPreferences? _prefs;

  @override
  FutureOr<AppAccessMode> build() async {
    _prefs = await SharedPreferences.getInstance();
    final stored = _prefs!.getString(_prefsKey);
    final mode = AppAccessMode.values.firstWhere(
      (value) => value.name == stored,
      orElse: () => AppAccessMode.local,
    );
    return mode;
  }

  Future<void> setMode(AppAccessMode mode) async {
    logInfo('Switching app access mode to ${mode.name}');

    state = AsyncValue.data(mode);
    try {
      await _ensurePrefs().setString(_prefsKey, mode.name);
    } catch (error, stackTrace) {
      logError('Failed to persist app access mode', error, stackTrace);
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  SharedPreferences _ensurePrefs() {
    final prefs = _prefs;
    if (prefs != null) {
      return prefs;
    }
    throw StateError('SharedPreferences not initialised');
  }
}
