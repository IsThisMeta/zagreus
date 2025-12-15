// ignore: always_use_package_imports
import 'platform/network_stub.dart'
    if (dart.library.io) 'platform/network_io.dart'
    if (dart.library.html) 'platform/network_html.dart';

abstract class ZagNetwork {
  static bool get isSupported => isPlatformSupported();
  factory ZagNetwork() => getNetwork();

  void initialize();
}
