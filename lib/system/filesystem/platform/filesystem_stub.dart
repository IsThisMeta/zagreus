// ignore: always_use_package_imports
import '../filesystem.dart';

bool isPlatformSupported() => false;
ZagFileSystem getFileSystem() =>
    throw UnsupportedError('ZagFileSystem unsupported');
