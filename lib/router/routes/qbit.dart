import 'package:flutter/material.dart';
import 'package:zagreus/modules.dart';
import 'package:zagreus/modules/qbit/routes/qbit.dart';
import 'package:zagreus/modules/qbit/routes/torrent_details.dart';
import 'package:zagreus/router/routes.dart';
import 'package:zagreus/vendor.dart';

enum QBitRoutes with ZagRoutesMixin {
  HOME('/qbit'),
  TORRENT_DETAILS('torrent/:hash');

  @override
  final String path;

  const QBitRoutes(this.path);

  @override
  ZagModule get module => ZagModule.QBIT;

  @override
  bool isModuleEnabled(BuildContext context) => true;

  @override
  GoRoute get routes {
    switch (this) {
      case QBitRoutes.HOME:
        return route(widget: const QBitRoute());
      case QBitRoutes.TORRENT_DETAILS:
        return route(builder: (_, state) {
          final hash = state.pathParameters['hash'] ?? '';
          return QBitTorrentDetailsRoute(hash: hash);
        });
    }
  }

  @override
  List<GoRoute> get subroutes {
    switch (this) {
      case QBitRoutes.HOME:
        return [
          QBitRoutes.TORRENT_DETAILS.routes,
        ];
      default:
        return const [];
    }
  }
}
