import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/router/routes/tautulli.dart';

class LogsRoute extends StatefulWidget {
  const LogsRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<LogsRoute> with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar() as PreferredSizeWidget?,
      body: _body(),
    );
  }

  Widget _appBar() {
    return ZagAppBar(
      title: 'Logs',
      scrollControllers: [scrollController],
    );
  }

  Widget _body() {
    return ZagListView(
      controller: scrollController,
      children: [
        ZagBlock(
          title: 'Logins',
          body: const [TextSpan(text: 'Tautulli Login Logs')],
          trailing: ZagIconButton(
            icon: Icons.vpn_key_rounded,
            color: ZagColours().byListIndex(0),
          ),
          onTap: TautulliRoutes.LOGS_LOGINS.go,
        ),
        ZagBlock(
          title: 'Newsletters',
          body: const [TextSpan(text: 'Tautulli Newsletter Logs')],
          trailing: ZagIconButton(
            icon: Icons.email_rounded,
            color: ZagColours().byListIndex(1),
          ),
          onTap: TautulliRoutes.LOGS_NEWSLETTERS.go,
        ),
        ZagBlock(
          title: 'Notifications',
          body: const [TextSpan(text: 'Tautulli Notification Logs')],
          trailing: ZagIconButton(
            icon: Icons.notifications_rounded,
            color: ZagColours().byListIndex(2),
          ),
          onTap: TautulliRoutes.LOGS_NOTIFICATIONS.go,
        ),
        ZagBlock(
          title: 'Plex Media Scanner',
          body: const [TextSpan(text: 'Plex Media Scanner Logs')],
          trailing: ZagIconButton(
            icon: Icons.scanner_rounded,
            color: ZagColours().byListIndex(3),
          ),
          onTap: TautulliRoutes.LOGS_PLEX_MEDIA_SCANNER.go,
        ),
        ZagBlock(
          title: 'Plex Media Server',
          body: const [TextSpan(text: 'Plex Media Server Logs')],
          trailing: ZagIconButton(
            icon: ZagIcons.PLEX,
            iconSize: ZagUI.ICON_SIZE - 2.0,
            color: ZagColours().byListIndex(4),
          ),
          onTap: TautulliRoutes.LOGS_PLEX_MEDIA_SERVER.go,
        ),
        ZagBlock(
          title: 'Tautulli',
          body: const [TextSpan(text: 'Tautulli Logs')],
          trailing: ZagIconButton(
            icon: ZagIcons.TAUTULLI,
            color: ZagColours().byListIndex(5),
          ),
          onTap: TautulliRoutes.LOGS_TAUTULLI.go,
        ),
      ],
    );
  }
}
