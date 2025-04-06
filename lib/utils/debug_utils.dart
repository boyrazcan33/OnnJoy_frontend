import 'package:flutter/foundation.dart';

class DebugLogger {
  static void log(String message, {String? tag, bool important = false}) {
    final prefix = important ? "🔴 IMPORTANT - " : "🔹 ";
    final tagStr = tag != null ? "[$tag] " : "";
    debugPrint("$prefix$tagStr$message");
  }

  static void logObject(String label, dynamic object, {String? tag, bool important = false}) {
    final objString = object != null
        ? object.toString()
        : "NULL";
    log("$label: $objString", tag: tag, important: important);
  }

  static void logMap(String label, Map<String, dynamic>? map, {String? tag, bool important = false}) {
    if (map == null) {
      log("$label: NULL MAP", tag: tag, important: important);
      return;
    }

    log("$label:", tag: tag, important: important);
    map.forEach((key, value) {
      log("  $key: $value", tag: tag);
    });
  }

  static void logError(String message, dynamic error, StackTrace? stackTrace, {String? tag}) {
    log("ERROR: $message", tag: tag, important: true);
    log("Error details: $error", tag: tag, important: true);
    if (stackTrace != null) {
      log("Stack trace: $stackTrace", tag: tag);
    }
  }
}