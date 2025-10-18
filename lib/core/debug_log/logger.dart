import 'package:talker_flutter/talker_flutter.dart';

/// Global instance of Talker for debug logging
late Talker _talker;

/// Initialize the logger
void initializeTalker() {
  _talker = Talker(settings: TalkerSettings());
}

/// Log info message
void logInfo(String message, [dynamic error, StackTrace? stackTrace]) {
  _talker.info(message);
}

/// Log debug message
void logDebug(String message, [dynamic error, StackTrace? stackTrace]) {
  _talker.debug(message);
}

/// Log warning message
void logWarning(String message, [dynamic error, StackTrace? stackTrace]) {
  _talker.warning(message);
}

/// Log error message
void logError(String message, [dynamic error, StackTrace? stackTrace]) {
  if (error != null) {
    _talker.error(message, error, stackTrace);
  } else {
    _talker.error(message);
  }
}

/// Log verbose message
void logVerbose(String message, [dynamic error, StackTrace? stackTrace]) {
  _talker.verbose(message);
}

/// Clear all logs
void clearLogs() {
  _talker.cleanHistory();
}

/// get talker instance
Talker getTalkerInstance() {
  return _talker;
}