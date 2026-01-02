import 'package:flutter/material.dart';
import 'package:zagreus/modules.dart';
import 'package:zagreus/modules/readarr/core/api.dart';
import 'package:zagreus/modules/readarr/routes/add_details.dart';
import 'package:zagreus/modules/readarr/routes/add_book_details.dart';
import 'package:zagreus/modules/readarr/routes/add_search.dart';
import 'package:zagreus/modules/readarr/routes/details_book.dart';
import 'package:zagreus/modules/readarr/routes/details_author.dart';
import 'package:zagreus/modules/readarr/routes/edit_author.dart';
import 'package:zagreus/modules/readarr/routes/readarr.dart';
import 'package:zagreus/modules/readarr/routes/search_results.dart';
import 'package:zagreus/router/routes.dart';
import 'package:zagreus/vendor.dart';

enum ReadarrRoutes with ZagRoutesMixin {
  HOME('/readarr'),
  ADD_AUTHOR('add_author'),
  ADD_AUTHOR_DETAILS('details'),
  ADD_BOOK_DETAILS('book_details'),
  AUTHOR('author/:author'),
  AUTHOR_BOOK('book/:book'),
  AUTHOR_BOOK_RELEASES('releases'),
  AUTHOR_EDIT('edit');

  @override
  final String path;

  const ReadarrRoutes(this.path);

  @override
  ZagModule get module => ZagModule.READARR;

  @override
  bool isModuleEnabled(BuildContext context) => true;

  @override
  GoRoute get routes {
    switch (this) {
      case ReadarrRoutes.HOME:
        return route(widget: const ReadarrRoute());
      case ReadarrRoutes.ADD_AUTHOR:
        return route(widget: const AddAuthorRoute());
      case ReadarrRoutes.ADD_AUTHOR_DETAILS:
        return route(builder: (_, state) {
          return AddAuthorDetailsRoute(
            data: state.extra as ReadarrSearchData?,
          );
        });
      case ReadarrRoutes.ADD_BOOK_DETAILS:
        return route(builder: (_, state) {
          return AddBookDetailsRoute(
            data: state.extra as ReadarrUnifiedSearchResult?,
          );
        });
      case ReadarrRoutes.AUTHOR:
        return route(builder: (_, state) {
          return AuthorDetailsRoute(
            data: state.extra as ReadarrCatalogueData?,
            authorId: int.tryParse(state.pathParameters['author'] ?? '') ?? -1,
          );
        });
      case ReadarrRoutes.AUTHOR_BOOK:
        return route(builder: (_, state) {
          return AuthorBookDetailsRoute(
            authorId: int.tryParse(state.pathParameters['author'] ?? '') ?? -1,
            bookId: int.tryParse(state.pathParameters['book'] ?? '') ?? -1,
            monitored:
                state.uri.queryParameters['monitored']?.toLowerCase() == 'true',
          );
        });
      case ReadarrRoutes.AUTHOR_BOOK_RELEASES:
        return route(builder: (_, state) {
          return AuthorBookReleasesRoute(
            bookId: int.tryParse(state.pathParameters['book'] ?? '') ?? -1,
          );
        });
      case ReadarrRoutes.AUTHOR_EDIT:
        return route(builder: (_, state) {
          return AuthorEditRoute(
            data: state.extra as ReadarrCatalogueData?,
            authorId: int.tryParse(state.pathParameters['author'] ?? '') ?? -1,
          );
        });
    }
  }

  @override
  List<GoRoute> get subroutes {
    switch (this) {
      case ReadarrRoutes.HOME:
        return [
          ReadarrRoutes.ADD_AUTHOR.routes,
          ReadarrRoutes.AUTHOR.routes,
        ];
      case ReadarrRoutes.ADD_AUTHOR:
        return [
          ReadarrRoutes.ADD_AUTHOR_DETAILS.routes,
          ReadarrRoutes.ADD_BOOK_DETAILS.routes,
        ];
      case ReadarrRoutes.AUTHOR:
        return [
          ReadarrRoutes.AUTHOR_BOOK.routes,
          ReadarrRoutes.AUTHOR_EDIT.routes,
        ];
      case ReadarrRoutes.AUTHOR_BOOK:
        return [
          ReadarrRoutes.AUTHOR_BOOK_RELEASES.routes,
        ];
      default:
        return const [];
    }
  }
}
