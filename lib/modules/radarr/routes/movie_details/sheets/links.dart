import 'package:flutter/material.dart';
import 'package:zagreus/api/radarr/models.dart';
import 'package:zagreus/extensions/string/links.dart';
import 'package:zagreus/utils/links.dart';
import 'package:zagreus/widgets/ui.dart';

class LinksSheet extends ZagBottomModalSheet {
  RadarrMovie movie;

  LinksSheet({
    required this.movie,
  });

  @override
  Widget builder(BuildContext context) {
    final imdb = ZagLinkedContent.imdb(movie.imdbId);
    final tmdb =
        ZagLinkedContent.theMovieDB(movie.tmdbId, LinkedContentType.MOVIE);
    final letterboxd = ZagLinkedContent.letterboxd(movie.tmdbId);
    final trakt =
        ZagLinkedContent.trakt(movie.imdbId, LinkedContentType.MOVIE);
    final youtube = ZagLinkedContent.youtube(movie.youTubeTrailerId);

    return ZagListViewModal(
      children: [
        if (imdb != null)
          ZagBlock(
            title: 'IMDb',
            leading: const ZagIconButton(icon: ZagIcons.IMDB),
            onTap: imdb.openLink,
          ),
        if (letterboxd != null)
          ZagBlock(
            title: 'Letterboxd',
            leading: const ZagIconButton(icon: ZagIcons.LETTERBOXD),
            onTap: letterboxd.openLink,
          ),
        if (tmdb != null)
          ZagBlock(
            title: 'The Movie Database',
            leading: const ZagIconButton(icon: ZagIcons.THEMOVIEDATABASE),
            onTap: tmdb.openLink,
          ),
        if (trakt != null)
          ZagBlock(
            title: 'Trakt',
            leading: const ZagIconButton(icon: ZagIcons.TRAKT),
            onTap: trakt.openLink,
          ),
        if (youtube != null)
          ZagBlock(
            title: 'YouTube',
            leading: const ZagIconButton(icon: ZagIcons.YOUTUBE),
            onTap: youtube.openLink,
          ),
      ],
    );
  }
}
