// ignore: always_use_package_imports
import '../image_cache.dart';

bool isPlatformSupported() => false;
ZagImageCache getImageCache() =>
    throw UnsupportedError('ZagImageCache unsupported');
