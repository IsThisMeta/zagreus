import 'package:flutter/material.dart';
import 'package:zagreus/modules.dart';
import 'package:zagreus/modules/discover.dart';
import 'package:zagreus/router/routes.dart';
import 'package:zagreus/vendor.dart';
import 'package:zagreus/utils/zagreus_pro.dart';
import 'package:zagreus/database/tables/zagreus.dart';

enum DiscoverRoutes with ZagRoutesMixin {
  HOME('/discover'),
  RECENTLY_DOWNLOADED('recently_downloaded'),
  RECOMMENDED('recommended'),
  MISSING('missing'),
  DOWNLOADING_SOON('downloading_soon'),
  TMDB_POPULAR_MOVIES('tmdb_popular_movies');

  @override
  final String path;

  const DiscoverRoutes(this.path);

  @override
  ZagModule get module => ZagModule.DISCOVER;

  @override
  bool isModuleEnabled(BuildContext context) => ZagreusPro.isEnabled;

  @override
  GoRoute get routes {
    switch (this) {
      case DiscoverRoutes.HOME:
        return route(widget: const DiscoverHomeRoute());
      case DiscoverRoutes.RECENTLY_DOWNLOADED:
        return route(widget: const DiscoverRecentlyDownloadedRoute());
      case DiscoverRoutes.RECOMMENDED:
        return route(widget: const DiscoverRecommendedRoute());
      case DiscoverRoutes.MISSING:
        return route(widget: const DiscoverMissingRoute());
      case DiscoverRoutes.DOWNLOADING_SOON:
        return route(widget: DiscoverDownloadingSoonRoute());
      case DiscoverRoutes.TMDB_POPULAR_MOVIES:
        return route(widget: const TMDBPopularMoviesRoute());
    }
  }
  
  @override
  List<GoRoute> get subroutes {
    switch (this) {
      case DiscoverRoutes.HOME:
        return [
          DiscoverRoutes.RECENTLY_DOWNLOADED.routes,
          DiscoverRoutes.RECOMMENDED.routes,
          DiscoverRoutes.MISSING.routes,
          DiscoverRoutes.DOWNLOADING_SOON.routes,
          DiscoverRoutes.TMDB_POPULAR_MOVIES.routes,
        ];
      case DiscoverRoutes.RECENTLY_DOWNLOADED:
        return [];
      case DiscoverRoutes.RECOMMENDED:
        return [];
      case DiscoverRoutes.MISSING:
        return [];
      case DiscoverRoutes.DOWNLOADING_SOON:
        return [];
      case DiscoverRoutes.TMDB_POPULAR_MOVIES:
        return [];
    }
  }
}