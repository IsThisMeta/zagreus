import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/string/string.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/router/routes/radarr.dart';

enum _RadarrCatalogueTileType {
  TILE,
  GRID,
}

class RadarrCatalogueTile extends StatefulWidget {
  static final itemExtent = ZagBlock.calculateItemExtent(2, hasBottom: true);

  final RadarrMovie movie;
  final RadarrQualityProfile? profile;
  final _RadarrCatalogueTileType type;

  const RadarrCatalogueTile({
    Key? key,
    required this.movie,
    required this.profile,
    this.type = _RadarrCatalogueTileType.TILE,
  }) : super(key: key);

  const RadarrCatalogueTile.grid({
    Key? key,
    required this.movie,
    required this.profile,
    this.type = _RadarrCatalogueTileType.GRID,
  }) : super(key: key);

  @override
  State<RadarrCatalogueTile> createState() => _State();
}

class _State extends State<RadarrCatalogueTile> {
  @override
  Widget build(BuildContext context) {
    return Selector<RadarrState, Future<List<RadarrMovie>>?>(
      selector: (_, state) => state.movies,
      builder: (context, movies, _) {
        switch (widget.type) {
          case _RadarrCatalogueTileType.TILE:
            return _buildBlockTile();
          case _RadarrCatalogueTileType.GRID:
            return _buildGridTile();
          default:
            throw Exception('Invalid _RadarrCatalogueTileType');
        }
      },
    );
  }

  Widget _buildBlockTile() {
    return ZagBlock(
      key: ObjectKey(widget.movie),
      backgroundUrl: context.read<RadarrState>().getFanartURL(widget.movie.id),
      posterUrl: context.read<RadarrState>().getPosterURL(widget.movie.id),
      posterHeaders: context.read<RadarrState>().headers,
      backgroundHeaders: context.read<RadarrState>().headers,
      posterPlaceholderIcon: ZagIcons.VIDEO_CAM,
      disabled: !widget.movie.monitored!,
      title: widget.movie.title,
      body: [
        _subtitle1(),
        _subtitle2(),
      ],
      posterIsSquare: false,
      bottom: _subtitle3(),
      onTap: _onTap,
      onLongPress: _onLongPress,
    );
  }

  Widget _buildGridTile() {
    RadarrMoviesSorting _sorting = context.read<RadarrState>().moviesSortType;
    return ZagGridBlock(
      key: ObjectKey(widget.movie),
      backgroundUrl: context.read<RadarrState>().getFanartURL(widget.movie.id),
      posterUrl: context.read<RadarrState>().getPosterURL(widget.movie.id),
      posterHeaders: context.read<RadarrState>().headers,
      backgroundHeaders: context.read<RadarrState>().headers,
      posterPlaceholderIcon: ZagIcons.VIDEO_CAM,
      title: widget.movie.title,
      subtitle: TextSpan(text: _sorting.value(widget.movie, widget.profile)),
      disabled: !widget.movie.monitored!,
      onTap: _onTap,
      onLongPress: _onLongPress,
    );
  }

  TextSpan _buildChildTextSpan(String? text, RadarrMoviesSorting sorting) {
    TextStyle? style;
    if (context.read<RadarrState>().moviesSortType == sorting)
      style = TextStyle(
        color: ZagColours.currentAccent,
        fontWeight: ZagUI.FONT_WEIGHT_BOLD,
      );
    return TextSpan(
      text: text,
      style: style,
    );
  }

  TextSpan _subtitle1() {
    return TextSpan(
      children: [
        _buildChildTextSpan(widget.movie.zagYear, RadarrMoviesSorting.YEAR),
        TextSpan(text: ZagUI.TEXT_BULLET.pad()),
        _buildChildTextSpan(
            widget.movie.zagRuntime, RadarrMoviesSorting.RUNTIME),
        TextSpan(text: ZagUI.TEXT_BULLET.pad()),
        _buildChildTextSpan(
            widget.movie.zagStudio, RadarrMoviesSorting.STUDIO),
      ],
    );
  }

