import 'package:zagreus/types/log_type.dart';

abstract class ZagException implements Exception {
  ZagLogType get type;
}

mixin WarningExceptionMixin implements ZagException {
  @override
  ZagLogType get type => ZagLogType.WARNING;
}

mixin ErrorExceptionMixin implements ZagException {
  @override
  ZagLogType get type => ZagLogType.ERROR;
}
