import 'package:zagreus/api/wake_on_lan/wake_on_lan.dart';

bool isPlatformSupported() => false;
ZagWakeOnLAN getWakeOnLAN() =>
    throw UnsupportedError('ZagWakeOnLAN unsupported');
