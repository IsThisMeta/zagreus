import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/readarr.dart';
import 'package:zagreus/modules/readarr/routes/details_book/widgets/navigation_bar.dart';

class ReadarrBookDetailsHistoryPage extends StatefulWidget {
  final ReadarrBookData book;

  const ReadarrBookDetailsHistoryPage({
    Key? key,
    required this.book,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<ReadarrBookDetailsHistoryPage>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      body: ZagListView(
        controller: ReadarrBookDetailsNavigationBar.scrollControllers[2],
        children: [
          ZagBlock(
            title: 'History',
            body: const [
              ZagTextSpan.extended(
                text: 'History tracking for books is not yet implemented.',
              ),
            ],
            posterPlaceholderIcon: Icons.history_rounded,
          ),
        ],
      ),
    );
  }
}
