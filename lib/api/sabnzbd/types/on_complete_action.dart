import 'package:zagreus/types/enum/readable.dart';
import 'package:zagreus/types/enum/serializable.dart';
import 'package:zagreus/vendor.dart';

enum SABnzbdOnCompleteAction with EnumSerializable, EnumReadable {
  SHUTDOWN_PROGRAM('shutdown_program'),
  SHUTDOWN_PC('shutdown_pc'),
  HIBERNATE_PC('hibernate_pc'),
  STANDBY_PC('standby_pc'),
  NONE('none');

  @override
  final String value;

  const SABnzbdOnCompleteAction(this.value);

  @override
  String get readable {
    switch (this) {
      case SABnzbdOnCompleteAction.SHUTDOWN_PROGRAM:
        return 'sabnzbd.ShutdownSABnzbd'.tr();
      case SABnzbdOnCompleteAction.SHUTDOWN_PC:
        return 'sabnzbd.ShutdownPC'.tr();
      case SABnzbdOnCompleteAction.HIBERNATE_PC:
        return 'sabnzbd.HibernatePC'.tr();
      case SABnzbdOnCompleteAction.STANDBY_PC:
        return 'sabnzbd.StandbyPC'.tr();
      case SABnzbdOnCompleteAction.NONE:
        return 'sabnzbd.None'.tr();
    }
  }
}
