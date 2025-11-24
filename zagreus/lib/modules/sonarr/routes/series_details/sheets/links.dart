import 'package:flutter/material.dart';
import 'package:zagreus/extensions/string/links.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/utils/links.dart';
import 'package:zagreus/widgets/ui.dart';

class LinksSheet extends ZagBottomModalSheet {
  SonarrSeries series;

  LinksSheet({
    required this.series,
  });

  @override
  Widget builder(BuildContext context) {
    final imdb = ZagLinkedContent.imdb(series.imdbId);
    final rottenTomatoes =
        ZagLinkedContent.rottenTomatoes(series.title, LinkedContentType.SERIES);
    final tvdb =
        ZagLinkedContent.theTVDB(series.tvdbId, LinkedContentType.SERIES);
    final trakt =
        ZagLinkedContent.trakt(series.imdbId, LinkedContentType.SERIES);
    final tvMaze = ZagLinkedContent.tvMaze(series.tvMazeId);

    return ZagListViewModal(
      children: [
        if (imdb != null)
          ZagBlock(
            title: 'IMDb',
            leading: const ZagIconButton(icon: ZagIcons.IMDB),
            onTap: imdb.openLink,
          ),
        if (rottenTomatoes != null)
          ZagBlock(
            title: 'Rotten Tomatoes',
            leading: const ZagIconButton(icon: ZagIcons.LINK),
            onTap: rottenTomatoes.openLink,
          ),
        if (tvdb != null)
          ZagBlock(
            title: 'TheTVDB',
            leading: const ZagIconButton(icon: ZagIcons.THETVDB),
            onTap: tvdb.openLink,
          ),
        if (trakt != null)
          ZagBlock(
            title: 'Trakt',
            leading: const ZagIconButton(icon: ZagIcons.TRAKT),
            onTap: trakt.openLink,
          ),
        if (tvMaze != null)
          ZagBlock(
            title: 'TVmaze',
            leading: const ZagIconButton(icon: ZagIcons.TVMAZE),
            onTap: tvMaze.openLink,
          ),
      ],
    );
  }
}
