import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/lidarr.dart';

class LidarrDetailsOverview extends StatefulWidget {
  final LidarrCatalogueData data;

  const LidarrDetailsOverview({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  State<LidarrDetailsOverview> createState() => _State();
}

class _State extends State<LidarrDetailsOverview>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ZagListView(
      controller: LidarrArtistNavigationBar.scrollControllers[0],
      children: <Widget>[
        LidarrDescriptionBlock(
          title: widget.data.title,
          description: widget.data.overview == ''
              ? 'No Summary Available'
              : widget.data.overview,
          uri: widget.data.posterURI(),
          squareImage: true,
          headers: ZagProfile.current.lidarrHeaders,
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
              title: 'Albums',
              body: widget.data.albums,
            ),
            ZagTableContent(
              title: 'Tracks',
              body: widget.data.tracks,
            ),
            ZagTableContent(
              title: 'Genres',
              body: widget.data.genre,
            ),
          ],
        ),
      ],
    );
  }
}
