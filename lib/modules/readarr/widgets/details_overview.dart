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
              ? 'readarr.NoSummaryAvailable'.tr()
              : widget.data.overview,
          uri: widget.data.posterURI(),
          squareImage: true,
          headers: ZagProfile.forModule('readarr').readarrHeaders,
        ),
        ZagTableCard(
          content: [
            ZagTableContent(
              title: 'readarr.Path'.tr(),
              body: widget.data.path,
            ),
            ZagTableContent(
              title: 'readarr.Quality'.tr(),
              body: widget.data.quality,
            ),
            ZagTableContent(
              title: 'readarr.Metadata'.tr(),
              body: widget.data.metadata,
            ),
            ZagTableContent(
              title: 'readarr.Books'.tr(),
              body: widget.data.books,
            ),
            ZagTableContent(
              title: 'readarr.Size'.tr(),
              body: widget.data.sizeOnDisk.asBytes(),
            ),
            ZagTableContent(
              title: 'readarr.Genres'.tr(),
              body: widget.data.genre,
            ),
            ZagTableContent(
              title: 'readarr.Type'.tr(),
              body: widget.data.authorType,
            ),
          ],
        ),
      ],
    );
  }
}
