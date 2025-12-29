import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/modules/radarr/routes/movie_details/widgets/rotten_tomatoes_tile.dart';
import 'package:zagreus/modules/radarr/routes/movie_details/widgets/bazarr/subtitle_tile.dart';

class RadarrMovieDetailsOverviewPage extends StatefulWidget {
  final RadarrMovie? movie;
  final RadarrQualityProfile? qualityProfile;
  final List<RadarrTag> tags;

  const RadarrMovieDetailsOverviewPage({
    Key? key,
    required this.movie,
    required this.qualityProfile,
    required this.tags,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<RadarrMovieDetailsOverviewPage>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ZagScaffold(
      module: ZagModule.RADARR,
      scaffoldKey: _scaffoldKey,
      body: Selector<RadarrState, Future<List<RadarrMovie>>?>(
        selector: (_, state) => state.movies,
        builder: (context, movies, _) => ZagListView(
          controller: RadarrMovieDetailsNavigationBar.scrollControllers[0],
          children: [
            RadarrMovieDetailsOverviewDescriptionTile(movie: widget.movie),
            RadarrRottenTomatoesTile(movie: widget.movie),
            RadarrMovieDetailsOverviewInformationBlock(
              movie: widget.movie,
              qualityProfile: widget.qualityProfile,
              tags: widget.tags,
            ),
            if (widget.movie?.id != null)
              RadarrBazarrSubtitleTile(radarrId: widget.movie!.id!),
          ],
        ),
      ),
    );
  }
}
