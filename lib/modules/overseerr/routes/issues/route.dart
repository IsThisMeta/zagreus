import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/overseerr.dart';

class OverseerrIssuesRoute extends StatefulWidget {
  const OverseerrIssuesRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<OverseerrIssuesRoute>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  Future<void> _refresh() async {
    OverseerrState _state = context.read<OverseerrState>();
    await _state.fetchIssues();
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
      child: Selector<OverseerrState, Tuple3<List<OverseerrIssue>?, bool, bool>>(
          selector: (_, state) => Tuple3(
                state.issues,
                state.enabled,
                state.issuesLoading,
              ),
          builder: (context, tuple, _) {
            if (!tuple.item2) {
              return ZagMessage(
                text: 'overseerr.NotEnabled'.tr(),
                buttonText: 'overseerr.EnableInSettings'.tr(),
                onTap: () {
                  // TODO: Navigate to settings
                },
              );
            }

            final issues = tuple.item1;
            final isLoading = tuple.item3;

            if (issues == null || isLoading) {
              return const ZagLoader();
            }

            return _issueList(issues);
          }),
    );
  }

  Widget _issueList(List<OverseerrIssue> issues) {
    if (issues.isEmpty) {
      return ZagMessage(
        text: 'overseerr.NoIssuesFound'.tr(),
        buttonText: 'overseerr.Refresh'.tr(),
        onTap: _refreshKey.currentState!.show,
      );
    }

    // Sort by created date (newest first), with open issues first
    final sorted = List<OverseerrIssue>.from(issues)
      ..sort((a, b) {
        // First sort by status (open issues first)
        if (a.status != b.status) {
          return a.status == 1 ? -1 : 1; // 1 = open
        }
        // Then by created date
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
        return OverseerrIssueTile(
          issue: sorted[index],
        );
      },
      itemCount: sorted.length,
      itemExtent: OverseerrIssueTile.itemExtent,
    );
  }
}
