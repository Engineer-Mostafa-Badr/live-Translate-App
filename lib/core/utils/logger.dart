import 'package:flutter/foundation.dart';

/// Simple logger utility
class Logger {
  static void log(String message, {String tag = 'APP'}) {
    if (kDebugMode) {
      print('[$tag] $message');
    }
  }
  
  static void error(String message, {String tag = 'ERROR'}) {
    if (kDebugMode) {
      print('[$tag] ❌ $message');
    }
  }
  
  static void success(String message, {String tag = 'SUCCESS'}) {
    if (kDebugMode) {
      print('[$tag] ✅ $message');
    }
  }
  
  static void warning(String message, {String tag = 'WARNING'}) {
    if (kDebugMode) {
      print('[$tag] ⚠️ $message');
    }
  }
}
