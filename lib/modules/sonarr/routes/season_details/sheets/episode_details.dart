import 'package:flutter/material.dart';
import 'package:zagreus/api/bazarr/bazarr.dart';
import 'package:zagreus/api/bazarr/models.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/datetime.dart';
import 'package:zagreus/extensions/int/bytes.dart';
import 'package:zagreus/extensions/string/string.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/router/routes/sonarr.dart';
import 'package:zagreus/utils/zagreus_pro.dart';

class SonarrEpisodeDetailsSheet extends ZagBottomModalSheet {
  BuildContext context;
  SonarrEpisode? episode;
  SonarrEpisodeFile? episodeFile;
  List<SonarrQueueRecord>? queueRecords;

  SonarrEpisodeDetailsSheet({
    required this.context,
    required this.episode,
    required this.episodeFile,
    required this.queueRecords,
  }) {
    _intializeSheet();
  }

  Future<void> _intializeSheet() async {
    SonarrSeasonDetailsState _state = context.read<SonarrSeasonDetailsState>();
    _state.currentEpisodeId = episode!.id;
    _state.episodeSearchState = ZagLoadingState.INACTIVE;
    _state.fetchState(
      context,
      shouldFetchEpisodes: false,
      shouldFetchFiles: false,
      shouldFetchHistory: false,
    );
  }

  Widget _highlightedNodes(BuildContext context) {
    List<ZagHighlightedNode> _nodes = [
      if (!episode!.monitored!)
        ZagHighlightedNode(
          text: 'sonarr.Unmonitored'.tr(),
          backgroundColor: ZagColours.red,
        ),
      if (episode!.hasFile! && episodeFile != null)
        ZagHighlightedNode(
          backgroundColor: episodeFile!.qualityCutoffNotMet!
              ? ZagColours.orange
              : ZagColours.currentAccent,
          text: episodeFile!.quality?.quality?.name ?? ZagUI.TEXT_EMDASH,
        ),
      if (episode!.hasFile! &&
          episodeFile != null &&
          episodeFile!.languageCutoffNotMet != null)
        ZagHighlightedNode(
          backgroundColor: episodeFile!.languageCutoffNotMet!
              ? ZagColours.orange
              : ZagColours.currentAccent,
          text: episodeFile!.language?.name ?? ZagUI.TEXT_EMDASH,
        ),
      if (episode!.hasFile! && episodeFile != null)
        ZagHighlightedNode(
          backgroundColor: ZagColours.blueGrey,
          text: episodeFile!.size?.asBytes() ?? ZagUI.TEXT_EMDASH,
        ),
      if (!episode!.hasFile! &&
          (episode?.airDateUtc?.toLocal().isAfter(DateTime.now()) ?? true))
        ZagHighlightedNode(
          backgroundColor: ZagColours.blue,
          text: 'sonarr.Unaired'.tr(),
        ),
      if (!episode!.hasFile! &&
          (episode?.airDateUtc?.toLocal().isBefore(DateTime.now()) ?? false))
        ZagHighlightedNode(
          backgroundColor: ZagColours.red,
          text: 'sonarr.Missing'.tr(),
        ),
    ];
    if (_nodes.isEmpty) return const SizedBox(height: 0, width: 0);
    return Padding(
      child: Wrap(
        direction: Axis.horizontal,
        spacing: ZagUI.DEFAULT_MARGIN_SIZE / 2,
        runSpacing: ZagUI.DEFAULT_MARGIN_SIZE / 2,
        children: _nodes,
      ),
      padding: ZagUI.MARGIN_H_DEFAULT_V_HALF.copyWith(top: 0),
    );
  }

