import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:zagreus/core.dart';
import 'package:zagreus/database/models/log.dart';
import 'package:zagreus/types/exception.dart';
import 'package:zagreus/types/log_type.dart';

class ZagLogger {
  static String get checkLogsMessage => 'zagreus.CheckLogsMessage'.tr();

  void initialize() {
    FlutterError.onError = (details) async {
      if (kDebugMode) FlutterError.dumpErrorToConsole(details);
      Zone.current.handleUncaughtError(
        details.exception,
        details.stack ?? StackTrace.current,
      );
    };
    _compact();
  }

  Future<void> _compact([int count = 50]) async {
    if (ZagBox.logs.data.length <= count) return;
    List<ZagLog> logs = ZagBox.logs.data.toList();
    logs.sort((a, b) => (b.timestamp).compareTo(a.timestamp));
    logs.skip(count).forEach((log) => log.delete());
  }

  Future<String> export() async {
    final logs = ZagBox.logs.data.map((log) => log.toJson()).toList();
    final encoder = JsonEncoder.withIndent(' '.repeat(4));
    return encoder.convert(logs);
  }

  Future<void> clear() async => ZagBox.logs.clear();

  void debug(String message) {
    ZagLog log = ZagLog.withMessage(
      type: ZagLogType.DEBUG,
      message: message,
    );
    ZagBox.logs.create(log);
  }

  void warning(String message, [String? className, String? methodName]) {
    ZagLog log = ZagLog.withMessage(
      type: ZagLogType.WARNING,
      message: message,
      className: className,
      methodName: methodName,
    );
    ZagBox.logs.create(log);
  }

  void error(String message, dynamic error, StackTrace? stackTrace) {
    if (kDebugMode) {
      print(message);
      print(error);
      print(stackTrace);
    }

    if (error is! NetworkImageLoadException) {
      ZagLog log = ZagLog.withError(
        type: ZagLogType.ERROR,
        message: message,
        error: error,
        stackTrace: stackTrace,
      );
      ZagBox.logs.create(log);
    }
  }

  void critical(dynamic error, StackTrace stackTrace) {
    if (kDebugMode) {
      print(error);
      print(stackTrace);
    }

    if (error is! NetworkImageLoadException) {
      ZagLog log = ZagLog.withError(
        type: ZagLogType.CRITICAL,
        message: error?.toString() ?? ZagUI.TEXT_EMDASH,
        error: error,
        stackTrace: stackTrace,
      );
      ZagBox.logs.create(log);
    }
  }

  void exception(ZagException exception, [StackTrace? trace]) {
    switch (exception.type) {
      case ZagLogType.WARNING:
        warning(exception.toString(), exception.runtimeType.toString());
        break;
      case ZagLogType.ERROR:
        error(exception.toString(), exception, trace);
        break;
      default:
        break;
    }
  }
}
