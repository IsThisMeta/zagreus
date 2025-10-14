import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/tautulli.dart';
import 'package:zagreus/router/routes/tautulli.dart';

class TautulliSearchResultTile extends StatefulWidget {
  final TautulliSearchResult result;
  final TautulliMediaType mediaType;

  const TautulliSearchResultTile({
    Key? key,
    required this.result,
    required this.mediaType,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<TautulliSearchResultTile> {
  @override
  Widget build(BuildContext context) {
    return ZagBlock(
      title: widget.result.title,
      body: [
        TextSpan(text: _body1),
        TextSpan(text: widget.result.grandparentTitle),
        _library(),
      ],
      posterUrl: context
          .watch<TautulliState>()
          .getImageURLFromPath(widget.result.thumb),
      posterHeaders: context.watch<TautulliState>().headers,
      backgroundHeaders: context.watch<TautulliState>().headers,
      backgroundUrl:
          context.watch<TautulliState>().getImageURLFromPath(widget.result.art),
      posterPlaceholderIcon: ZagIcons.VIDEO_CAM,
      onTap: _onTap,
    );
  }

  String get _body1 {
    String _text = '';
    switch (widget.result.mediaType) {
      case TautulliMediaType.MOVIE:
      case TautulliMediaType.SHOW:
        _text = widget.result.year?.toString() ?? 'Unknown';
        break;
      case TautulliMediaType.ARTIST:
        break;
      case TautulliMediaType.SEASON:
      case TautulliMediaType.EPISODE:
      case TautulliMediaType.ALBUM:
      case TautulliMediaType.TRACK:
        _text = widget.result.parentTitle ?? '';
        break;
      case TautulliMediaType.COLLECTION:
        _text =
            '${widget.result.minYear ?? 0} ${ZagUI.TEXT_EMDASH} ${widget.result.maxYear ?? 0}';
        break;
      default:
        break;
    }
    return _text;
  }

  TextSpan _library() {
    return TextSpan(
      text: widget.result.libraryName,
      style: TextStyle(
        color: ZagColours.currentAccent,
        fontWeight: ZagUI.FONT_WEIGHT_BOLD,
      ),
    );
  }

  void _onTap() {
    TautulliRoutes.MEDIA_DETAILS.go(params: {
      'rating_key': widget.result.ratingKey.toString(),
      'media_type': widget.mediaType.value,
    });
  }
}
