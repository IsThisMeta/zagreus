import 'package:zagreus/core.dart';

abstract class ZagWebhooks {
  Future<void> handle(Map<dynamic, dynamic> data);

  static String buildUserTokenURL(String token, ZagModule module) {
    return 'https://zagreus-notifications.fly.dev/v1/${module.key}/user/$token';
  }

  static String buildDeviceTokenURL(String token, ZagModule module) {
    return 'https://zagreus-notifications.fly.dev/v1/${module.key}/device/$token';
  }
}
