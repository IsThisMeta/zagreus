import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/string/string.dart';
import 'package:zagreus/extensions/string/links.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/router/routes/radarr.dart';

class RadarrAddMovieSearchResultTile extends StatefulWidget {
  final RadarrMovie movie;
  final bool onTapShowOverview;
  final bool exists;
  final bool isExcluded;

  const RadarrAddMovieSearchResultTile({
    Key? key,
    required this.movie,
    required this.exists,
    required this.isExcluded,
    this.onTapShowOverview = false,
  }) : super(key: key);

  @override
  State<RadarrAddMovieSearchResultTile> createState() => _State();
}

class _State extends State<RadarrAddMovieSearchResultTile> {
  @override
  Widget build(BuildContext context) {
    return ZagBlock(
      backgroundUrl: widget.movie.remotePoster,
      posterUrl: widget.movie.remotePoster,
      posterHeaders: context.watch<RadarrState>().headers,
      posterPlaceholderIcon: ZagIcons.VIDEO_CAM,
      title: widget.movie.title,
      titleColor: widget.isExcluded 
          ? ZagColours.red 
          : (Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black87),
      disabled: widget.exists,
      body: [_subtitle1()],
      bottom: _subtitle2(),
      bottomHeight: ZagBlock.SUBTITLE_HEIGHT * 2,
      onTap: _onTap,
      onLongPress: _onLongPress,
    );
  }

  TextSpan _subtitle1() {
    return TextSpan(
      children: [
        TextSpan(text: widget.movie.zagYear),
        TextSpan(text: ZagUI.TEXT_BULLET.pad()),
        TextSpan(text: widget.movie.zagRuntime),
        TextSpan(text: ZagUI.TEXT_BULLET.pad()),
        TextSpan(text: widget.movie.zagStudio),
      ],
    );
  }

  Widget _subtitle2() {
    String? summary;
    if (widget.movie.overview == null || widget.movie.overview!.isEmpty) {
      summary = 'radarr.NoSummaryIsAvailable'.tr();
    } else {
      summary = widget.movie.overview;
    }
    return SizedBox(
      height: ZagBlock.SUBTITLE_HEIGHT * 2,
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontSize: ZagUI.FONT_SIZE_H3,
            color: Theme.of(context).brightness == Brightness.dark
                ? ZagColours.grey
                : Colors.grey.shade600,
          ),
          children: [
            ZagTextSpan.extended(text: summary),
          ],
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
    );
  }

  Future<void> _onTap() async {
    if (widget.onTapShowOverview) {
      ZagDialogs().textPreview(context, widget.movie.title,
          widget.movie.overview ?? 'radarr.NoSummaryIsAvailable'.tr());
    } else if (widget.exists) {
      RadarrRoutes.MOVIE.go(params: {
        'movie': widget.movie.id!.toString(),
      });
    } else {
      RadarrRoutes.ADD_MOVIE_DETAILS.go(extra: widget.movie, queryParams: {
        'isDiscovery': 'false',
      });
    }
  }

  Future<void>? _onLongPress() async =>
      widget.movie.youTubeTrailerId?.openYouTube();
}
