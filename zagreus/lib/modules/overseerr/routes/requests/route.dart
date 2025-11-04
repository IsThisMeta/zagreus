import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/overseerr.dart';

class OverseerrRequestsRoute extends StatefulWidget {
  const OverseerrRequestsRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<OverseerrRequestsRoute>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  Future<void> _refresh() async {
    OverseerrState _state = context.read<OverseerrState>();
    await _state.fetchRequests();
    await _state.fetchUsers();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
  }

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
      onRefresh: _refresh,
      child: Selector<OverseerrState, Tuple3<List<OverseerrRequest>?, bool, bool>>(
          selector: (_, state) => Tuple3(
                state.requests,
                state.enabled,
                state.requestsLoading,
              ),
          builder: (context, tuple, _) {
            if (!tuple.item2) {
              return ZagMessage(
                text: 'Overseerr is not enabled',
                buttonText: 'Enable in Settings',
                onTap: () {
                  // TODO: Navigate to settings
                },
              );
            }

            final requests = tuple.item1;
            final isLoading = tuple.item3;

            if (requests == null || isLoading) {
              return const ZagLoader();
            }

            return _requestList(requests);
          }),
    );
  }

  Widget _requestList(List<OverseerrRequest> requests) {
    if (requests.isEmpty) {
      return ZagMessage(
        text: 'No requests found',
        buttonText: 'Refresh',
        onTap: _refreshKey.currentState!.show,
      );
    }

    // Sort by created date (newest first)
    final sorted = List<OverseerrRequest>.from(requests)
      ..sort((a, b) {
        try {
          final aDate = DateTime.parse(a.createdAt);
          final bDate = DateTime.parse(b.createdAt);
          return bDate.compareTo(aDate);
        } catch (e) {
          return 0;
        }
      });

    return ZagListViewBuilder(
      controller: _scrollController,
      itemBuilder: (context, index) {
        return OverseerrRequestTile(
          request: sorted[index],
        );
      },
      itemCount: sorted.length,
      itemExtent: OverseerrRequestTile.itemExtent,
    );
  }
}
