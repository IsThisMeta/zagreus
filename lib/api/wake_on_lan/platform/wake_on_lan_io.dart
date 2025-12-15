import 'package:wake_on_lan/wake_on_lan.dart';
import 'package:zagreus/api/wake_on_lan/wake_on_lan.dart';
import 'package:zagreus/database/models/profile.dart';
import 'package:zagreus/system/logger.dart';
import 'package:zagreus/vendor.dart';
import 'package:zagreus/widgets/ui.dart';

bool isPlatformSupported() => true;
ZagWakeOnLAN getWakeOnLAN() => IO();

class IO implements ZagWakeOnLAN {
  @override
  Future<void> wake() async {
    ZagProfile profile = ZagProfile.current;
    try {
      final ip = IPAddress(profile.wakeOnLANBroadcastAddress);
      final mac = MACAddress(profile.wakeOnLANMACAddress);
      return WakeOnLAN(ip, mac).wake().then((_) {
        showZagSuccessSnackBar(
          title: 'wake_on_lan.MagicPacketSent'.tr(),
          message: 'wake_on_lan.MagicPacketSentMessage'.tr(),
        );
      });
    } catch (error, stack) {
      ZagLogger().error(
        'Failed to send wake on LAN magic packet',
        error,
        stack,
      );
      showZagErrorSnackBar(
        title: 'wake_on_lan.MagicPacketFailedToSend'.tr(),
        error: error,
      );
    }
  }
}