  List<Widget> _episodeDetails(BuildContext context) {
    return [
      ZagHeader(
        text: episode!.title,
        subtitle: [
          episode!.airDateUtc != null
              ? DateFormat.yMMMMd().format(episode!.airDateUtc!.toLocal())
              : 'zagreus.UnknownDate'.tr(),
          '\n',
          'sonarr.SeasonNumber'.tr(
            args: [episode?.seasonNumber?.toString() ?? ZagUI.TEXT_EMDASH],
          ),
          ZagUI.TEXT_BULLET.pad(),
          'sonarr.EpisodeNumber'.tr(
            args: [episode?.episodeNumber?.toString() ?? ZagUI.TEXT_EMDASH],
          ),
          if (episode?.absoluteEpisodeNumber != null)
            ' (${episode!.absoluteEpisodeNumber})',
        ].join(),
      ),
      _highlightedNodes(context),
      Padding(
        padding: ZagUI.MARGIN_DEFAULT_HORIZONTAL,
        child: ZagText.subtitle(
          text: episode!.overview ?? 'sonarr.NoSummaryAvailable'.tr(),
          maxLines: 0,
          softWrap: true,
        ),
      ),
    ];
  }

  List<Widget> _files(BuildContext context) {
    if (!episode!.hasFile! || episodeFile == null) return [];
    return [
      ZagTableCard(
        content: [
          ZagTableContent(
            title: 'sonarr.RelativePath'.tr(),
            body: episodeFile!.relativePath ?? ZagUI.TEXT_EMDASH,
          ),
          ZagTableContent(
            title: 'sonarr.Video'.tr(),
            body: episodeFile?.mediaInfo?.videoCodec,
          ),
          ZagTableContent(
            title: 'sonarr.Audio'.tr(),
            body: [
              episodeFile?.mediaInfo?.audioCodec ?? ZagUI.TEXT_EMDASH,
              if (episodeFile?.mediaInfo?.audioChannels != null)
                episodeFile?.mediaInfo?.audioChannels?.toString(),
            ].join(ZagUI.TEXT_BULLET.pad()),
          ),
          ZagTableContent(
            title: 'sonarr.Size'.tr(),
            body: episodeFile!.size?.asBytes() ?? ZagUI.TEXT_EMDASH,
          ),
          ZagTableContent(
            title: 'sonarr.AddedOn'.tr(),
            body: episodeFile?.dateAdded?.asDateTime(delimiter: '\n'),
          ),
        ],
        buttons: [
          if (episodeFile?.mediaInfo != null)
            ZagButton.text(
              text: 'sonarr.MediaInfo'.tr(),
              icon: Icons.info_outline_rounded,
              onTap: () async =>
                  SonarrMediaInfoSheet(mediaInfo: episodeFile!.mediaInfo)
                      .show(),
            ),
          ZagButton(
            type: ZagButtonType.TEXT,
            text: 'zagreus.Delete'.tr(),
            icon: Icons.delete_rounded,
            onTap: () async {
              bool result = await SonarrDialogs().deleteEpisode(context);
              if (result) {
                SonarrAPIController()
                    .deleteEpisode(
                        context: context,
                        episode: episode!,
                        episodeFile: episodeFile!)
                    .then((_) {
                  episode!.hasFile = false;
                  context
                      .read<SonarrSeasonDetailsState>()
                      .fetchHistory(context);
                  context
                      .read<SonarrSeasonDetailsState>()
                      .fetchEpisodeHistory(context, episode!.id);
                });
              }
            },
            color: ZagColours.red,
          ),
        ],
      ),
    ];
  }

  BazarrAPI? _getBazarrApi() {
    if (!ZagreusPro.isEnabled) return null;
    final profile = ZagProfile.current;
    if (!profile.bazarrEnabled) return null;
    final host = profile.effectiveBazarrHost();
    if (host.isEmpty || profile.bazarrKey.isEmpty) return null;
    return BazarrAPI(
      host: host,
      apiKey: profile.bazarrKey,
      headers: Map<String, dynamic>.from(profile.bazarrHeaders),
    );
  }

  List<Widget> _bazarrSubtitles(BuildContext context) {
    // Only show if episode has a file and Bazarr is configured
    if (!episode!.hasFile! || episodeFile == null) return [];
    if (!ZagProfile.current.bazarrEnabled) return [];
    if (!ZagreusPro.isEnabled) return [];

    final api = _getBazarrApi();
    if (api == null) return [];

    return [
      _BazarrSubtitleButtons(
        api: api,
        seriesId: episode!.seriesId!,
        episodeId: episode!.id!,
      ),
    ];
  }