  TextSpan _subtitle2() {
    return TextSpan(
      children: [
        _buildChildTextSpan(widget.profile?.name ?? ZagUI.TEXT_EMDASH,
            RadarrMoviesSorting.QUALITY_PROFILE),
        TextSpan(text: ZagUI.TEXT_BULLET.pad()),
        _buildChildTextSpan(widget.movie.zagMinimumAvailability,
            RadarrMoviesSorting.MIN_AVAILABILITY),
        TextSpan(text: ZagUI.TEXT_BULLET.pad()),
        if (context.read<RadarrState>().moviesSortType !=
                RadarrMoviesSorting.IN_CINEMAS &&
            context.read<RadarrState>().moviesSortType !=
                RadarrMoviesSorting.DIGITAL_RELEASE &&
            context.read<RadarrState>().moviesSortType !=
                RadarrMoviesSorting.PHYSICAL_RELEASE)
          _buildChildTextSpan(
            widget.movie.zagDateAdded(),
            RadarrMoviesSorting.DATE_ADDED,
          ),
        if (context.read<RadarrState>().moviesSortType ==
            RadarrMoviesSorting.PHYSICAL_RELEASE)
          _buildChildTextSpan(widget.movie.zagPhysicalReleaseDate(),
              RadarrMoviesSorting.PHYSICAL_RELEASE),
        if (context.read<RadarrState>().moviesSortType ==
            RadarrMoviesSorting.DIGITAL_RELEASE)
          _buildChildTextSpan(widget.movie.zagDigitalReleaseDate(),
              RadarrMoviesSorting.DIGITAL_RELEASE),
        if (context.read<RadarrState>().moviesSortType ==
            RadarrMoviesSorting.IN_CINEMAS)
          _buildChildTextSpan(
            widget.movie.zagInCinemasOn(),
            RadarrMoviesSorting.IN_CINEMAS,
          ),
      ],
    );
  }

  Widget _buildReleaseIcon(IconData icon, Color color, bool highlight) {
    return Padding(
      child: Container(
        child: Icon(
          icon,
          size: ZagUI.FONT_SIZE_H2,
          color: highlight ? color : ZagColours.grey.disabled(),
        ),
        width: ZagBlock.SUBTITLE_HEIGHT,
        height: ZagBlock.SUBTITLE_HEIGHT,
        alignment: Alignment.centerLeft,
      ),
      padding: const EdgeInsets.only(right: ZagUI.DEFAULT_MARGIN_SIZE / 4),
    );
  }

  Widget _subtitle3() {
    return SizedBox(
      height: ZagBlock.SUBTITLE_HEIGHT,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildReleaseIcon(
            Icons.videocam_rounded,
            ZagColours.orange,
            widget.movie.zagIsInCinemas,
          ),
          _buildReleaseIcon(
            Icons.album_rounded,
            ZagColours.blue,
            widget.movie.zagIsReleased,
          ),
          _buildReleaseIcon(
            Icons.check_circle_rounded,
            ZagColours.currentAccent,
            widget.movie.hasFile!,
          ),
          Container(
            height: ZagBlock.SUBTITLE_HEIGHT,
            child: widget.movie.hasFile!
                ? widget.movie.zagHasFileTextObject()
                : widget.movie.zagNextReleaseTextObject(),
            alignment: Alignment.center,
          ),
        ],
      ),
    );
  }

  Future<void> _onTap() async {
    RadarrRoutes.MOVIE.go(params: {
      'movie': widget.movie.id!.toString(),
    });
  }

  Future<void> _onLongPress() async {
    Tuple2<bool, RadarrMovieSettingsType?> values =
        await RadarrDialogs().movieSettings(context, widget.movie);
    if (values.item1) values.item2!.execute(context, widget.movie);
  }
}
