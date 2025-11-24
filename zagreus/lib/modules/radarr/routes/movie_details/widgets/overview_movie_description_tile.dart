import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/string/links.dart';
import 'package:zagreus/modules/radarr.dart';

class RadarrMovieDetailsOverviewDescriptionTile extends StatelessWidget {
  final RadarrMovie? movie;

  const RadarrMovieDetailsOverviewDescriptionTile({
    Key? key,
    required this.movie,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagBlock(
      posterPlaceholderIcon: ZagIcons.VIDEO_CAM,
      backgroundUrl: context.read<RadarrState>().getFanartURL(movie!.id),
      posterUrl: context.read<RadarrState>().getPosterURL(movie!.id),
      posterHeaders: context.read<RadarrState>().headers,
      title: movie!.title,
      body: [
        ZagTextSpan.extended(
          text: movie!.overview == null || movie!.overview!.isEmpty
              ? 'sonarr.NoSummaryAvailable'.tr()
              : movie!.overview,
        ),
      ],
      customBodyMaxLines: 3,
      onTap: () async =>
          ZagDialogs().textPreview(context, movie!.title, movie!.overview!),
      onLongPress: () async => movie!.youTubeTrailerId?.openYouTube(),
    );
  }
}
