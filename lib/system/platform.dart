import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

enum ZagPlatform {
  ANDROID,
  IOS,
  LINUX,
  MACOS,
  WEB,
  WINDOWS;

  static bool get isAndroid {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  }

  static bool get isIOS {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
  }

  static bool get isLinux {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.linux;
  }

  static bool get isMacOS {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;
  }

  static bool get isWeb {
    return kIsWeb;
  }

  static bool get isWindows {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;
  }

  static bool get isMobile => isAndroid || isIOS;
  static bool get isDesktop => isLinux || isMacOS || isWindows;

  /// Detects if the current device is a tablet/iPad based on screen size.
  /// Uses the shortest side of the screen; if > 600px, it's considered a tablet.
  /// This is the standard Material Design breakpoint for tablets.
  static bool isTablet(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return size.shortestSide > 600;
  }

  static ZagPlatform get current {
    if (isWeb) return ZagPlatform.WEB;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return ZagPlatform.ANDROID;
      case TargetPlatform.iOS:
        return ZagPlatform.IOS;
      case TargetPlatform.linux:
        return ZagPlatform.LINUX;
      case TargetPlatform.macOS:
        return ZagPlatform.MACOS;
      case TargetPlatform.windows:
        return ZagPlatform.WINDOWS;
      default:
        throw UnsupportedError('Platform is not supported');
    }
  }

  String get name {
    switch (this) {
      case ZagPlatform.ANDROID:
        return 'Android';
      case ZagPlatform.IOS:
        return 'iOS';
      case ZagPlatform.LINUX:
        return 'Linux';
      case ZagPlatform.MACOS:
        return 'macOS';
      case ZagPlatform.WEB:
        return 'Web';
      case ZagPlatform.WINDOWS:
        return 'Windows';
    }
  }
}
