import 'package:flutter/material.dart';
import 'package:zagreus/modules.dart';
import 'package:zagreus/modules/search/routes/categories/route.dart';
import 'package:zagreus/modules/search/routes/indexers/route.dart';
import 'package:zagreus/modules/search/routes/results/route.dart';
import 'package:zagreus/modules/search/routes/search/route.dart';
import 'package:zagreus/modules/search/routes/subcategories/route.dart';
import 'package:zagreus/router/routes.dart';
import 'package:zagreus/utils/zagreus_pro.dart';
import 'package:zagreus/vendor.dart';

enum SearchRoutes with ZagRoutesMixin {
  HOME('/search'),
  CATEGORIES('categories'),
  RESULTS('results'),
  SEARCH('search'),
  SUBCATEGORIES('subcategories');

  @override
  final String path;

  const SearchRoutes(this.path);

  @override
  ZagModule get module => ZagModule.SEARCH;

  @override
  bool isModuleEnabled(BuildContext context) => ZagModule.SEARCH.isEnabled;

  @override
  GoRoute get routes {
    switch (this) {
      case SearchRoutes.HOME:
        return route(widget: const SearchRoute());
      case SearchRoutes.CATEGORIES:
        return route(widget: const CategoriesRoute());
      case SearchRoutes.RESULTS:
        return route(widget: const ResultsRoute());
      case SearchRoutes.SEARCH:
        return route(widget: const SearchIndexerRoute());
      case SearchRoutes.SUBCATEGORIES:
        return route(widget: const SubcategoriesRoute());
    }
  }

  @override
  List<GoRoute> get subroutes {
    switch (this) {
      case SearchRoutes.HOME:
        return [
          SearchRoutes.CATEGORIES.routes,
          SearchRoutes.RESULTS.routes,
          SearchRoutes.SEARCH.routes,
          SearchRoutes.SUBCATEGORIES.routes,
        ];
      default:
        return const [];
    }
  }
}