  List<Widget> _queue(BuildContext context) {
    if (queueRecords?.isNotEmpty ?? false) {
      return queueRecords!
          .map((r) => SonarrQueueTile(
                queueRecord: r,
                type: SonarrQueueTileType.EPISODE,
              ))
          .toList();
    }
    return [];
  }

  List<Widget> _history(BuildContext context) {
    return [
      FutureBuilder(
        future: context
            .select<SonarrSeasonDetailsState, Future<SonarrHistoryPage?>>(
          (s) => s.getEpisodeHistory(episode!.id!),
        ),
        builder:
            (BuildContext context, AsyncSnapshot<SonarrHistoryPage?> snapshot) {
          if (snapshot.hasError) {
            if (snapshot.connectionState != ConnectionState.waiting) {
              ZagLogger().error(
                'Unable to fetch Sonarr episode history ${episode!.id}',
                snapshot.error,
                snapshot.stackTrace,
              );
            }
          }
          if (snapshot.hasData) {
            if (snapshot.data!.records!.isEmpty)
              return Padding(
                child: ZagMessage.inList(
                  text: 'sonarr.NoHistoryFound'.tr(),
                ),
                padding: const EdgeInsets.only(
                    bottom: ZagUI.DEFAULT_MARGIN_SIZE / 2),
              );
            return Padding(
              child: Column(
                children: List.generate(
                  snapshot.data!.records!.length,
                  (index) => SonarrHistoryTile(
                    history: snapshot.data!.records![index],
                    episode: episode,
                    type: SonarrHistoryTileType.EPISODE,
                  ),
                ),
              ),
              padding:
                  const EdgeInsets.only(bottom: ZagUI.DEFAULT_MARGIN_SIZE / 2),
            );
          }
          return const Padding(
            child: ZagLoader(
              useSafeArea: false,
              size: 16.0,
            ),
            padding: EdgeInsets.only(
              bottom: ZagUI.DEFAULT_MARGIN_SIZE * 1.5,
              top: ZagUI.DEFAULT_MARGIN_SIZE,
            ),
          );
        },
      ),
    ];
  }

  Widget _actionBar(BuildContext context) {
    return ZagBottomActionBar(
      actions: [
        ZagButton(
          loadingState:
              context.select<SonarrSeasonDetailsState, ZagLoadingState>(
                  (s) => s.episodeSearchState),
          type: ZagButtonType.TEXT,
          text: 'sonarr.Automatic'.tr(),
          icon: Icons.search_rounded,
          onTap: () async {
            context.read<SonarrSeasonDetailsState>().episodeSearchState =
                ZagLoadingState.ACTIVE;
            SonarrAPIController()
                .episodeSearch(context: context, episode: episode!)
                .whenComplete(() => context
                    .read<SonarrSeasonDetailsState>()
                    .episodeSearchState = ZagLoadingState.INACTIVE);
          },
        ),
        ZagButton.text(
          text: 'sonarr.Interactive'.tr(),
          icon: Icons.person_rounded,
          onTap: () {
            SonarrRoutes.RELEASES.go(queryParams: {
              'episode': episode!.id!.toString(),
            });
            context.read<SonarrSeasonDetailsState>().fetchState(
                  context,
                  shouldFetchEpisodes: false,
                  shouldFetchFiles: false,
                );
          },
        ),
      ],
    );
  }

