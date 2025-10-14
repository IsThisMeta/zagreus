import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/router/routes/sonarr.dart';

class SonarrEpisodeTile extends StatefulWidget {
  final SonarrEpisode episode;
  final SonarrEpisodeFile? episodeFile;
  final List<SonarrQueueRecord>? queueRecords;

  const SonarrEpisodeTile({
    Key? key,
    required this.episode,
    this.episodeFile,
    this.queueRecords,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<SonarrEpisodeTile> {
  ZagLoadingState _loadingState = ZagLoadingState.INACTIVE;

  @override
  Widget build(BuildContext context) {
    return ZagBlock(
      disabled: !widget.episode.monitored!,
      title: widget.episode.title,
      body: _body(),
      leading: _leading(),
      trailing: _trailing(),
      onTap: _onTap,
      onLongPress: _onLongPress,
      backgroundColor: context
              .read<SonarrSeasonDetailsState>()
              .selectedEpisodes
              .contains(widget.episode.id)
          ? ZagColours.currentAccent.selected()
          : null,
    );
  }

  Future<void> _onTap() async {
    SonarrEpisodeDetailsSheet(
      context: context,
      episode: widget.episode,
      episodeFile: widget.episodeFile,
      queueRecords: widget.queueRecords,
    ).show();
  }

  Future<void> _onLongPress() async {
    Tuple2<bool, SonarrEpisodeSettingsType?> results = await SonarrDialogs()
        .episodeSettings(context: context, episode: widget.episode);
    if (results.item1) {
      results.item2!.execute(
        context: context,
        episode: widget.episode,
        episodeFile: widget.episodeFile,
      );
    }
  }

  List<TextSpan> _body() {
    return [
      TextSpan(text: widget.episode.zagAirDate()),
      TextSpan(
        text: widget.episode.zagDownloadedQuality(
          widget.episodeFile,
          widget.queueRecords?.isNotEmpty ?? false
              ? widget.queueRecords!.first
              : null,
        ),
        style: TextStyle(
          color: widget.episode.zagDownloadedQualityColor(
            widget.episodeFile,
            widget.queueRecords?.isNotEmpty ?? false
                ? widget.queueRecords!.first
                : null,
          ),
          fontWeight: ZagUI.FONT_WEIGHT_BOLD,
        ),
      ),
    ];
  }

  Widget _leading() {
    return ZagIconButton(
      text: widget.episode.episodeNumber.toString(),
      textSize: ZagUI.FONT_SIZE_H4,
      onPressed: () {
        context
            .read<SonarrSeasonDetailsState>()
            .toggleSelectedEpisode(widget.episode);
      },
    );
  }

  Widget _trailing() {
    Future<void> setLoadingState(ZagLoadingState state) async {
      if (this.mounted) setState(() => _loadingState = state);
    }

    return ZagIconButton(
      icon: Icons.search_rounded,
      loadingState: _loadingState,
      onPressed: () async {
        setLoadingState(ZagLoadingState.ACTIVE);
        SonarrAPIController()
            .episodeSearch(
              context: context,
              episode: widget.episode,
            )
            .whenComplete(() => setLoadingState(ZagLoadingState.INACTIVE));
      },
      onLongPress: () async {
        SonarrRoutes.RELEASES.go(queryParams: {
          'episode': widget.episode.id!.toString(),
        });
      },
    );
  }
}
