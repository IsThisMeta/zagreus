
class DiscoverRouteState {
  final List<dynamic> items;
  final int currentPage;
  final double scrollOffset;
  final bool hasMorePages;
  final Map<String, dynamic>? extra;

  DiscoverRouteState({
    required this.items,
    required this.currentPage,
    required this.scrollOffset,
    required this.hasMorePages,
    this.extra,
  });
}

class DiscoverSessionCache {
  static final DiscoverSessionCache _instance = DiscoverSessionCache._internal();
  factory DiscoverSessionCache() => _instance;
  DiscoverSessionCache._internal();

  final Map<String, DiscoverRouteState> _cache = {};

  DiscoverRouteState? get(String key) => _cache[key];
  void set(String key, DiscoverRouteState state) => _cache[key] = state;
  bool has(String key) => _cache.containsKey(key);
  void clear() => _cache.clear();
}
