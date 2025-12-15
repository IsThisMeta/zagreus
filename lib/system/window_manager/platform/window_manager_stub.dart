// ignore: always_use_package_imports
import '../window_manager.dart';

bool isPlatformSupported() => false;
ZagWindowManager getWindowManager() =>
    throw UnsupportedError('ZagWindowManager unsupported');
