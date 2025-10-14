import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/system/flavor.dart';

part 'log_type.g.dart';

const TYPE_DEBUG = 'debug';
const TYPE_WARNING = 'warning';
const TYPE_ERROR = 'error';
const TYPE_CRITICAL = 'critical';

@HiveType(typeId: 24, adapterName: 'ZagLogTypeAdapter')
enum ZagLogType {
  @HiveField(0)
  WARNING(TYPE_WARNING),
  @HiveField(1)
  ERROR(TYPE_ERROR),
  @HiveField(2)
  CRITICAL(TYPE_CRITICAL),
  @HiveField(3)
  DEBUG(TYPE_DEBUG);

  final String key;
  const ZagLogType(this.key);

  String get description => 'settings.ViewTypeLogs'.tr(args: [title]);

  bool get enabled {
    switch (this) {
      case ZagLogType.DEBUG:
        return ZagFlavor.BETA.isRunningFlavor();
      default:
        return true;
    }
  }

  String get title {
    switch (this) {
      case ZagLogType.WARNING:
        return 'zagreus.Warning'.tr();
      case ZagLogType.ERROR:
        return 'zagreus.Error'.tr();
      case ZagLogType.CRITICAL:
        return 'zagreus.Critical'.tr();
      case ZagLogType.DEBUG:
        return 'zagreus.Debug'.tr();
    }
  }

  IconData get icon {
    switch (this) {
      case ZagLogType.WARNING:
        return ZagIcons.WARNING;
      case ZagLogType.ERROR:
        return ZagIcons.ERROR;
      case ZagLogType.CRITICAL:
        return ZagIcons.CRITICAL;
      case ZagLogType.DEBUG:
        return ZagIcons.DEBUG;
    }
  }

  Color get color {
    switch (this) {
      case ZagLogType.WARNING:
        return ZagColours.orange;
      case ZagLogType.ERROR:
        return ZagColours.red;
      case ZagLogType.CRITICAL:
        return ZagColours.currentAccent;
      case ZagLogType.DEBUG:
        return ZagColours.blueGrey;
    }
  }

  static ZagLogType? fromKey(String key) {
    switch (key) {
      case TYPE_WARNING:
        return ZagLogType.WARNING;
      case TYPE_ERROR:
        return ZagLogType.ERROR;
      case TYPE_CRITICAL:
        return ZagLogType.CRITICAL;
      case TYPE_DEBUG:
        return ZagLogType.DEBUG;
    }
    return null;
  }
}
