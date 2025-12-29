import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/api/bazarr/bazarr.dart';
import 'package:zagreus/api/bazarr/models.dart';
import 'package:zagreus/extensions/string/string.dart';
import 'package:zagreus/utils/zagreus_pro.dart';

class RadarrBazarrSubtitleTile extends StatefulWidget {
  final int radarrId;

  const RadarrBazarrSubtitleTile({
    Key? key,
    required this.radarrId,
  }) : super(key: key);

  @override
  State<RadarrBazarrSubtitleTile> createState() => _State();
}

class _State extends State<RadarrBazarrSubtitleTile> {
  BazarrMovie? _bazarrMovie;
  bool _loading = true;
  String? _error;
  bool _searchingSubtitles = false;

  @override
  void initState() {
    super.initState();
    _loadBazarrData();
  }

  BazarrAPI? _getApi() {
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

  Future<void> _loadBazarrData() async {
    final api = _getApi();
    if (api == null) {
      setState(() {
        _loading = false;
        _error = null;
      });
      return;
    }

    try {
      final movie = await api.movie.get(radarrId: widget.radarrId);
      setState(() {
        _bazarrMovie = movie;
        _loading = false;
        _error = null;
      });
    } catch (e, stack) {
      ZagLogger().error('Failed to load Bazarr data', e, stack);
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _autoSearchSubtitles() async {
    final api = _getApi();
    if (api == null) return;

    final missing = _bazarrMovie?.missingSubtitles ?? [];

    // If there are missing subtitles, let user pick which language to search
    if (missing.isNotEmpty) {
      final selected = await _showLanguageSelectionDialog(missing);
      if (selected == null) return; // User cancelled

      setState(() => _searchingSubtitles = true);
      try {
        await api.movie.autoSearch(
          radarrId: widget.radarrId,
          language: selected.code2,
          hearingImpaired: selected.hearingImpaired,
          forced: selected.forced,
        );
        showZagSuccessSnackBar(
          title: 'Subtitle Search Started',
          message: 'Searching for ${selected.name ?? selected.code2}...',
        );
        await Future.delayed(const Duration(seconds: 2));
        await _loadBazarrData();
      } catch (e, stack) {
        ZagLogger().error('Failed to search subtitles', e, stack);
        showZagErrorSnackBar(
          title: 'Subtitle Search Failed',
          error: e,
        );
      } finally {
        setState(() => _searchingSubtitles = false);
      }
    } else {
      // No missing subtitles - search anyway (user explicitly requested)
      setState(() => _searchingSubtitles = true);
      try {
        await api.movie.autoSearch(radarrId: widget.radarrId);
        showZagSuccessSnackBar(
          title: 'Subtitle Search Started',
          message: 'Bazarr is searching for subtitles...',
        );
        await Future.delayed(const Duration(seconds: 2));
        await _loadBazarrData();
      } catch (e, stack) {
        ZagLogger().error('Failed to search subtitles', e, stack);
        showZagErrorSnackBar(
          title: 'Subtitle Search Failed',
          error: e,
        );
      } finally {
        setState(() => _searchingSubtitles = false);
      }
    }
  }

  Future<BazarrSubtitle?> _showLanguageSelectionDialog(
      List<BazarrSubtitle> languages) async {
    return showDialog<BazarrSubtitle>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Language'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: languages.map((lang) {
              final flags = <String>[];
              if (lang.hearingImpaired == true) flags.add('HI');
              if (lang.forced == true) flags.add('Forced');
              return ListTile(
                title: Text(lang.name ?? lang.code2 ?? 'Unknown'),
                subtitle: flags.isNotEmpty ? Text(flags.join(' • ')) : null,
                onTap: () => Navigator.pop(ctx, lang),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: TextStyle(color: ZagColours.textColor(ctx))),
          ),
        ],
      ),
    );
  }

  Future<void> _manualSearchSubtitles() async {
    final api = _getApi();
    if (api == null) return;

    setState(() => _searchingSubtitles = true);

    try {
      final results = await api.provider.searchMovieSubtitles(
        radarrId: widget.radarrId,
      );
      setState(() => _searchingSubtitles = false);

      if (!mounted) return;

      if (results.isEmpty) {
        showZagInfoSnackBar(
          title: 'No Subtitles Found',
          message: 'No subtitles available from providers',
        );
        return;
      }

      await _showManualSearchResults(results);
    } catch (e, stack) {
      ZagLogger().error('Failed to search subtitles', e, stack);
      showZagErrorSnackBar(
        title: 'Subtitle Search Failed',
        error: e,
      );
      setState(() => _searchingSubtitles = false);
    }
  }

  Future<void> _showManualSearchResults(
      List<BazarrSubtitleSearchResult> results) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _SubtitleSearchResultsPage(
          results: results,
          onDownload: _downloadSubtitle,
        ),
      ),
    );
  }

  Future<void> _downloadSubtitle(BazarrSubtitleSearchResult result) async {
    final api = _getApi();
    if (api == null) return;

    try {
      await api.provider.downloadMovieSubtitle(
        radarrId: widget.radarrId,
        language: result.language ?? '',
        provider: result.provider ?? '',
        subtitle: result.subtitle ?? '',
        hearingImpaired: result.hearingImpaired == 'True',
        forced: result.forced == 'True',
      );
      showZagSuccessSnackBar(
        title: 'Subtitle Downloaded',
        message: '${result.language} subtitle from ${result.provider}',
      );
      // Pop the search results page and reload data
      if (mounted) Navigator.of(context).pop();
      await _loadBazarrData();
    } catch (e, stack) {
      ZagLogger().error('Failed to download subtitle', e, stack);
      showZagErrorSnackBar(
        title: 'Download Failed',
        error: e,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Don't show anything if Bazarr is not enabled
    if (!ZagProfile.current.bazarrEnabled) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ZagHeader(text: 'Subtitles'),
        _buildContent(),
      ],
    );
  }

  Widget _buildContent() {
    // Show lock for non-Pro users
    if (!ZagreusPro.isEnabled) {
      return _proLockedTile();
    }

    // Show not configured if Bazarr is not set up
    final host = ZagProfile.current.effectiveBazarrHost();
    if (host.isEmpty || ZagProfile.current.bazarrKey.isEmpty) {
      return _notConfiguredTile();
    }

    if (_loading) {
      return _loadingTile();
    }

    if (_error != null) {
      return _errorTile();
    }

    if (_bazarrMovie == null) {
      return _noDataTile();
    }

    return _subtitleContent();
  }

  Widget _notConfiguredTile() {
    return ZagBlock(
      title: 'Bazarr Not Configured',
      body: const [
        TextSpan(text: 'Set up Bazarr in Settings to manage subtitles'),
      ],
      trailing: ZagIconButton(
        icon: Icons.settings_rounded,
        onPressed: () => ZagModule.BAZARR.settingsRoute?.go(),
      ),
    );
  }

  Widget _loadingTile() {
    return const ZagBlock(
      title: 'Loading Subtitles',
      body: [TextSpan(text: 'Fetching subtitle data from Bazarr...')],
      trailing: ZagLoader(),
    );
  }

  Widget _errorTile() {
    return ZagBlock(
      title: 'Connection Error',
      body: const [
        TextSpan(text: 'Could not load subtitle data from Bazarr'),
      ],
      trailing: ZagIconButton(
        icon: Icons.refresh_rounded,
        onPressed: () {
          setState(() => _loading = true);
          _loadBazarrData();
        },
      ),
    );
  }

  Widget _noDataTile() {
    return ZagBlock(
      title: 'Not Found in Bazarr',
      body: const [
        TextSpan(text: 'This wasn\'t found in your Bazarr library'),
      ],
      trailing: ZagIconButton(
        icon: Icons.refresh_rounded,
        onPressed: () {
          setState(() => _loading = true);
          _loadBazarrData();
        },
      ),
    );
  }

  Widget _subtitleContent() {
    final existing = _bazarrMovie?.existingSubtitles ?? [];
    final missing = _bazarrMovie?.missingSubtitles ?? [];
    final hasMissing = missing.isNotEmpty;

    return Column(
      children: [
        // Status block with search action
        ZagBlock(
          title: existing.isEmpty && missing.isEmpty
              ? 'No Subtitle Requirements'
              : '${existing.length} Downloaded${hasMissing ? ', ${missing.length} Missing' : ''}',
          body: [
            TextSpan(
              text: existing.isEmpty && missing.isEmpty
                  ? 'Configure subtitle languages in Bazarr'
                  : hasMissing
                      ? 'Tap search to find missing subtitles'
                      : 'All required subtitles are available',
            ),
          ],
          trailing: _searchingSubtitles
              ? const ZagLoader()
              : OverflowBox(
                  maxWidth: 96,
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ZagIconButton(
                        icon: Icons.person_rounded,
                        color: hasMissing ? ZagColours.currentAccent : null,
                        onPressed: _manualSearchSubtitles,
                      ),
                      ZagIconButton(
                        icon: Icons.search_rounded,
                        color: hasMissing ? ZagColours.currentAccent : null,
                        onPressed: _autoSearchSubtitles,
                      ),
                    ],
                  ),
                ),
        ),
        // Downloaded subtitles list
        if (existing.isNotEmpty)
          ZagTableCard(
            title: 'Downloaded',
            content: existing.map((s) => ZagTableContent(
              title: s.name ?? s.code2 ?? 'Unknown',
              body: _formatSubtitleFlags(s),
            )).toList(),
          ),
        // Missing subtitles list
        if (missing.isNotEmpty)
          ZagTableCard(
            title: 'Missing',
            content: missing.map((s) => ZagTableContent(
              title: s.name ?? s.code2 ?? 'Unknown',
              body: _formatSubtitleFlags(s),
            )).toList(),
          ),
      ],
    );
  }

  String? _formatSubtitleFlags(BazarrSubtitle s) {
    final flags = <String>[];
    if (s.forced == true) flags.add('Forced');
    if (s.hearingImpaired == true) flags.add('HI');
    return flags.isEmpty ? null : flags.join(' • ');
  }

  Widget _proLockedTile() {
    return ZagBlock(
      title: 'Zagreus Pro Required',
      body: const [
        TextSpan(text: 'Upgrade to Pro to manage subtitles with Bazarr'),
      ],
      trailing: const ZagIconButton(icon: Icons.lock_rounded),
      onTap: () => showZagInfoSnackBar(
        title: 'Zagreus Pro Required',
        message: 'Upgrade to access Bazarr subtitle management',
      ),
    );
  }
}

