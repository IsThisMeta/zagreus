import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/api/bazarr/bazarr.dart';
import 'package:zagreus/api/bazarr/models.dart';
import 'package:zagreus/extensions/string/string.dart';
import 'package:zagreus/utils/zagreus_pro.dart';

class RadarrMovieDetailsFilesPage extends StatefulWidget {
  const RadarrMovieDetailsFilesPage({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<RadarrMovieDetailsFilesPage>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ZagScaffold(
      module: ZagModule.RADARR,
      scaffoldKey: _scaffoldKey,
      body: _body(),
    );
  }

  Widget _body() {
    return ZagRefreshIndicator(
      context: context,
      key: _refreshKey,
      onRefresh: () async =>
          context.read<RadarrMovieDetailsState>().fetchFiles(context),
      child: FutureBuilder(
        future: Future.wait([
          context.watch<RadarrMovieDetailsState>().movieFiles,
          context.watch<RadarrMovieDetailsState>().extraFiles,
        ]),
        builder: (context, AsyncSnapshot<List<Object>> snapshot) {
          if (snapshot.hasError) {
            ZagLogger().error(
              'Unable to fetch Radarr files: ${context.read<RadarrMovieDetailsState>().movie.id}',
              snapshot.error,
              snapshot.stackTrace,
            );
            return ZagMessage.error(onTap: _refreshKey.currentState!.show);
          }
          if (snapshot.hasData) {
            return _list(
              movieFiles: snapshot.requireData[0] as List<RadarrMovieFile>,
              extraFiles: snapshot.requireData[1] as List<RadarrExtraFile>,
            );
          }
          return const ZagLoader();
        },
      ),
    );
  }

  Widget _list({
    required List<RadarrMovieFile> movieFiles,
    required List<RadarrExtraFile> extraFiles,
  }) {
    if (movieFiles.isEmpty && extraFiles.isEmpty) {
      return ZagMessage(
        text: 'radarr.NoFilesFound'.tr(),
        buttonText: 'zagreus.Refresh'.tr(),
        onTap: _refreshKey.currentState!.show,
      );
    }
    final radarrId = context.read<RadarrMovieDetailsState>().movie.id;
    return ZagListView(
      controller: RadarrMovieDetailsNavigationBar.scrollControllers[1],
      children: [
        if (movieFiles.isNotEmpty) ..._filesTiles(movieFiles),
        if (extraFiles.isNotEmpty) ..._extraFilesTiles(extraFiles),
        if (movieFiles.isNotEmpty && radarrId != null)
          _RadarrBazarrSubtitleButtons(radarrId: radarrId),
      ],
    );
  }

  List<Widget> _filesTiles(List<RadarrMovieFile> movieFiles) {
    return List.generate(
      movieFiles.length,
      (idx) => RadarrMovieDetailsFilesFileBlock(file: movieFiles[idx]),
    );
  }

  List<Widget> _extraFilesTiles(List<RadarrExtraFile> extraFiles) {
    return List.generate(
      extraFiles.length,
      (idx) => RadarrMovieDetailsFilesExtraFileBlock(file: extraFiles[idx]),
    );
  }
}

/// Bazarr subtitle search buttons for movie files page.
class _RadarrBazarrSubtitleButtons extends StatefulWidget {
  final int radarrId;

  const _RadarrBazarrSubtitleButtons({required this.radarrId});

  @override
  State<_RadarrBazarrSubtitleButtons> createState() =>
      _RadarrBazarrSubtitleButtonsState();
}

class _RadarrBazarrSubtitleButtonsState
    extends State<_RadarrBazarrSubtitleButtons> {
  ZagLoadingState _autoSearchState = ZagLoadingState.INACTIVE;
  ZagLoadingState _manualSearchState = ZagLoadingState.INACTIVE;

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

  @override
  Widget build(BuildContext context) {
    if (!ZagProfile.current.bazarrEnabled || !ZagreusPro.isEnabled) {
      return const SizedBox.shrink();
    }

    final api = _getBazarrApi();
    if (api == null) return const SizedBox.shrink();

    return ZagTableCard(
      title: 'radarr.Subtitles'.tr(),
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

  Future<void> _autoSearch() async {
    final api = _getBazarrApi();
    if (api == null) return;

    setState(() => _autoSearchState = ZagLoadingState.ACTIVE);
    try {
      await api.movie.autoSearch(radarrId: widget.radarrId);
      showZagSuccessSnackBar(
        title: 'radarr.SubtitleSearchStarted'.tr(),
        message: 'radarr.SubtitleSearchStartedMessage'.tr(),
      );
    } catch (e, stack) {
      ZagLogger().error('Failed to auto search subtitles', e, stack);
      showZagErrorSnackBar(
        title: 'radarr.SearchFailed'.tr(),
        error: e,
      );
    } finally {
      if (mounted) setState(() => _autoSearchState = ZagLoadingState.INACTIVE);
    }
  }

  Future<void> _manualSearch() async {
    final api = _getBazarrApi();
    if (api == null) return;

    setState(() => _manualSearchState = ZagLoadingState.ACTIVE);
    try {
      final results = await api.provider.searchMovieSubtitles(
        radarrId: widget.radarrId,
      );
      if (!mounted) return;
      setState(() => _manualSearchState = ZagLoadingState.INACTIVE);

      if (results.isEmpty) {
        showZagInfoSnackBar(
          title: 'radarr.NoSubtitlesFound'.tr(),
          message: 'radarr.NoSubtitlesAvailableFromProviders'.tr(),
        );
        return;
      }

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _MovieSubtitleSearchResultsPage(
            results: results,
            radarrId: widget.radarrId,
            api: api,
          ),
        ),
      );
    } catch (e, stack) {
      ZagLogger().error('Failed to search subtitles', e, stack);
      showZagErrorSnackBar(
        title: 'radarr.SearchFailed'.tr(),
        error: e,
      );
      if (mounted) setState(() => _manualSearchState = ZagLoadingState.INACTIVE);
    }
  }
}

class _MovieSubtitleSearchResultsPage extends StatefulWidget {
  final List<BazarrSubtitleSearchResult> results;
  final int radarrId;
  final BazarrAPI api;

