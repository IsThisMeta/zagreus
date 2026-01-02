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
              ? 'lidarr.NoSummaryAvailable'.tr()
              : widget.data.overview,
          uri: widget.data.posterURI(),
          squareImage: true,
          headers: ZagProfile.forModule('lidarr').lidarrHeaders,
        ),
        ZagTableCard(
          content: [
            ZagTableContent(
              title: 'lidarr.Path'.tr(),
              body: widget.data.path,
            ),
            ZagTableContent(
              title: 'lidarr.Quality'.tr(),
              body: widget.data.quality,
            ),
            ZagTableContent(
              title: 'lidarr.Metadata'.tr(),
              body: widget.data.metadata,
            ),
            ZagTableContent(
              title: 'lidarr.Albums'.tr(),
              body: widget.data.albums,
            ),
            ZagTableContent(
              title: 'lidarr.Tracks'.tr(),
              body: widget.data.tracks,
            ),
            ZagTableContent(
              title: 'lidarr.Genres'.tr(),
              body: widget.data.genre,
            ),
          ],
        ),
      ],
    );
  }
}