/// Full page for displaying subtitle search results, matching Radarr releases style.
class _SubtitleSearchResultsPage extends StatefulWidget {
  final List<BazarrSubtitleSearchResult> results;
  final Future<void> Function(BazarrSubtitleSearchResult) onDownload;

  const _SubtitleSearchResultsPage({
    required this.results,
    required this.onDownload,
  });

  @override
  State<_SubtitleSearchResultsPage> createState() =>
      _SubtitleSearchResultsPageState();
}

class _SubtitleSearchResultsPageState extends State<_SubtitleSearchResultsPage>
    with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: ZagAppBar(
        title: 'Subtitles (${widget.results.length})',
        scrollControllers: [scrollController],
      ),
      body: widget.results.isEmpty
          ? ZagMessage(text: 'No Subtitles Found')
          : ZagListViewBuilder(
              controller: scrollController,
              itemCount: widget.results.length,
              itemBuilder: (context, index) => _SubtitleResultTile(
                result: widget.results[index],
                onDownload: () => widget.onDownload(widget.results[index]),
              ),
            ),
    );
  }
}

/// Individual subtitle result tile using ZagExpandableListTile pattern.
class _SubtitleResultTile extends StatefulWidget {
  final BazarrSubtitleSearchResult result;
  final VoidCallback onDownload;