  const _MovieSubtitleSearchResultsPage({
    required this.results,
    required this.radarrId,
    required this.api,
  });

  @override
  State<_MovieSubtitleSearchResultsPage> createState() =>
      _MovieSubtitleSearchResultsPageState();
}

class _MovieSubtitleSearchResultsPageState
    extends State<_MovieSubtitleSearchResultsPage>
    with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _downloadSubtitle(BazarrSubtitleSearchResult result) async {
    try {
      await widget.api.provider.downloadMovieSubtitle(
        radarrId: widget.radarrId,
        language: result.language ?? '',
        provider: result.provider ?? '',
        subtitle: result.subtitle ?? '',
        hearingImpaired: result.hearingImpaired == 'True',
        forced: result.forced == 'True',
      );
      showZagSuccessSnackBar(
        title: 'radarr.SubtitleDownloaded'.tr(),
        message: 'radarr.SubtitleDownloadedMessage'.tr(
          args: [
            result.language ?? 'zagreus.Unknown'.tr(),
            result.provider ?? 'radarr.UnknownProvider'.tr(),
          ],
        ),
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e, stack) {
      ZagLogger().error('Failed to download subtitle', e, stack);
      showZagErrorSnackBar(
        title: 'radarr.DownloadFailed'.tr(),
        error: e,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: ZagAppBar(
        title: 'radarr.SubtitlesWithCount'
            .tr(args: [widget.results.length.toString()]),
        scrollControllers: [scrollController],
      ),
      body: widget.results.isEmpty
          ? ZagMessage(text: 'radarr.NoSubtitlesFound'.tr())
          : ZagListViewBuilder(
              controller: scrollController,
              itemCount: widget.results.length,
              itemBuilder: (context, index) => _MovieSubtitleResultTile(
                result: widget.results[index],
                onDownload: () => _downloadSubtitle(widget.results[index]),
              ),
            ),
    );
  }
}

class _MovieSubtitleResultTile extends StatefulWidget {
  final BazarrSubtitleSearchResult result;
  final VoidCallback onDownload;

  const _MovieSubtitleResultTile({
    required this.result,
    required this.onDownload,
  });

  @override
  State<_MovieSubtitleResultTile> createState() =>
      _MovieSubtitleResultTileState();
}

class _MovieSubtitleResultTileState extends State<_MovieSubtitleResultTile> {
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
    return widget.result.provider ?? 'radarr.UnknownProvider'.tr();
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
        TextSpan(text: widget.result.provider ?? 'radarr.UnknownProvider'.tr()),
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
      flags.add('radarr.SubtitleFlagHI'.tr());
    if (widget.result.forced == 'True')
      flags.add('radarr.SubtitleFlagForced'.tr());

    return TextSpan(
      children: [
        TextSpan(
          text: 'radarr.SubtitleMatches'
              .tr(args: ['${widget.result.matches?.length ?? 0}']),
          style: const TextStyle(color: Colors.green),
        ),
        TextSpan(text: ZagUI.TEXT_BULLET.pad()),
        TextSpan(
          text: 'radarr.SubtitleMissing'
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
        text: 'radarr.SubtitleFlagHI'.tr(),
        backgroundColor: ZagColours.orange,
      ));
    }
    if (widget.result.forced == 'True') {
      nodes.add(ZagHighlightedNode(
        text: 'radarr.SubtitleFlagForced'.tr(),
        backgroundColor: ZagColours.purple,
      ));
    }
    return nodes;
  }

  List<ZagTableContent> _tableContent() {
    return [
      ZagTableContent(
          title: 'radarr.Provider'.tr(), body: widget.result.provider),
      ZagTableContent(
          title: 'radarr.Language'.tr(), body: widget.result.language),
      ZagTableContent(
          title: 'radarr.Score'.tr(), body: '${widget.result.score ?? 0}'),
      ZagTableContent(
        title: 'radarr.Matches'.tr(),
        body: '${widget.result.matches?.length ?? 0}',
      ),
      ZagTableContent(
          title: 'radarr.Missing'.tr(),
        body: '${widget.result.dontMatches?.length ?? 0}',
      ),
      if (widget.result.uploader?.isNotEmpty ?? false)
        ZagTableContent(
            title: 'radarr.Uploader'.tr(), body: widget.result.uploader),
      if (widget.result.releaseInfo?.isNotEmpty ?? false)
        ZagTableContent(
          title: 'radarr.Release'.tr(),
          body: widget.result.releaseInfo!.join('\n'),
        ),
    ];
  }

  List<ZagButton> _tableButtons() {
    return [
      ZagButton(
        type: ZagButtonType.TEXT,
        text: 'radarr.Download'.tr(),
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
