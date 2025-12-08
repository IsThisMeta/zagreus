import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/router/router.dart';
import 'package:zagreus/router/routes/radarr.dart';

class RadarrAddMovieDetailsActionBar extends StatelessWidget {
  const RadarrAddMovieDetailsActionBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagBottomActionBar(
      actions: [
        ZagButton(
          type: ZagButtonType.TEXT,
          text: 'zagreus.Add'.tr(),
          icon: Icons.add_rounded,
          onTap: () async => _onTap(context),
          loadingState: context.watch<RadarrAddMovieDetailsState>().state,
        ),
      ],
    );
  }

  Future<void> _onTap(BuildContext context) async {
    if (context.read<RadarrAddMovieDetailsState>().canExecuteAction) {
      context.read<RadarrAddMovieDetailsState>().state =
          ZagLoadingState.ACTIVE;
      await RadarrAPIHelper()
          .addMovie(
        context: context,
        movie: context.read<RadarrAddMovieDetailsState>().movie,
        rootFolder: context.read<RadarrAddMovieDetailsState>().rootFolder,
        monitored: context.read<RadarrAddMovieDetailsState>().monitored,
        qualityProfile:
            context.read<RadarrAddMovieDetailsState>().qualityProfile,
        availability: context.read<RadarrAddMovieDetailsState>().availability,
        tags: context.read<RadarrAddMovieDetailsState>().tags,
        searchForMovie: RadarrDatabase.ADD_MOVIE_SEARCH_FOR_MISSING.read(),
      )
          .then((movie) async {
        context.read<RadarrState>().fetchMovies();
        context.read<RadarrAddMovieDetailsState>().movie.id = movie!.id;
        ZagRouter.router.pop();
        RadarrRoutes.MOVIE.go(params: {
          'movie': movie.id!.toString(),
        });
      }).catchError((error, stack) {
        context.read<RadarrAddMovieDetailsState>().state =
            ZagLoadingState.ERROR;
      });
      context.read<RadarrAddMovieDetailsState>().state =
          ZagLoadingState.INACTIVE;
    }
  }
}
