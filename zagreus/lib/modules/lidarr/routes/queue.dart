import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zagreus/api/lidarr/models/queue/queue.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/lidarr/widgets/navigation_bar.dart';
import 'package:zagreus/modules/lidarr/routes/queue/state.dart';
import 'package:zagreus/modules/lidarr/routes/queue/widgets/queue_tile.dart';

class LidarrQueueRoute extends StatefulWidget {
  final bool embedInNavigation;
  final ScrollController? scrollController;
  final VoidCallback? openDownloadsDrawer;

  const LidarrQueueRoute({
    Key? key,
    this.embedInNavigation = false,
    this.scrollController,
    this.openDownloadsDrawer,
  }) : super(key: key);

  @override
  State<LidarrQueueRoute> createState() => _State();
}

class _State extends State<LidarrQueueRoute> with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController? _localScrollController;
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  ScrollController get _controller =>
      widget.scrollController ?? _localScrollController ?? scrollController;

  @override
  void initState() {
    super.initState();
    _localScrollController =
        widget.scrollController == null ? ScrollController() : null;
  }

  @override
  void dispose() {
    _localScrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LidarrQueueState(context),
      builder: (context, _) => ZagScaffold(
        scaffoldKey: _scaffoldKey,
        appBar:
            widget.embedInNavigation ? null : _appBar() as PreferredSizeWidget?,
        body: _body(context),
      ),
    );
  }

  PreferredSizeWidget _appBar() {
    return ZagAppBar(
      title: 'Queue',
      scrollControllers: [_controller],
    );
  }

  Widget _body(BuildContext context) {
    return ZagRefreshIndicator(
      key: _refreshKey,
      context: context,
      onRefresh: () async {
        await context.read<LidarrQueueState>().fetchQueue(context);
        _refreshKey.currentState?.show();
      },
      child: FutureBuilder(
        future: context.watch<LidarrQueueState>().queue,
        builder: (context, AsyncSnapshot<LidarrQueuePage> snapshot) {
          if (snapshot.hasError) {
            if (snapshot.connectionState != ConnectionState.waiting) {
              ZagLogger().error(
                'Unable to fetch Lidarr queue',
                snapshot.error,
                snapshot.stackTrace,
              );
            }
            return ZagMessage.error(
              onTap: () => _refreshKey.currentState?.show(),
            );
          }

          if (snapshot.hasData) {
            final records = snapshot.data!.records ?? [];
            if (records.isEmpty) {
              return ZagMessage(
                text: 'Empty Queue',
                buttonText: 'zagreus.Refresh'.tr(),
                onTap: _refreshKey.currentState?.show,
              );
            }
            return ZagListViewBuilder(
              controller: _controller,
              itemCount: records.length,
              itemBuilder: (context, index) => LidarrQueueTile(
                record: records[index],
              ),
            );
          }

          return const ZagLoader();
        },
      ),
    );
  }
}
