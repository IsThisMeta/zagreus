import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/radarr.dart';

class RadarrSystemStatusAboutPage extends StatefulWidget {
  final ScrollController scrollController;

  const RadarrSystemStatusAboutPage({
    Key? key,
    required this.scrollController,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<RadarrSystemStatusAboutPage>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      body: _body(),
    );
  }

  Widget _body() {
    return ZagRefreshIndicator(
      context: context,
      key: _refreshKey,
      onRefresh: () async =>
          context.read<RadarrSystemStatusState>().fetchStatus(context),
      child: FutureBuilder(
        future: context.watch<RadarrSystemStatusState>().status,
        builder: (context, AsyncSnapshot<RadarrSystemStatus> snapshot) {
          if (snapshot.hasError) {
            ZagLogger().error('Unable to fetch Radarr system status',
                snapshot.error, snapshot.stackTrace);
            return ZagMessage.error(onTap: _refreshKey.currentState!.show);
          }
          if (snapshot.hasData) return _list(snapshot.data!);
          return const ZagLoader();
        },
      ),
    );
  }

  Widget _list(RadarrSystemStatus status) {
    return ZagListView(
      controller: RadarrSystemStatusNavigationBar.scrollControllers[0],
      children: [
        ZagTableCard(
          content: [
            ZagTableContent(title: 'Version', body: status.zagVersion),
            if (status.zagIsDocker)
              ZagTableContent(
                title: 'Package',
                body: status.zagPackageVersion,
              ),
            ZagTableContent(title: '.NET Core', body: status.zagNetCore),
            ZagTableContent(title: 'Migration', body: status.zagDBMigration),
            ZagTableContent(
                title: 'AppData', body: status.zagAppDataDirectory),
            ZagTableContent(
                title: 'Startup', body: status.zagStartupDirectory),
            ZagTableContent(title: 'mode', body: status.zagMode),
            ZagTableContent(title: 'uptime', body: status.zagUptime),
          ],
        ),
      ],
    );
  }
}
