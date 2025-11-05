import 'package:flutter/material.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/datetime.dart';
import 'package:zagreus/extensions/int/bytes.dart';
import 'package:zagreus/extensions/string/string.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/router/routes/sonarr.dart';

class SonarrSeriesDetailsSeasonTile extends StatefulWidget {
  final SonarrSeriesSeason season;
  final int? seriesId;

  const SonarrSeriesDetailsSeasonTile({
    Key? key,
    required this.season,
    required this.seriesId,
  }) : super(key: key);

  @override
  State<SonarrSeriesDetailsSeasonTile> createState() => _State();
}

class _State extends State<SonarrSeriesDetailsSeasonTile> {
  ZagLoadingState _loadingState = ZagLoadingState.INACTIVE;

  @override
  Widget build(BuildContext context) {
    return ZagBlock(
      posterPlaceholderIcon: ZagIcons.VIDEO_CAM,
      posterUrl: _posterUrl(),
      posterHeaders: context.read<SonarrState>().headers,
      title: widget.season.zagTitle,
      disabled: !widget.season.monitored!,
      body: [
        _subtitle1(),
        _subtitle2(),
        _subtitle3(),
      ],
      trailing: _trailing(),
      onTap: _onTap,
      onLongPress: _onLongPress,
    );
  }

  String _posterUrl() {
    final images = widget.season.images;
    final poster = images?.firstWhereOrNull((e) => e.coverType == 'poster');
    return poster?.remoteUrl ?? poster?.url ?? '';
  }

  Future<void> _onTap() async {
    SonarrRoutes.SERIES_SEASON.go(params: {
      'series': (widget.seriesId ?? -1).toString(),
      'season': (widget.season.seasonNumber ?? -1).toString(),
    });
  }

  Future<void> _onLongPress() async {
    Tuple2<bool, SonarrSeasonSettingsType?> result = await SonarrDialogs()
        .seasonSettings(context, widget.season.seasonNumber);
    if (result.item1)
      result.item2!.execute(
        context,
        widget.seriesId,
        widget.season.seasonNumber,
      );
  }

  TextSpan _subtitle1() {
    return TextSpan(
      text: widget.season.statistics?.previousAiring?.asDateTime(
            showSeconds: false,
            delimiter: '@'.pad(),
          ) ??
          ZagUI.TEXT_EMDASH,
    );
  }

  TextSpan _subtitle2() {
    return TextSpan(
      text: widget.season.statistics?.sizeOnDisk?.asBytes(decimals: 1) ??
          ZagUI.TEXT_EMDASH,
    );
  }

  TextSpan _subtitle3() {
    return TextSpan(
      style: TextStyle(
        color: widget.season.zagPercentageComplete == 100
            ? ZagColours.currentAccent
            : ZagColours.red,
        fontWeight: ZagUI.FONT_WEIGHT_BOLD,
      ),
      text: [
        '${widget.season.zagPercentageComplete}%',
        ZagUI.TEXT_BULLET,
        '${widget.season.statistics?.episodeFileCount ?? 0}/${widget.season.statistics?.episodeCount ?? 0}',
        'sonarr.EpisodesAvailable'.tr(),
      ].join(' '),
    );
  }

  Widget _trailing() {
    Future<void> setLoadingState(ZagLoadingState state) async {
      if (this.mounted) setState(() => _loadingState = state);
    }

    return ZagIconButton(
      icon: widget.season.monitored!
          ? Icons.turned_in_rounded
          : Icons.turned_in_not_rounded,
      color: ZagColours.white,
      loadingState: _loadingState,
      onPressed: () async {
        setLoadingState(ZagLoadingState.ACTIVE);
        await SonarrAPIController()
            .toggleSeasonMonitored(
              context: context,
              season: widget.season,
              seriesId: widget.seriesId,
            )
            .whenComplete(() => setLoadingState(ZagLoadingState.INACTIVE));
      },
    );
  }
}
