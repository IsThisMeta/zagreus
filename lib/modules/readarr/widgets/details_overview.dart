import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/readarr.dart';
import 'package:zagreus/extensions/int/bytes.dart';

class ReadarrDetailsOverview extends StatefulWidget {
  final ReadarrCatalogueData data;

  const ReadarrDetailsOverview({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  State<ReadarrDetailsOverview> createState() => _State();
}

class _State extends State<ReadarrDetailsOverview>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ZagListView(
      controller: ReadarrAuthorNavigationBar.scrollControllers[0],
      children: <Widget>[
        ReadarrDescriptionBlock(
          title: widget.data.title,
          description: widget.data.overview == ''
              ? 'No Summary Available'
              : widget.data.overview,
          uri: widget.data.posterURI(),
          squareImage: true,
          headers: ZagProfile.current.readarrHeaders,
        ),
        ZagTableCard(
          content: [
            ZagTableContent(
              title: 'Path',
              body: widget.data.path,
            ),
            ZagTableContent(
              title: 'Quality',
              body: widget.data.quality,
            ),
            ZagTableContent(
              title: 'Metadata',
              body: widget.data.metadata,
            ),
            ZagTableContent(
              title: 'Books',
              body: widget.data.books,
            ),
            ZagTableContent(
              title: 'Size',
              body: widget.data.sizeOnDisk.asBytes(),
            ),
            ZagTableContent(
              title: 'Genres',
              body: widget.data.genre,
            ),
            ZagTableContent(
              title: 'Type',
              body: widget.data.authorType,
            ),
          ],
        ),
      ],
    );
  }
}