  @override
  Widget builder(BuildContext context) {
    return ChangeNotifierProvider<SonarrSeasonDetailsState>.value(
      value: this.context.watch<SonarrSeasonDetailsState>(),
      builder: (context, _) => Consumer<SonarrSeasonDetailsState>(
        builder: (context, state, _) => FutureBuilder(
          future: Future.wait([
            state.episodes!,
            state.files!,
            state.queue,
            state.getEpisodeHistory(episode!.id!),
          ]),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              SonarrEpisode? _e =
                  (snapshot.data[0] as Map<int, SonarrEpisode>)[episode!.id!];
              episode = _e;
              SonarrEpisodeFile? _ef = (snapshot.data[1]
                  as Map<int, SonarrEpisodeFile>)[episode!.episodeFileId!];
              episodeFile = _ef;
              List<SonarrQueueRecord> _qr =
                  (snapshot.data[2] as List<SonarrQueueRecord>)
                      .where((q) => q.episodeId == episode!.id)
                      .toList();
              queueRecords = _qr;
            }
            return ZagListViewModal(
              children: [
                ..._episodeDetails(context),
                ..._queue(context),
                ..._files(context),
                ..._bazarrSubtitles(context),
                ..._history(context),
              ],
              actionBar: _actionBar(context) as ZagBottomActionBar?,
            );
          },
        ),
      ),
    );
  }
}

/// Bazarr subtitle search buttons for an episode
class _BazarrSubtitleButtons extends StatefulWidget {
  final BazarrAPI api;
  final int seriesId;
  final int episodeId;

  const _BazarrSubtitleButtons({
    required this.api,
    required this.seriesId,
    required this.episodeId,
  });

  @override
  State<_BazarrSubtitleButtons> createState() => _BazarrSubtitleButtonsState();
}

class _BazarrSubtitleButtonsState extends State<_BazarrSubtitleButtons> {
  ZagLoadingState _autoSearchState = ZagLoadingState.INACTIVE;
  ZagLoadingState _manualSearchState = ZagLoadingState.INACTIVE;

  Future<void> _autoSearch() async {
    setState(() => _autoSearchState = ZagLoadingState.ACTIVE);
    try {
      await widget.api.episode.autoSearch(
        seriesId: widget.seriesId,
        episodeId: widget.episodeId,
      );
      showZagSuccessSnackBar(
        title: 'sonarr.SubtitleSearchStarted'.tr(),
        message: 'sonarr.SubtitleSearchStartedMessage'.tr(),
      );
    } catch (e, stack) {
      ZagLogger().error('Failed to auto-search subtitles', e, stack);
      showZagErrorSnackBar(
        title: 'sonarr.SubtitleSearchFailed'.tr(),
        error: e,
      );
    } finally {
      if (mounted) setState(() => _autoSearchState = ZagLoadingState.INACTIVE);
    }
  }

  Future<void> _manualSearch() async {
    setState(() => _manualSearchState = ZagLoadingState.ACTIVE);
    try {
      final results = await widget.api.provider.searchEpisodeSubtitles(
        episodeId: widget.episodeId,
      );

      if (!mounted) return;
      setState(() => _manualSearchState = ZagLoadingState.INACTIVE);

      if (results.isEmpty) {
        showZagInfoSnackBar(
          title: 'sonarr.NoSubtitlesFound'.tr(),
          message: 'sonarr.NoSubtitlesAvailableFromProviders'.tr(),
        );
        return;
      }

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _EpisodeSubtitleSearchResultsPage(
            results: results,
            api: widget.api,
            seriesId: widget.seriesId,
            episodeId: widget.episodeId,
          ),
        ),
      );
    } catch (e, stack) {
      ZagLogger().error('Failed to search subtitles', e, stack);
      showZagErrorSnackBar(
        title: 'sonarr.SubtitleSearchFailed'.tr(),
        error: e,
      );
      if (mounted) setState(() => _manualSearchState = ZagLoadingState.INACTIVE);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ZagTableCard(
      title: 'sonarr.Subtitles'.tr(),
      content: const [],
      buttons: [
        ZagButton(
          type: ZagButtonType.ICON,
          icon: Icons.search_rounded,
          onTap: _autoSearch,
          loadingState: _autoSearchState,
        ),
        ZagButton(
          type: ZagButtonType.ICON,
          icon: Icons.person_rounded,
          onTap: _manualSearch,
          loadingState: _manualSearchState,
        ),
      ],
    );
  }
}

