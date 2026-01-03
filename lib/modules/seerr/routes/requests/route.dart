import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/tables/ui_preferences.dart';
import 'package:zagreus/modules/seerr.dart';

class SeerrRequestsRoute extends StatefulWidget {
  const SeerrRequestsRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<SeerrRequestsRoute>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();
  final ScrollController _scrollController = ScrollController();

  String _requestFilter = 'pending';
  String _requestSort = 'added';

  @override
  bool get wantKeepAlive => true;

  Future<void> _refresh() async {
    SeerrState _state = context.read<SeerrState>();
    await _state.fetchRequests();
    await _state.fetchUsers();
  }

  void _loadFilterAndSort() {
    _requestFilter = UIPreferencesDatabase.SEERR_REQUEST_FILTER.read() as String;
    _requestSort = UIPreferencesDatabase.SEERR_REQUEST_SORT.read() as String;
    SeerrState _state = context.read<SeerrState>();
    _state.requestsFilter = _requestFilter;
    _state.requestsSort = _requestSort;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFilterAndSort();
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
      child: Selector<SeerrState, Tuple3<List<SeerrRequest>?, bool, bool>>(
          selector: (_, state) => Tuple3(
                state.requests,
                state.enabled,
                state.requestsLoading,
              ),
          builder: (context, tuple, _) {
            if (!tuple.item2) {
              return ZagMessage(
                text: 'seerr.NotEnabled'.tr(),
                buttonText: 'seerr.EnableInSettings'.tr(),
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

  Widget _requestList(List<SeerrRequest> requests) {
    if (requests.isEmpty) {
      return ZagMessage(
        text: 'seerr.NoRequestsFound'.tr(),
        buttonText: 'seerr.Refresh'.tr(),
        onTap: _refreshKey.currentState!.show,
      );
    }

    // Sort by created date (newest first)
    final sorted = List<SeerrRequest>.from(requests)
      ..sort((a, b) {
        try {
          final aDate = DateTime.parse(a.createdAt);
          final bDate = DateTime.parse(b.createdAt);
          return bDate.compareTo(aDate);
        } catch (e) {
          return 0;
        }
      });

    return Column(
      children: [
        _buildFilterHeader(),
        Expanded(
          child: ZagListViewBuilder(
            controller: _scrollController,
            itemBuilder: (context, index) {
              return SeerrRequestTile(
                request: sorted[index],
              );
            },
            itemCount: sorted.length,
            itemExtent: SeerrRequestTile.itemExtent,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildFilterSelector(),
          _buildSortSelector(),
        ],
      ),
    );
  }

  Widget _buildFilterSelector() {
    final filterOptions = {
      'pending': 'seerr.Pending'.tr(),
      'approved': 'seerr.Approved'.tr(),
      'declined': 'seerr.Declined'.tr(),
      'available': 'seerr.Available'.tr(),
      'processing': 'seerr.Processing'.tr(),
      'unavailable': 'seerr.Unavailable'.tr(),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? ZagColours.secondary
            : ZagColours.secondaryLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white10
              : Colors.black12,
          width: 1,
        ),
      ),
      child: DropdownButton<String>(
        value: _requestFilter,
        underline: const SizedBox(),
        isDense: true,
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
        dropdownColor: Theme.of(context).brightness == Brightness.dark
            ? ZagColours.secondary
            : ZagColours.secondaryLight,
        icon: Icon(
          Icons.arrow_drop_down_rounded,
          color: ZagColours.accentColor(context),
        ),
        items: filterOptions.entries.map((entry) {
          return DropdownMenuItem<String>(
            value: entry.key,
            child: Text(entry.value),
          );
        }).toList(),
        onChanged: (newFilter) {
          if (newFilter == null) return;
          setState(() {
            _requestFilter = newFilter;
          });
          UIPreferencesDatabase.SEERR_REQUEST_FILTER.update(newFilter);
          SeerrState _state = context.read<SeerrState>();
          _state.requestsFilter = newFilter;
        },
      ),
    );
  }

  Widget _buildSortSelector() {
    final sortOptions = {
      'added': 'seerr.MostRecent'.tr(),
      'modified': 'seerr.LastModified'.tr(),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? ZagColours.secondary
            : ZagColours.secondaryLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white10
              : Colors.black12,
          width: 1,
        ),
      ),
      child: DropdownButton<String>(
        value: _requestSort,
        underline: const SizedBox(),
        isDense: true,
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
        dropdownColor: Theme.of(context).brightness == Brightness.dark
            ? ZagColours.secondary
            : ZagColours.secondaryLight,
        icon: Icon(
          Icons.arrow_drop_down_rounded,
          color: ZagColours.accentColor(context),
        ),
        items: sortOptions.entries.map((entry) {
          return DropdownMenuItem<String>(
            value: entry.key,
            child: Text(entry.value),
          );
        }).toList(),
        onChanged: (newSort) {
          if (newSort == null) return;
          setState(() {
            _requestSort = newSort;
          });
          UIPreferencesDatabase.SEERR_REQUEST_SORT.update(newSort);
          SeerrState _state = context.read<SeerrState>();
          _state.requestsSort = newSort;
        },
      ),
    );
  }
}
