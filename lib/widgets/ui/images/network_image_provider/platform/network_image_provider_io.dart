import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:zagreus/system/cache/image/image_cache.dart';

// ignore: always_use_package_imports
import '../network_image_provider.dart';

ZagNetworkImageProvider getNetworkImageProvider({
  required String url,
  Map<String, String>? headers,
}) {
  return IO(
    url: url,
    headers: headers,
  );
}

class IO implements ZagNetworkImageProvider {
  String url;
  Map<String, String>? headers;

  IO({
    required this.url,
    this.headers,
  });

  @override
  ImageProvider<Object> get imageProvider {
    return ZagImageCache.isSupported ? _cache() : _default();
  }

  ImageProvider<Object> _cache() {
    return CachedNetworkImageProvider(
      url,
      headers: headers,
      cacheManager: ZagImageCache().instance,
      errorListener: (_) {},
    );
  }

  ImageProvider<Object> _default() {
    return NetworkImage(
      url,
      headers: headers,
    );
  }
}
