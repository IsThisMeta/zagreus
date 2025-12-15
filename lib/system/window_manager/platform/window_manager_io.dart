import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:zagreus/system/platform.dart';
import 'package:window_manager/window_manager.dart';

// ignore: always_use_package_imports
import '../window_manager.dart';

bool isPlatformSupported() => ZagPlatform.isDesktop;
ZagWindowManager getWindowManager() {
  switch (ZagPlatform.current) {
    case ZagPlatform.LINUX:
    case ZagPlatform.MACOS:
    case ZagPlatform.WINDOWS:
      return IO();
    default:
      throw UnsupportedError('ZagWindowManager unsupported');
  }
}

class IO implements ZagWindowManager {
  @override
  Future<void> initialize() async {
    if (kDebugMode) return;

    await windowManager.ensureInitialized();
    windowManager.waitUntilReadyToShow().then((_) async {
      await setWindowSize();
      await setWindowTitle('Zagreus');
      windowManager.show();
    });
  }

  @override
  Future<void> setWindowTitle(String title) async {
    return windowManager
        .waitUntilReadyToShow()
        .then((_) async => await windowManager.setTitle(title));
  }

  Future<void> setWindowSize() async {
    const min = ZagWindowManager.MINIMUM_WINDOW_SIZE;
    const init = ZagWindowManager.INITIAL_WINDOW_SIZE;
    const minSize = Size(min, min);
    const initSize = Size(init, init);

    await windowManager.setSize(initSize);
    // Currently broken on Linux
    if (!ZagPlatform.isLinux) {
      await windowManager.setMinimumSize(minSize);
    }
  }
}
