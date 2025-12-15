import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/widgets/pages/invalid_route.dart';

class MovieEditRoute extends StatefulWidget {
  final int movieId;

  const MovieEditRoute({
    Key? key,
    required this.movieId,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<MovieEditRoute>
    with ZagLoadCallbackMixin, ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Future<void> loadCallback() async {
    context.read<RadarrState>().fetchTags();
    context.read<RadarrState>().fetchQualityProfiles();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.movieId <= 0) {
      return InvalidRoutePage(
        title: 'radarr.EditMovie'.tr(),
        message: 'radarr.MovieNotFound'.tr(),
      );
    }
    return ChangeNotifierProvider(
        create: (_) => RadarrMoviesEditState(),
        builder: (context, _) {
          ZagLoadingState state =
              context.select<RadarrMoviesEditState, ZagLoadingState>(
                  (state) => state.state);
          return ZagScaffold(
            scaffoldKey: _scaffoldKey,
            appBar: _appBar() as PreferredSizeWidget?,
            body:
                state == ZagLoadingState.ERROR ? _bodyError() : _body(context),
            bottomNavigationBar: state == ZagLoadingState.ERROR
                ? null
                : const RadarrEditMovieActionBar(),
          );
        });
  }

  Widget _appBar() {
    return ZagAppBar(
      scrollControllers: [scrollController],
      title: 'radarr.EditMovie'.tr(),
    );
  }

  Widget _bodyError() {
    return ZagMessage.goBack(
      context: context,
      text: 'zagreus.AnErrorHasOccurred'.tr(),
    );
  }

  Widget _body(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        context.select<RadarrState, Future<List<RadarrMovie>>>(
          (state) => state.movies!,
        ),
        context.select<RadarrState, Future<List<RadarrQualityProfile>>>(
          (state) => state.qualityProfiles!,
        ),
        context.select<RadarrState, Future<List<RadarrTag>>>(
          (state) => state.tags!,
        ),
      ]),
      builder: (context, AsyncSnapshot<List<Object>> snapshot) {
        if (snapshot.hasError) return ZagMessage.error(onTap: loadCallback);
        if (snapshot.hasData) {
          final movies = snapshot.data![0] as List<RadarrMovie>;
          final profiles = snapshot.data![1] as List<RadarrQualityProfile>;
          final tags = snapshot.data![2] as List<RadarrTag>;
          RadarrMovie movie = movies.firstWhere((m) => m.id == widget.movieId);

          return _list(
            context,
            movie: movie,
            profiles: profiles,
            tags: tags,
          );
        }
        return const ZagLoader();
      },
    );
  }

  Widget _list(
    BuildContext context, {
    required RadarrMovie movie,
    required List<RadarrQualityProfile> profiles,
    required List<RadarrTag> tags,
  }) {
    if (context.read<RadarrMoviesEditState>().movie == null) {
      context.read<RadarrMoviesEditState>().movie = movie;
      context.read<RadarrMoviesEditState>().initializeQualityProfile(profiles);
      context.read<RadarrMoviesEditState>().initializeTags(tags);
      context.read<RadarrMoviesEditState>().canExecuteAction = true;
    }
    return ZagListView(
      controller: scrollController,
      children: [
        const RadarrMoviesEditMonitoredTile(),
        const RadarrMoviesEditMinimumAvailabilityTile(),
        RadarrMoviesEditQualityProfileTile(profiles: profiles),
        const RadarrMoviesEditPathTile(),
        const RadarrMoviesEditTagsTile(),
      ],
    );
  }
}