  const _SubtitleResultTile({
    required this.result,
    required this.onDownload,
  });

  @override
  State<_SubtitleResultTile> createState() => _SubtitleResultTileState();
}

class _SubtitleResultTileState extends State<_SubtitleResultTile> {
  ZagLoadingState _downloadState = ZagLoadingState.INACTIVE;

  @override
  Widget build(BuildContext context) {
    return ZagExpandableListTile(
      title: _title(),
      collapsedSubtitles: [
        _subtitle1(),
        _subtitle2(),
      ],
      collapsedTrailing: _trailing(),
      expandedHighlightedNodes: _highlightedNodes(),
      expandedTableContent: _tableContent(),
      expandedTableButtons: _tableButtons(),
    );
  }

  String _title() {
    // Use first release info element as title (like nzb360), fallback to provider
    if (widget.result.releaseInfo?.isNotEmpty ?? false) {
      return widget.result.releaseInfo!.first;
    }
    return widget.result.provider ?? 'Unknown Provider';
  }

  TextSpan _subtitle1() {
    return TextSpan(
      children: [
        TextSpan(
          text: widget.result.language ?? 'Unknown',
          style: TextStyle(
            color: ZagColours.currentAccent,
            fontWeight: ZagUI.FONT_WEIGHT_BOLD,
          ),
        ),
        TextSpan(text: ZagUI.TEXT_BULLET.pad()),
        TextSpan(text: widget.result.provider ?? 'Unknown'),
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
    if (widget.result.hearingImpaired == 'True') flags.add('HI');
    if (widget.result.forced == 'True') flags.add('Forced');

    return TextSpan(
      children: [
        TextSpan(
          text: '${widget.result.matches?.length ?? 0} Matches',
          style: TextStyle(color: Colors.green),
        ),
        TextSpan(text: ZagUI.TEXT_BULLET.pad()),
        TextSpan(
          text: '${widget.result.dontMatches?.length ?? 0} Missing',
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
        text: widget.result.language ?? 'Unknown',
        backgroundColor: ZagColours.currentAccent,
      ),
    ];

    if (widget.result.hearingImpaired == 'True') {
      nodes.add(ZagHighlightedNode(
        text: 'HI',
        backgroundColor: ZagColours.orange,
      ));
    }
    if (widget.result.forced == 'True') {
      nodes.add(ZagHighlightedNode(
        text: 'Forced',
        backgroundColor: ZagColours.purple,
      ));
    }

    return nodes;
  }

  List<ZagTableContent> _tableContent() {
    return [
      ZagTableContent(title: 'provider', body: widget.result.provider),
      ZagTableContent(title: 'language', body: widget.result.language),
      ZagTableContent(title: 'score', body: '${widget.result.score ?? 0}'),
      ZagTableContent(
        title: 'matches',
        body: '${widget.result.matches?.length ?? 0}',
      ),
      ZagTableContent(
        title: 'missing',
        body: '${widget.result.dontMatches?.length ?? 0}',
      ),
      if (widget.result.uploader?.isNotEmpty ?? false)
        ZagTableContent(title: 'uploader', body: widget.result.uploader),
      if (widget.result.releaseInfo?.isNotEmpty ?? false)
        ZagTableContent(
          title: 'release',
          body: widget.result.releaseInfo!.join('\n'),
        ),
    ];
  }

  List<ZagButton> _tableButtons() {
    return [
      ZagButton(
        type: ZagButtonType.TEXT,
        text: 'Download',
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
      if (mounted) {
        setState(() => _downloadState = ZagLoadingState.INACTIVE);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _downloadState = ZagLoadingState.ERROR);
      }
    }
  }

  Color _scoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 50) return ZagColours.orange;
    return ZagColours.red;
  }
}

