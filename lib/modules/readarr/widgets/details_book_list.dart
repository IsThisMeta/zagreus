import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/readarr.dart';

class ReadarrDetailsBookList extends StatefulWidget {
  final int authorId;

  const ReadarrDetailsBookList({
    Key? key,
    required this.authorId,
  }) : super(key: key);

  @override
  State<ReadarrDetailsBookList> createState() => _State();
}

class _State extends State<ReadarrDetailsBookList>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();
  Future<List<ReadarrBookData>>? _future;
  List<ReadarrBookData>? _results;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    _results = [];
    ReadarrAPI _api = ReadarrAPI.from(ZagProfile.forModule('readarr'));
    setState(() {
      _future = _api.getBooksForAuthor(widget.authorId);
    });
  }

  void _refreshState() => setState(() {});

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _body;
  }

  Widget get _body => ZagRefreshIndicator(
        context: context,
        key: _refreshKey,
        onRefresh: _refresh,
        child: FutureBuilder(
          future: _future,
          builder: (context, AsyncSnapshot<List<ReadarrBookData>> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                {
                  if (snapshot.hasError || snapshot.data == null) {
                    return ZagMessage.error(onTap: _refresh);
                  }
                  _results = snapshot.data;
                  return _list;
                }
              case ConnectionState.none:
              case ConnectionState.waiting:
              case ConnectionState.active:
              default:
                return const ZagLoader();
            }
          },
        ),
      );

  Widget get _list => Consumer<ReadarrState>(
        builder: (context, model, _) {
          return ZagListViewBuilder(
            controller: ReadarrAuthorNavigationBar.scrollControllers[1],
            itemCount: _results!.isEmpty ? 1 : _results!.length,
            itemBuilder: _results!.isEmpty
                ? (context, _) => const ZagMessage(text: 'No Books Found')
                : (context, index) => ReadarrDetailsBookTile(
                      data: _results![index],
                      authorId: widget.authorId,
                      refreshState: _refreshState,
                    ),
          );
        },
      );
}
