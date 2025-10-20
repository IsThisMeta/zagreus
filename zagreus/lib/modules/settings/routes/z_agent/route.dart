import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';

class ZAgentSettingsRoute extends StatefulWidget {
  const ZAgentSettingsRoute({Key? key}) : super(key: key);

  @override
  State<ZAgentSettingsRoute> createState() => _State();
}

class _State extends State<ZAgentSettingsRoute> with ZagScrollControllerMixin {
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
      title: 'Z Agent',
      scrollControllers: [scrollController],
    );
  }

  Widget _body() {
    return ZagListView(
      controller: scrollController,
      children: [
        ZagreusDatabase.Z_ASSISTANT_LIBRARY_CACHE_ENABLED.listenableBuilder(
          builder: (context, _) {
            final enabled = ZagreusDatabase.Z_ASSISTANT_LIBRARY_CACHE_ENABLED.read();
            return ZagBlock(
              title: 'Library Cache',
              body: [
                TextSpan(
                  text: enabled
                      ? 'Your library is anonymously synced to Z'
                      : 'Enable library cache to allow Z Agent to analyze your library',
                ),
              ],
              trailing: ZagSwitch(
                value: enabled,
                onChanged: (value) {
                  ZagreusDatabase.Z_ASSISTANT_LIBRARY_CACHE_ENABLED.update(value);
                  if (value) {
                    showZagInfoSnackBar(
                      title: 'Library Cache Enabled',
                      message: 'Z Agent will now sync your library periodically',
                    );
                  } else {
                    showZagInfoSnackBar(
                      title: 'Library Cache Disabled',
                      message: 'Z Agent will no longer sync your library',
                    );
                  }
                },
              ),
            );
          },
        ),
        ZagreusDatabase.Z_ASSISTANT_WATCH_HISTORY_CACHE_ENABLED.listenableBuilder(
          builder: (context, _) {
            final enabled = ZagreusDatabase.Z_ASSISTANT_WATCH_HISTORY_CACHE_ENABLED.read();
            return ZagBlock(
              title: 'Watch History Cache',
              body: [
                TextSpan(
                  text: enabled
                      ? 'Tautulli watch history synced to Z'
                      : 'Enable to sync your Tautulli watch history',
                ),
              ],
              trailing: ZagSwitch(
                value: enabled,
                onChanged: (value) {
                  ZagreusDatabase.Z_ASSISTANT_WATCH_HISTORY_CACHE_ENABLED.update(value);
                  if (value) {
                    showZagInfoSnackBar(
                      title: 'Watch History Cache Enabled',
                      message: 'Z Agent will now sync your Tautulli watch history',
                    );
                  } else {
                    showZagInfoSnackBar(
                      title: 'Watch History Cache Disabled',
                      message: 'Z Agent will no longer sync watch history',
                    );
                  }
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
