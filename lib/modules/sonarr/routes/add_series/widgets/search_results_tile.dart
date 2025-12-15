import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/string/string.dart';
import 'package:zagreus/extensions/string/links.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/router/routes/sonarr.dart';

class SonarrSeriesAddSearchResultTile extends StatefulWidget {
  static final double extent = ZagBlock.calculateItemExtent(
    1,
    hasBottom: true,
    bottomHeight: ZagBlock.SUBTITLE_HEIGHT * 2,
  );

  final SonarrSeries series;
  final bool onTapShowOverview;
  final bool exists;
  final bool isExcluded;

  const SonarrSeriesAddSearchResultTile({
    Key? key,
    required this.series,
    required this.exists,
    required this.isExcluded,
    this.onTapShowOverview = false,
  }) : super(key: key);

  @override
  State<SonarrSeriesAddSearchResultTile> createState() => _State();
}

class _State extends State<SonarrSeriesAddSearchResultTile> {
  @override
  Widget build(BuildContext context) {
    return ZagBlock(
      backgroundUrl: widget.series.remotePoster,
      posterUrl: widget.series.remotePoster,
      posterHeaders: context.watch<SonarrState>().headers,
      posterPlaceholderIcon: ZagIcons.VIDEO_CAM,
      title: widget.series.title,
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
    return TextSpan(children: [
      TextSpan(text: widget.series.zagSeasonCount),
      TextSpan(text: ZagUI.TEXT_BULLET.pad()),
      TextSpan(text: widget.series.zagYear),
      TextSpan(text: ZagUI.TEXT_BULLET.pad()),
      TextSpan(text: widget.series.zagNetwork),
    ]);
  }

  Widget _subtitle2() {
    return SizedBox(
      height: ZagBlock.SUBTITLE_HEIGHT * 2,
      child: Builder(
        builder: (context) => RichText(
          text: TextSpan(
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontSize: ZagUI.FONT_SIZE_H3,
              color: Theme.of(context).brightness == Brightness.dark
                  ? ZagColours.grey
                  : Colors.grey.shade700,
            ),
            children: [
              ZagTextSpan.extended(text: widget.series.zagOverview),
            ],
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ),
    );
  }

  Future<void> _onTap() async {
    if (widget.onTapShowOverview) {
      ZagDialogs().textPreview(
        context,
        widget.series.title,
        widget.series.overview ?? 'sonarr.NoSummaryAvailable'.tr(),
      );
    } else if (widget.exists) {
      SonarrRoutes.SERIES.go(params: {'series': widget.series.id!.toString()});
    } else {
      SonarrRoutes.ADD_SERIES_DETAILS.go(extra: widget.series);
    }
  }

  Future<void>? _onLongPress() async =>
      widget.series.tvdbId?.toString().openTvdbSeries();
}