/// Full page for displaying episode subtitle search results
class _EpisodeSubtitleSearchResultsPage extends StatefulWidget {
  final List<BazarrSubtitleSearchResult> results;
  final BazarrAPI api;
  final int seriesId;
  final int episodeId;

  const _EpisodeSubtitleSearchResultsPage({
    required this.results,
    required this.api,
    required this.seriesId,
    required this.episodeId,
  });

  @override
  State<_EpisodeSubtitleSearchResultsPage> createState() =>
      _EpisodeSubtitleSearchResultsPageState();
}

class _EpisodeSubtitleSearchResultsPageState
    extends State<_EpisodeSubtitleSearchResultsPage>
    with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _downloadSubtitle(BazarrSubtitleSearchResult result) async {
    try {
      await widget.api.provider.downloadEpisodeSubtitle(
        seriesId: widget.seriesId,
        episodeId: widget.episodeId,
        language: result.language ?? '',
        provider: result.provider ?? '',
        subtitle: result.subtitle ?? '',
        hearingImpaired: result.hearingImpaired == 'True',
        forced: result.forced == 'True',
      );
      showZagSuccessSnackBar(
        title: 'sonarr.SubtitleDownloaded'.tr(),
        message: 'sonarr.SubtitleDownloadedMessage'.tr(
          args: [
            result.language ?? 'zagreus.Unknown'.tr(),
            result.provider ?? 'sonarr.UnknownProvider'.tr(),
          ],
        ),
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e, stack) {
      ZagLogger().error('Failed to download subtitle', e, stack);
      showZagErrorSnackBar(
        title: 'sonarr.DownloadFailed'.tr(),
        error: e,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: ZagAppBar(
        title: 'sonarr.SubtitlesWithCount'
            .tr(args: [widget.results.length.toString()]),
        scrollControllers: [scrollController],
      ),
      body: widget.results.isEmpty
          ? ZagMessage(text: 'sonarr.NoSubtitlesFound'.tr())
          : ZagListViewBuilder(
              controller: scrollController,
              itemCount: widget.results.length,
              itemBuilder: (context, index) => _EpisodeSubtitleResultTile(
                result: widget.results[index],
                onDownload: () => _downloadSubtitle(widget.results[index]),
              ),
            ),
    );
  }
}

/// Individual subtitle result tile
class _EpisodeSubtitleResultTile extends StatefulWidget {
  final BazarrSubtitleSearchResult result;
  final VoidCallback onDownload;

  const _EpisodeSubtitleResultTile({
    required this.result,
    required this.onDownload,
  });

  @override
  State<_EpisodeSubtitleResultTile> createState() =>
      _EpisodeSubtitleResultTileState();
}

class _EpisodeSubtitleResultTileState extends State<_EpisodeSubtitleResultTile> {
  ZagLoadingState _downloadState = ZagLoadingState.INACTIVE;

  @override
  Widget build(BuildContext context) {
    return ZagExpandableListTile(
      title: _title(),
      collapsedSubtitles: [_subtitle1(), _subtitle2()],
      collapsedTrailing: _trailing(),
      expandedHighlightedNodes: _highlightedNodes(),
      expandedTableContent: _tableContent(),
      expandedTableButtons: _tableButtons(),
    );
  }

  String _title() {
    if (widget.result.releaseInfo?.isNotEmpty ?? false) {
      return widget.result.releaseInfo!.first;
    }
    return widget.result.provider ?? 'sonarr.UnknownProvider'.tr();
  }

  TextSpan _subtitle1() {
    return TextSpan(
      children: [
        TextSpan(
          text: widget.result.language ?? 'zagreus.Unknown'.tr(),
          style: TextStyle(
            color: ZagColours.currentAccent,
            fontWeight: ZagUI.FONT_WEIGHT_BOLD,
          ),
        ),
        TextSpan(text: ZagUI.TEXT_BULLET.pad()),
        TextSpan(text: widget.result.provider ?? 'sonarr.UnknownProvider'.tr()),
        if (widget.result.score != null) ...[
          TextSpan(text: ZagUI.TEXT_BULLET.pad()),
          TextSpan(
            text: '${widget.result.score}',
            style: TextStyle(
              color: _scoreColor(widget.result.score!),
              fontWeight: ZagUI.FONT_WEIGHT_BOLD,
            ),
          ),
        ],
      ],
    );
  }

  TextSpan _subtitle2() {
    final flags = <String>[];
    if (widget.result.hearingImpaired == 'True')
      flags.add('sonarr.SubtitleFlagHI'.tr());
    if (widget.result.forced == 'True')
      flags.add('sonarr.SubtitleFlagForced'.tr());

    return TextSpan(
      children: [
        TextSpan(
          text: 'sonarr.SubtitleMatches'
              .tr(args: ['${widget.result.matches?.length ?? 0}']),
          style: const TextStyle(color: Colors.green),
        ),
        TextSpan(text: ZagUI.TEXT_BULLET.pad()),
        TextSpan(
          text: 'sonarr.SubtitleMissing'
              .tr(args: ['${widget.result.dontMatches?.length ?? 0}']),
          style: TextStyle(color: ZagColours.red),
        ),
        if (flags.isNotEmpty) ...[
          TextSpan(text: ZagUI.TEXT_BULLET.pad()),
          TextSpan(text: flags.join(' • ')),
        ],
      ],
    );
  }

  Widget _trailing() {
    return ZagIconButton(
      icon: Icons.download_rounded,
      color: ZagColours.currentAccent,
      onPressed: _startDownload,
      loadingState: _downloadState,
    );
  }

  List<ZagHighlightedNode> _highlightedNodes() {
    final nodes = <ZagHighlightedNode>[
      ZagHighlightedNode(
        text: widget.result.language ?? 'zagreus.Unknown'.tr(),
        backgroundColor: ZagColours.currentAccent,
      ),
    ];

    if (widget.result.hearingImpaired == 'True') {
      nodes.add(ZagHighlightedNode(
        text: 'sonarr.SubtitleFlagHI'.tr(),
        backgroundColor: ZagColours.orange,
      ));
    }
    if (widget.result.forced == 'True') {
      nodes.add(ZagHighlightedNode(
        text: 'sonarr.SubtitleFlagForced'.tr(),
        backgroundColor: ZagColours.purple,
      ));
    }

    return nodes;
  }

  List<ZagTableContent> _tableContent() {
    return [
      ZagTableContent(
          title: 'sonarr.Provider'.tr(), body: widget.result.provider),
      ZagTableContent(
          title: 'sonarr.Language'.tr(), body: widget.result.language),
      ZagTableContent(
          title: 'sonarr.Score'.tr(), body: '${widget.result.score ?? 0}'),
      ZagTableContent(
        title: 'sonarr.Matches'.tr(),
        body: '${widget.result.matches?.length ?? 0}',
      ),
      ZagTableContent(
        title: 'sonarr.Missing'.tr(),
        body: '${widget.result.dontMatches?.length ?? 0}',
      ),
      if (widget.result.uploader?.isNotEmpty ?? false)
        ZagTableContent(
            title: 'sonarr.Uploader'.tr(), body: widget.result.uploader),
      if (widget.result.releaseInfo?.isNotEmpty ?? false)
        ZagTableContent(
          title: 'sonarr.Release'.tr(),
          body: widget.result.releaseInfo!.join('\n'),
        ),
    ];
  }

  List<ZagButton> _tableButtons() {
    return [
      ZagButton(
        type: ZagButtonType.TEXT,
        text: 'sonarr.Download'.tr(),
        icon: Icons.download_rounded,
        onTap: _startDownload,
        loadingState: _downloadState,
      ),
    ];
  }

  Future<void> _startDownload() async {
    setState(() => _downloadState = ZagLoadingState.ACTIVE);
    try {
      widget.onDownload();
    } catch (e) {
      if (mounted) setState(() => _downloadState = ZagLoadingState.ERROR);
    }
  }

  Color _scoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 50) return ZagColours.orange;
    return ZagColours.red;
  }
}
