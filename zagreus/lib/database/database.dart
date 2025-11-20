import 'package:zagreus/database/box.dart';
import 'package:zagreus/database/models/profile.dart';
import 'package:zagreus/database/table.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/system/filesystem/filesystem.dart';
import 'package:zagreus/system/platform.dart';
import 'package:zagreus/vendor.dart';

class ZagDatabase {
  static const String _DATABASE_LEGACY_PATH = 'database';
  static const String _DATABASE_PATH = 'Zagreus/database';

  String get path {
    if (ZagPlatform.isWindows || ZagPlatform.isLinux) return _DATABASE_PATH;
    return _DATABASE_LEGACY_PATH;
  }

  Future<void> initialize() async {
    await Hive.initFlutter(path);
    ZagTable.register();
    await open();
  }

  Future<void> open() async {
    await ZagBox.open();
    if (ZagBox.profiles.isEmpty) await bootstrap();
    await _runMigrations();
  }

  /// Run database migrations for version updates
  Future<void> _runMigrations() async {
    await _migrateOpacityTo20();
  }

  /// Migration: Reset background image opacity from 25% to 20%
  /// This migration fixes users who were stuck at 25% opacity after
  /// toggling the "Use Original Colors" setting.
  Future<void> _migrateOpacityTo20() async {
    const opacityKey = ZagreusDatabase.THEME_IMAGE_BACKGROUND_OPACITY;
    final currentOpacity = opacityKey.read();

    // If user has 25% opacity, reset to 20%
    if (currentOpacity == 25) {
      opacityKey.update(20);
    }
  }

  Future<void> nuke() async {
    await Hive.close();

    for (final box in ZagBox.values) {
      await Hive.deleteBoxFromDisk(box.key, path: path);
    }

    if (ZagFileSystem.isSupported) {
      await ZagFileSystem().nuke();
    }
  }

  Future<void> bootstrap() async {
    const defaultProfile = ZagProfile.DEFAULT_PROFILE;
    await clear();

    ZagBox.profiles.update(defaultProfile, ZagProfile());
    ZagreusDatabase.ENABLED_PROFILE.update(defaultProfile);
  }

  Future<void> clear() async {
    for (final box in ZagBox.values) await box.clear();
  }

  Future<void> deinitialize() async {
    await Hive.close();
  }
}
