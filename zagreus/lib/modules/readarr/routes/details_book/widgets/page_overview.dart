import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/readarr.dart';
import 'package:zagreus/modules/readarr/routes/details_book/widgets/navigation_bar.dart';
import 'package:zagreus/modules/readarr/routes/details_book/widgets/overview_book_description_tile.dart';
import 'package:zagreus/modules/readarr/routes/details_book/widgets/overview_book_information_block.dart';

class ReadarrBookDetailsOverviewPage extends StatefulWidget {
  final ReadarrBookData book;
  final int authorId;
  final Future<void> Function() onRefresh;

  const ReadarrBookDetailsOverviewPage({
    Key? key,
    required this.book,
    required this.authorId,
    required this.onRefresh,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<ReadarrBookDetailsOverviewPage>
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
        controller: ReadarrBookDetailsNavigationBar.scrollControllers[0],
        children: [
          ReadarrBookDetailsOverviewDescriptionTile(
            book: widget.book,
            authorId: widget.authorId,
          ),
          ReadarrBookDetailsOverviewInformationBlock(
            book: widget.book,
            onRefresh: widget.onRefresh,
          ),
        ],
      ),
    );
  }
}
