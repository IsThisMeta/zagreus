import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/sabnzbd.dart';

class SABnzbdQueue extends StatefulWidget {
  static const ROUTE_NAME = '/sabnzbd/queue';
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey;

  const SABnzbdQueue({
    Key? key,
    required this.refreshIndicatorKey,
  }) : super(key: key);

  @override
  State<SABnzbdQueue> createState() => _State();
}

class _State extends State<SABnzbdQueue>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Timer? _timer;
  Future? _future;
  List<SABnzbdQueueData>? _queue = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ZagreusDatabase.SPEED_CUBE_ENABLED.listenableBuilder(
      builder: (context, _) {
        final cubeEnabled =
            ZagreusDatabase.SPEED_CUBE_ENABLED.read();
        return ZagScaffold(
          scaffoldKey: _scaffoldKey,
          body: _body,
          floatingActionButton: context.watch<SABnzbdState>().error
              ? null
              : SABnzbdQueueFAB(
                  scrollController: SABnzbdNavigationBar.scrollControllers[0]),
          floatingActionButtonLocation: cubeEnabled
              ? FloatingActionButtonLocation.startFloat
              : FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _createTimer() =>
      _timer = Timer(const Duration(seconds: 2), _fetchWithoutMessage);

  Future<void> _refresh() async => setState(() {
        _future = _fetch();
      });

  Future<void> _fetchWithoutMessage() async {
    _fetch().then((_) => {if (mounted) setState(() {})});
  }

  Future _fetch() async {
    SABnzbdAPI _api = SABnzbdAPI.from(ZagProfile.forModule('sabnzbd'));
    return _api.getStatusAndQueue().then((data) {
      try {
        _processStatus(data[0]);
        _queue = data[1];
        _setError(false);
        if (_timer == null || !_timer!.isActive) _createTimer();
        return true;
      } catch (error) {
        return Future.error(error);
      }
    }).catchError((error) {
      _queue = null;
      _setError(true);
      return Future.error(error);
    });
  }

  Future<void> _processStatus(SABnzbdStatusData data) async {
    if (mounted) {
      final _model = Provider.of<SABnzbdState>(context, listen: false);
      _model.paused = data.paused;
      _model.currentSpeed = data.currentSpeed;
      _model.queueSizeLeft = data.remainingSize;
      _model.queueTimeLeft = data.timeLeft;
      _model.speedLimit = data.speedlimit;
    }
  }

  void _setError(bool error) {
    final _model = Provider.of<SABnzbdState>(context, listen: false);
    _model.error = error;
  }

  Widget get _body => ZagRefreshIndicator(
        context: context,
        key: widget.refreshIndicatorKey,
        onRefresh: _fetchWithoutMessage,
        child: FutureBuilder(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                context.read<SABnzbdState>().error)
              return ZagMessage.error(onTap: _refresh);
            if (snapshot.hasData) return _list;
            return const ZagLoader();
          },
        ),
      );

  Widget get _list {
    if (_queue == null) return ZagMessage.error(onTap: _refresh);
    if (_queue!.isEmpty) {
      return ZagMessage(
        text: 'Empty Queue',
        buttonText: 'Refresh',
        onTap: _fetchWithoutMessage,
      );
    }
    return _reorderableList();
  }

  Widget _reorderableList() {
    return ZagReorderableListViewBuilder(
      controller: SABnzbdNavigationBar.scrollControllers[0],
      onReorder: (oIndex, nIndex) async {
        if (oIndex > _queue!.length) oIndex = _queue!.length;
        if (oIndex < nIndex) nIndex--;
        SABnzbdQueueData data = _queue![oIndex];
        if (mounted)
          setState(() {
            _queue!.remove(data);
            _queue!.insert(nIndex, data);
          });
        await SABnzbdAPI.from(ZagProfile.forModule('sabnzbd'))
            .moveQueue(data.nzoId, nIndex)
            .then(
              (_) => showZagSuccessSnackBar(
                title: 'Moved Job in Queue',
                message: data.name,
              ),
            )
            .catchError(
              (error) => showZagErrorSnackBar(
                title: 'Failed to Move Job',
                error: error,
              ),
            );
      },
      itemCount: _queue!.length,
      itemBuilder: (context, index) => SABnzbdQueueTile(
        key: Key(_queue![index].nzoId),
        data: _queue![index],
        index: index,
        queueContext: context,
        refresh: _fetchWithoutMessage,
      ),
    );
  }
}
