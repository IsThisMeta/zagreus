import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:zagreus/system/platform.dart';

// ignore: always_use_package_imports
import '../image_cache.dart';

bool isPlatformSupported() {
  return ZagPlatform.isMobile || ZagPlatform.isMacOS;
}

ZagImageCache getImageCache() {
  if (isPlatformSupported()) return IO();
  throw UnsupportedError('ZagImageCache unsupported');
}

class IO implements ZagImageCache {
  static final CacheManager _cache = CacheManager(
    Config(
      ZagImageCache.key,
      stalePeriod: const Duration(days: 30),
      maxNrOfCacheObjects: 5000,
    ),
  );

  @override
  CacheManager get instance => _cache;

  @override
  Future<bool> clear() async {
    await _cache.emptyCache();
    PaintingBinding.instance.imageCache.clear();
    return true;
  }

  @override
  void initialize() {
    PaintingBinding.instance.imageCache.maximumSize = 1000;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 128 << 20;
  }
}
