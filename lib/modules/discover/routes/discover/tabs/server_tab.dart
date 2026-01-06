import 'package:flutter/material.dart';
import 'package:zagreus/api/seerr/models.dart';
import 'package:zagreus/api/sonarr/sonarr.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/tables/ui_preferences.dart';
import 'package:zagreus/modules/discover/widgets/server_sections_editor.dart';
import 'package:zagreus/modules/discover/widgets/tautulli_stream_card.dart';
import 'package:zagreus/modules/lidarr/core/api/api.dart';
import 'package:zagreus/modules/lidarr/core/api/data/history.dart';
import 'package:zagreus/modules/lidarr/widgets/recently_downloaded_card.dart';
import 'package:zagreus/modules/seerr/core/state.dart';
import 'package:zagreus/modules/seerr/routes/requests/widgets/request_tile.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/modules/readarr/core/api/api.dart';
import 'package:zagreus/modules/readarr/core/api/data/history.dart';
import 'package:zagreus/modules/readarr/widgets/recently_downloaded_card.dart';
import 'package:zagreus/modules/sabnzbd/core/api/api.dart';
import 'package:zagreus/modules/tautulli.dart';
import 'package:zagreus/modules/tautulli/core/state.dart';
import 'package:zagreus/modules/unraid/core/download_history_fetcher.dart';
import 'package:zagreus/modules/unraid/routes/unraid/widgets/download_history_card.dart';
import 'package:zagreus/router/routes/settings.dart';

class DiscoverServerTab extends StatefulWidget {
  const DiscoverServerTab({super.key});

  @override
  State<DiscoverServerTab> createState() => _DiscoverServerTabState();
}

class _DiscoverServerTabState extends State<DiscoverServerTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<RadarrDiskSpace> _diskSpaces = [];
  List<_ServerIssue> _serverIssues = [];
  List<SeerrRequest> _seerrRequests = [];
  Map<String, double> _downloadHistoryChartData = {};
  double _downloadHistoryTotalGB = 0;
  int _downloadHistoryWeeks = 2; // Default to 2 weeks for better overview
  List<LidarrRecentlyDownloadedAlbum> _lidarrRecentlyDownloaded = [];
  List<ReadarrRecentlyDownloadedBook> _readarrRecentlyDownloaded = [];
  bool _seerrEnabled = false;
  bool _seerrLoading = false;
  String? _seerrError;
  String _seerrRequestFilter = 'pending';
  bool _isLoading = false;
  String? _error;

  // Tautulli streams state
  List<TautulliSession> _tautulliStreams = [];
  bool _tautulliEnabled = false;
  bool _tautulliLoading = false;
  String? _tautulliError;
  int? _tautulliStreamCount;
  int? _tautulliDirectPlayCount;
  int? _tautulliDirectStreamCount;
  int? _tautulliTranscodeCount;
  int? _tautulliBandwidth;

  @override
  void initState() {
    super.initState();
    _seerrRequestFilter =
        UIPreferencesDatabase.SEERR_REQUEST_FILTER.read() as String;
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadDiskSpaces(),
      _loadServerIssues(),
      _loadSeerrRequests(),
      _loadTautulliStreams(),
      _loadDownloadHistory(),
      _loadLidarrRecentlyDownloaded(),
      _loadReadarrRecentlyDownloaded(),
    ]);
  }

  Future<void> _loadDiskSpaces() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final allDiskSpaces = <RadarrDiskSpace>[];

      // Fetch from Radarr if enabled
      if (ZagProfile.current.radarrEnabled) {
        try {
          final radarrAPI = RadarrAPI(
            host: ZagProfile.current.effectiveRadarrHost(),
            apiKey: ZagProfile.current.radarrKey,
            headers: ZagProfile.current.radarrHeaders.isNotEmpty
                ? Map<String, dynamic>.from(ZagProfile.current.radarrHeaders)
                : null,
          );
          final radarrSpaces = await radarrAPI.fileSystem.getDiskSpace();
          allDiskSpaces.addAll(radarrSpaces);
        } catch (e) {
          ZagLogger().warning('Failed to fetch disk spaces from Radarr: $e');
        }
      }

      // Fetch from Sonarr if enabled
      if (ZagProfile.current.sonarrEnabled) {
        try {
          final sonarrAPI = SonarrAPI(
            host: ZagProfile.current.effectiveSonarrHost(),
            apiKey: ZagProfile.current.sonarrKey,
            headers: ZagProfile.current.sonarrHeaders.isNotEmpty
                ? Map<String, dynamic>.from(ZagProfile.current.sonarrHeaders)
                : null,
          );
          final sonarrSpaces = await sonarrAPI.filesystem.getAllDiskSpaces();
          // Convert SonarrDiskSpace to RadarrDiskSpace format
          allDiskSpaces.addAll(sonarrSpaces.map((s) => RadarrDiskSpace(
                path: s.path,
                label: s.label,
                freeSpace: s.freeSpace,
                totalSpace: s.totalSpace,
              )));
        } catch (e) {
          ZagLogger().warning('Failed to fetch disk spaces from Sonarr: $e');
        }
      }

      // Remove duplicates by path (case-insensitive)
      final seen = <String>{};
      final uniqueSpaces = <RadarrDiskSpace>[];
      for (final space in allDiskSpaces) {
        final pathLower = space.path?.toLowerCase() ?? '';
        if (pathLower.isNotEmpty && !seen.contains(pathLower)) {
          seen.add(pathLower);
          uniqueSpaces.add(space);
        }
      }

      // Sort by path
      uniqueSpaces.sort((a, b) =>
          (a.path ?? '').toLowerCase().compareTo((b.path ?? '').toLowerCase()));

      if (mounted) {
        setState(() {
          _diskSpaces = uniqueSpaces;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadServerIssues() async {
    if (!mounted) return;

    try {
      final allIssues = <_ServerIssue>[];

      // Fetch from Radarr if enabled
      if (ZagProfile.current.radarrEnabled) {
        try {
          final radarrAPI = RadarrAPI(
            host: ZagProfile.current.effectiveRadarrHost(),
            apiKey: ZagProfile.current.radarrKey,
            headers: ZagProfile.current.radarrHeaders.isNotEmpty
                ? Map<String, dynamic>.from(ZagProfile.current.radarrHeaders)
                : null,
          );

          final radarrIssues = await radarrAPI.healthCheck.get();
          allIssues.addAll(radarrIssues.map((issue) => _ServerIssue(
                message:
                    issue.message ?? 'discover.ServerIssuesUnknownIssue'.tr(),
                serviceType: 'discover.RadarrLabel'.tr(),
                icon: ZagIcons.RADARR,
                color: const Color(0xFFFFCB3D),
              )));
        } catch (e) {
          ZagLogger().warning('Failed to fetch health checks from Radarr: $e');
        }
      }

      // Fetch from Sonarr if enabled
      if (ZagProfile.current.sonarrEnabled) {
        try {
          final sonarrAPI = SonarrAPI(
            host: ZagProfile.current.effectiveSonarrHost(),
            apiKey: ZagProfile.current.sonarrKey,
            headers: ZagProfile.current.sonarrHeaders.isNotEmpty
                ? Map<String, dynamic>.from(ZagProfile.current.sonarrHeaders)
                : null,
          );
          final sonarrIssues = await sonarrAPI.healthCheck.get();
          allIssues.addAll(sonarrIssues.map((issue) => _ServerIssue(
                message:
                    issue.message ?? 'discover.ServerIssuesUnknownIssue'.tr(),
                serviceType: 'discover.SonarrLabel'.tr(),
                icon: ZagIcons.SONARR,
                color: const Color(0xFF3FC6F4),
              )));
        } catch (e) {
          ZagLogger().warning('Failed to fetch health checks from Sonarr: $e');
        }
      }

      // Fetch from Lidarr if enabled (when we add it)
      if (ZagProfile.current.lidarrEnabled) {
        // TODO: Add Lidarr health check support
      }

      if (mounted) {
        setState(() {
          _serverIssues = allIssues;
        });
      }
    } catch (e) {
      ZagLogger().warning('Failed to load server issues: $e');
    }
  }

  Future<void> _loadSeerrRequests() async {
    if (!mounted) return;

    final seerrState = context.read<SeerrState>();
    final isConfigured = seerrState.enabled &&
        seerrState.host.isNotEmpty &&
        seerrState.apiKey.isNotEmpty;

    if (!isConfigured) {
      if (!mounted) return;
      setState(() {
        _seerrEnabled = false;
        _seerrLoading = false;
        _seerrError = null;
        _seerrRequests = [];
      });
      return;
    }

    setState(() {
      _seerrEnabled = true;
      _seerrLoading = true;
      _seerrError = null;
    });

    try {
      // Fetch requests using the saved filter preference
      // Note: Client-side filtering is applied in _buildSeerrSectionWithFilter
      seerrState.requestsFilter = _seerrRequestFilter;
      await seerrState.fetchRequests();
      final requests = seerrState.requests ?? [];
      final sorted = List<SeerrRequest>.from(requests)
        ..sort(
          (a, b) {
            final aDate = DateTime.tryParse(a.createdAt) ??
                DateTime.fromMillisecondsSinceEpoch(0);
            final bDate = DateTime.tryParse(b.createdAt) ??
                DateTime.fromMillisecondsSinceEpoch(0);
            return bDate.compareTo(aDate);
          },
        );

      if (!mounted) return;
      setState(() {
        _seerrRequests = sorted;
        _seerrLoading = false;
        _seerrError = seerrState.requestsError;
      });
    } catch (e) {
      ZagLogger().warning('Failed to fetch Seerr requests: $e');
      if (!mounted) return;
      setState(() {
        _seerrError = e.toString();
        _seerrLoading = false;
        _seerrRequests = [];
      });
    }
  }

  bool get _shouldShowSeerrSection =>
      _seerrEnabled ||
      _seerrLoading ||
      _seerrError != null ||
      _seerrRequests.isNotEmpty;

  Future<void> _loadTautulliStreams() async {
    if (!mounted) return;

    final tautulliState = context.read<TautulliState>();

    if (!tautulliState.enabled) {
      if (!mounted) return;
      setState(() {
        _tautulliEnabled = false;
        _tautulliLoading = false;
        _tautulliError = null;
        _tautulliStreams = [];
      });
      return;
    }

    setState(() {
      _tautulliEnabled = true;
      _tautulliLoading = true;
      _tautulliError = null;
    });

    try {
      final activity = await tautulliState.api!.activity.getActivity();

      if (!mounted) return;
      setState(() {
        _tautulliStreams = activity?.sessions ?? [];
        _tautulliStreamCount = activity?.streamCount;
        _tautulliDirectPlayCount = activity?.streamCountDirectPlay;
        _tautulliDirectStreamCount = activity?.streamCountDirectStream;
        _tautulliTranscodeCount = activity?.streamCountTranscode;
        _tautulliBandwidth = activity?.totalBandwidth;
        _tautulliLoading = false;
      });
    } catch (e) {
      ZagLogger().warning('Failed to load Tautulli streams: $e');
      if (!mounted) return;
      setState(() {
        _tautulliError = e.toString();
        _tautulliLoading = false;
        _tautulliStreams = [];
      });
    }
  }

  bool get _shouldShowTautulliStreamsSection =>
      _tautulliEnabled ||
      _tautulliLoading ||
      _tautulliError != null ||
      _tautulliStreams.isNotEmpty;

  Future<void> _loadDownloadHistory() async {
    if (!mounted) return;

    // Only load download history if SABnzbd is enabled
    try {
      print(
          '🔍 Loading download history - SABnzbd enabled: ${ZagProfile.current.sabnzbdEnabled}');

      if (ZagProfile.current.sabnzbdEnabled) {
        final sabnzbdApi = SABnzbdAPI.from(ZagProfile.current);
        final historyData =
            await DownloadHistoryFetcher.fetchSabnzbdDownloadStats(
          api: sabnzbdApi,
          weeksLookBack: _downloadHistoryWeeks, // Use 2 weeks
        );

        print(
            '🔍 Download history loaded: ${historyData.chartData.length} days, ${historyData.totalGB} GB');
        print('🔍 Chart data: ${historyData.chartData}');

        if (!mounted) return;
        setState(() {
          _downloadHistoryChartData = historyData.chartData;
          _downloadHistoryTotalGB = historyData.totalGB;
        });

        print('🔍 State updated with download history');
      } else {
        print('🔍 SABnzbd not enabled, skipping download history');
      }
    } catch (e, stackTrace) {
      print('❌ Failed to load download history: $e');
      print('❌ Stack trace: $stackTrace');
      ZagLogger().debug('Failed to load download history: $e');
      // Fail silently - this is optional data
    }
  }

  Future<void> _loadLidarrRecentlyDownloaded() async {
    print('🎵 _loadLidarrRecentlyDownloaded() called');
    if (!mounted) return;

    try {
      print('🎵 Lidarr enabled: ${ZagProfile.current.lidarrEnabled}');
      if (ZagProfile.current.lidarrEnabled) {
        print('🎵 Creating Lidarr API...');
        final api = LidarrAPI.from(ZagProfile.current);
        print('🎵 Fetching Lidarr history...');
        final history = await api.getHistory(
          sortKey: 'date',
          sortDir: 'descending',
          pageSize: 100,
        );
        print('🎵 Got ${history.length} history records');

        // Filter to only downloadImported events and dedupe by album
        final seenAlbumIds = <int>{};
        final albums = <LidarrRecentlyDownloadedAlbum>[];

        for (final record in history) {
          if (record is LidarrHistoryDataDownloadImported &&
              !seenAlbumIds.contains(record.albumID)) {
            seenAlbumIds.add(record.albumID);

            // Get artist name
            final artist = await api.getArtist(record.artistID);

            // Get album cover from Lidarr API
            String? coverUrl;
            try {
              // Construct cover URL from Lidarr API
              // Note: Lidarr uses /mediacover/Album/{albumId} for album covers
              coverUrl =
                  '${ZagProfile.current.effectiveLidarrHost()}/api/v1/mediacover/Album/${record.albumID}/cover.jpg?apikey=${ZagProfile.current.lidarrKey}';
            } catch (e) {
              // Fallback to null if URL construction fails
              coverUrl = null;
            }

            albums.add(LidarrRecentlyDownloadedAlbum(
              albumId: record.albumID,
              artistId: record.artistID,
              albumTitle: record.title,
              artistName: artist.title,
              coverUrl: coverUrl,
              downloadedAt: record.timestampObject ?? DateTime.now(),
            ));

            if (albums.length >= 10) break; // Limit to 10 for card display
          }
        }

        print('🎵 Processed ${albums.length} albums');
        if (!mounted) return;
        setState(() {
          _lidarrRecentlyDownloaded = albums;
        });
        print(
            '🎵 State updated with ${_lidarrRecentlyDownloaded.length} albums');
      } else {
        print('🎵 Lidarr is disabled, skipping');
      }
    } catch (e, stackTrace) {
      print('❌ Failed to load Lidarr recently downloaded: $e');
      print('❌ Stack trace: $stackTrace');
      ZagLogger().debug('Failed to load Lidarr recently downloaded: $e');
      // Fail silently - this is optional data
    }
  }

  Future<void> _loadReadarrRecentlyDownloaded() async {
    print('📚 _loadReadarrRecentlyDownloaded() called');
    if (!mounted) return;

    try {
      print('📚 Readarr enabled: ${ZagProfile.current.readarrEnabled}');
      if (ZagProfile.current.readarrEnabled) {
        print('📚 Creating Readarr API...');
        final api = ReadarrAPI.from(ZagProfile.current);
        print('📚 Fetching Readarr history...');
        final history = await api.getHistory(
          sortKey: 'date',
          sortDir: 'descending',
          pageSize: 100,
        );
        print('📚 Got ${history.length} history records');

        // Filter to only downloadImported events and dedupe by book
        final seenBookIds = <int>{};
        final books = <ReadarrRecentlyDownloadedBook>[];

        for (final record in history) {
          if (record is ReadarrHistoryDataDownloadImported &&
              !seenBookIds.contains(record.bookID)) {
            seenBookIds.add(record.bookID);

            try {
              // Get book details for cover and rating
              final book = await api.getBook(record.bookID);

              // Get cover URL from book images
              String? coverUrl;
              if (book.images != null && book.images!.isNotEmpty) {
                final coverImage = book.images!.firstWhere(
                  (img) => img['coverType'] == 'cover',
                  orElse: () => book.images!.first,
                );
                coverUrl = coverImage['url'] ?? coverImage['remoteUrl'];
              }

              // Fallback: construct cover URL manually if not found
              if (coverUrl == null || coverUrl.isEmpty) {
                coverUrl =
                    '${ZagProfile.current.effectiveReadarrHost()}/api/v1/mediacover/${record.bookID}/cover.jpg?apikey=${ZagProfile.current.readarrKey}';
              }

              books.add(ReadarrRecentlyDownloadedBook(
                bookId: record.bookID,
                authorId: record.authorID,
                bookTitle: book.title,
                authorName: book.authorName,
                coverUrl: coverUrl,
                rating: book.rating,
                downloadedAt: record.timestampObject ?? DateTime.now(),
              ));

              if (books.length >= 10) break; // Limit to 10 for card display
            } catch (e) {
              print('📚 Failed to get book details for ${record.bookID}: $e');
              // Continue to next record if individual book fetch fails
              continue;
            }
          }
        }

        print('📚 Processed ${books.length} books');
        if (!mounted) return;
        setState(() {
          _readarrRecentlyDownloaded = books;
        });
        print(
            '📚 State updated with ${_readarrRecentlyDownloaded.length} books');
      } else {
        print('📚 Readarr is disabled, skipping');
      }
    } catch (e, stackTrace) {
      print('❌ Failed to load Readarr recently downloaded: $e');
      print('❌ Stack trace: $stackTrace');
      ZagLogger().debug('Failed to load Readarr recently downloaded: $e');
      // Fail silently - this is optional data
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(ZagColours.currentAccent),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 60,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'discover.ServerTabLoadFailedTitle'.tr(),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_diskSpaces.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.dns_rounded,
              size: 60,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'discover.ServerTabNoDiskSpaceTitle'.tr(),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'discover.ServerTabNoDiskSpaceMessage'.tr(),
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Get section order from database
    final sectionOrder = UIPreferencesDatabase.SECTION_ORDER.read() as List;
    final orderedSections = sectionOrder.isNotEmpty
        ? List<String>.from(sectionOrder)
        : [
            'server_issues',
            'seerr_requests',
            'tautulli_streams',
            'disk_space',
            'download_history',
            'lidarr_recent',
            'readarr_recent'
          ];

    print('🎵 Ordered sections: $orderedSections');
    print('🎵 Lidarr enabled: ${ZagProfile.current.lidarrEnabled}');
    print('📚 Readarr enabled: ${ZagProfile.current.readarrEnabled}');

    // Build section widgets (conditionally include based on settings)
    final sectionWidgets = <String, List<Widget>>{
      'server_issues': _buildServerIssuesSection(),
      if (_shouldShowSeerrSection)
        'seerr_requests': _buildSeerrSection(),
      if (_shouldShowTautulliStreamsSection)
        'tautulli_streams': _buildTautulliStreamsSection(),
      'disk_space': _buildDiskSpaceSection(),
      if (ZagProfile.current.sabnzbdEnabled)
        'download_history': _buildDownloadHistorySection(),
      if (ZagProfile.current.lidarrEnabled)
        'lidarr_recent': _buildLidarrRecentSection(),
      if (ZagProfile.current.readarrEnabled)
        'readarr_recent': _buildReadarrRecentSection(),
    };

    print('🎵 Section widgets keys: ${sectionWidgets.keys.toList()}');

    return RefreshIndicator(
      onRefresh: _loadData,
      color: ZagColours.currentAccent,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // Render sections in order
          for (final sectionId in orderedSections)
            if (sectionWidgets.containsKey(sectionId))
              ...sectionWidgets[sectionId]!,
          // Edit Sections Button
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ZagUI.DEFAULT_MARGIN_SIZE,
              vertical: 8,
            ),
            child: ZagButton(
              type: ZagButtonType.TEXT,
              text: 'discover.EditSections'.tr(),
              icon: Icons.tune_rounded,
              color: ZagColours.currentAccent,
              onTap: _openServerSectionsEditor,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildServerIssuesSection() {
    if (_serverIssues.isEmpty &&
        !ZagProfile.current.radarrEnabled &&
        !ZagProfile.current.sonarrEnabled) {
      return [];
    }

    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: Text(
          'discover.ServerSectionServerIssues'.tr(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _serverIssues.isEmpty ? Colors.green : Colors.orange,
          ),
        ),
      ),
      if (_serverIssues.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ZagBlock(
            title: 'discover.ServerIssuesAllSystemsOperationalTitle'.tr(),
            body: [
              TextSpan(text: 'discover.ServerIssuesNoIssuesMessage'.tr()),
            ],
            trailing:
                const Icon(Icons.check_circle_outline, color: Colors.green),
          ),
        )
      else
        ..._serverIssues.map((issue) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: ZagBlock(
                title: issue.serviceType,
                body: [
                  TextSpan(text: issue.message),
                ],
                trailing: Icon(issue.icon, color: issue.color),
              ),
            )),
      const SizedBox(height: 24),
    ];
  }

  List<Widget> _buildSeerrSection() {
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: Row(
          children: [
            Text(
              'discover.ServerSectionSeerrRequests'.tr(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color:
                    _seerrEnabled ? ZagModule.SEERR.color : Colors.grey,
              ),
            ),
            const Spacer(),
            if (_seerrEnabled) _buildFilterSelector(),
          ],
        ),
      ),
      if (_seerrLoading)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: ZagLoader(),
          ),
        )
      else if (!_seerrEnabled)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: ZagBlock(
            title: 'discover.SeerrEnableTitle'.tr(),
            body: [
              TextSpan(
                text: 'discover.SeerrEnableMessage'.tr(),
              ),
            ],
            trailing: const Icon(Icons.settings_rounded),
            onTap: SettingsRoutes.CONFIGURATION_SEERR.go,
          ),
        )
      else if (_seerrError != null)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: ZagBlock(
            title: 'discover.SeerrLoadFailedTitle'.tr(),
            body: [
              TextSpan(
                text: 'discover.SeerrLoadFailedMessage'.tr(),
              ),
            ],
            trailing: const Icon(Icons.refresh_rounded),
            onTap: _loadSeerrRequests,
          ),
        )
      else if (_seerrRequests.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: ZagBlock(
            title: _getEmptyStateTitle(),
            body: [
              TextSpan(text: 'discover.SeerrEmptyMessage'.tr()),
            ],
            trailing: const Icon(Icons.inbox_outlined),
            onTap: () => ZagModule.SEERR.launch(),
          ),
        )
      else ...[
        ..._seerrRequests.take(4).map(
              (request) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SeerrRequestTile(
                  request: request,
                ),
              ),
            ),
      ],
      const SizedBox(height: 24),
    ];
  }

  String _getEmptyStateTitle() {
    switch (_seerrRequestFilter) {
      case 'pending':
        return 'discover.SeerrNoPendingRequests'.tr();
      case 'approved':
        return 'discover.SeerrNoApprovedRequests'.tr();
      case 'declined':
        return 'discover.SeerrNoDeclinedRequests'.tr();
      case 'available':
        return 'discover.SeerrNoAvailableContent'.tr();
      case 'processing':
        return 'discover.SeerrNothingProcessing'.tr();
      case 'unavailable':
        return 'discover.SeerrNoUnavailableRequests'.tr();
      default:
        return 'discover.SeerrNoRequestsFound'.tr();
    }
  }

  Widget _buildFilterSelector() {
    final filterOptions = {
      'pending': 'seerr.Pending'.tr(),
      'approved': 'seerr.Approved'.tr(),
      'declined': 'seerr.Declined'.tr(),
      'available': 'seerr.Available'.tr(),
      'processing': 'seerr.Processing'.tr(),
      'unavailable': 'seerr.Unavailable'.tr(),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? ZagColours.secondary
            : ZagColours.secondaryLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white10
              : Colors.black12,
          width: 1,
        ),
      ),
      child: DropdownButton<String>(
        value: _seerrRequestFilter,
        underline: const SizedBox(),
        isDense: true,
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
        dropdownColor: Theme.of(context).brightness == Brightness.dark
            ? ZagColours.secondary
            : ZagColours.secondaryLight,
        icon: Icon(
          Icons.arrow_drop_down_rounded,
          color: ZagColours.accentColor(context),
        ),
        items: filterOptions.entries.map((entry) {
          return DropdownMenuItem<String>(
            value: entry.key,
            child: Text(entry.value),
          );
        }).toList(),
        onChanged: (newFilter) {
          if (newFilter == null) return;
          setState(() {
            _seerrRequestFilter = newFilter;
          });
          UIPreferencesDatabase.SEERR_REQUEST_FILTER.update(newFilter);
          _loadSeerrRequests();
        },
      ),
    );
  }

  List<Widget> _buildTautulliStreamsSection() {
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: Row(
          children: [
            Text(
              'discover.ServerSectionTautulliStreams'.tr(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color:
                    _tautulliEnabled ? ZagModule.TAUTULLI.color : Colors.grey,
              ),
            ),
            const Spacer(),
            if (_tautulliEnabled && _tautulliStreams.isNotEmpty)
              _buildStreamsSummary(),
          ],
        ),
      ),
      if (_tautulliLoading)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: ZagLoader(),
          ),
        )
      else if (!_tautulliEnabled)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: ZagBlock(
            title: 'discover.TautulliEnableTitle'.tr(),
            body: [
              TextSpan(
                text: 'discover.TautulliEnableMessage'.tr(),
              ),
            ],
            trailing: const Icon(Icons.settings_rounded),
            onTap: SettingsRoutes.CONFIGURATION_TAUTULLI.go,
          ),
        )
      else if (_tautulliError != null)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: ZagBlock(
            title: 'discover.TautulliLoadFailedTitle'.tr(),
            body: [
              TextSpan(
                text: 'discover.TautulliLoadFailedMessage'.tr(),
              ),
            ],
            trailing: const Icon(Icons.refresh_rounded),
            onTap: _loadTautulliStreams,
          ),
        )
      else if (_tautulliStreams.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ZagBlock(
            title: 'discover.TautulliNoActiveStreamsTitle'.tr(),
            body: [
              TextSpan(text: 'discover.TautulliNoActiveStreamsMessage'.tr()),
            ],
            trailing: const Icon(Icons.play_circle_outline_rounded),
            onTap: () => ZagModule.TAUTULLI.launch(),
          ),
        )
      else
        ..._tautulliStreams.map(
          (stream) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TautulliStreamCard(
              session: stream,
            ),
          ),
        ),
      const SizedBox(height: 24),
    ];
  }

  Widget _buildStreamsSummary() {
    final parts = <String>[];

    if (_tautulliDirectPlayCount != null && _tautulliDirectPlayCount! > 0) {
      final label = _tautulliDirectPlayCount == 1
          ? 'tautulli.DirectPlay'.tr()
          : 'tautulli.DirectPlays'.tr();
      parts.add('$_tautulliDirectPlayCount $label');
    }
    if (_tautulliDirectStreamCount != null && _tautulliDirectStreamCount! > 0) {
      final label = _tautulliDirectStreamCount == 1
          ? 'tautulli.DirectStream'.tr()
          : 'tautulli.DirectStreams'.tr();
      parts.add('$_tautulliDirectStreamCount $label');
    }
    if (_tautulliTranscodeCount != null && _tautulliTranscodeCount! > 0) {
      final label = _tautulliTranscodeCount == 1
          ? 'tautulli.Transcode'.tr()
          : 'tautulli.Transcodes'.tr();
      parts.add('$_tautulliTranscodeCount $label');
    }

    final summaryText = parts.isEmpty ? '' : parts.join(' • ');
    final bandwidthText = _tautulliBandwidth != null
        ? 'discover.TautulliBandwidthMbps'.tr(
            args: [(_tautulliBandwidth! / 1000).toStringAsFixed(1)],
          )
        : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? ZagColours.secondary
            : ZagColours.secondaryLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white10
              : Colors.black12,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (summaryText.isNotEmpty)
            Text(
              summaryText,
              style: TextStyle(
                fontSize: 12,
                color: ZagColours.accentColor(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          if (bandwidthText.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              bandwidthText,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildDiskSpaceSection() {
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: Text(
          'discover.ServerSectionDiskSpaces'.tr(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: ZagColours.accentColor(context),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? ZagColours.secondary
                : ZagColours.secondaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              for (int i = 0; i < _diskSpaces.length; i++) ...[
                _buildDiskSpaceItem(_diskSpaces[i]),
                if (i < _diskSpaces.length - 1) const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
      const SizedBox(height: 24),
    ];
  }

  Widget _buildDiskSpaceItem(RadarrDiskSpace diskSpace) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 16,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  diskSpace.zagPath ?? '',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.0,
                  ),
                ),
              ),
              Text(
                diskSpace.zagPercentageString ?? '',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: diskSpace.zagColor,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        SizedBox(
          height: 14,
          child: Text(
            diskSpace.zagSpace ?? '',
            style: TextStyle(
              fontSize: 14,
              height: 1.0,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.black54,
            ),
          ),
        ),
        const SizedBox(height: 2),
        SizedBox(
          height: 4,
          child: ZagLinearPercentIndicator(
            compact: true,
            percent: diskSpace.zagPercentage / 100,
            progressColor: diskSpace.zagColor,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildDownloadHistorySection() {
    if (_downloadHistoryChartData.isEmpty) return [];

    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: Row(
          children: [
            Text(
              'discover.ServerSectionDownloadHistory'.tr(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ZagModule.SABNZBD.color,
              ),
            ),
            const Spacer(),
            DropdownButton<int>(
              value: _downloadHistoryWeeks,
              underline: const SizedBox(),
              isDense: true,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
              dropdownColor: Theme.of(context).brightness == Brightness.dark
                  ? ZagColours.secondary
                  : ZagColours.secondaryLight,
              icon: Icon(
                Icons.arrow_drop_down_rounded,
                color: ZagColours.accentColor(context),
              ),
              items: [
                DropdownMenuItem(
                  value: 1,
                  child: Text('unraid.DownloadHistoryOptionOneWeek'.tr()),
                ),
                DropdownMenuItem(
                  value: 2,
                  child: Text('unraid.DownloadHistoryOptionTwoWeeks'.tr()),
                ),
                DropdownMenuItem(
                  value: 4,
                  child: Text('unraid.DownloadHistoryOptionFourWeeks'.tr()),
                ),
                DropdownMenuItem(
                  value: 8,
                  child: Text('unraid.DownloadHistoryOptionEightWeeks'.tr()),
                ),
                DropdownMenuItem(
                  value: 12,
                  child: Text('unraid.DownloadHistoryOptionTwelveWeeks'.tr()),
                ),
              ],
              onChanged: (weeks) {
                if (weeks == null) return;
                setState(() {
                  _downloadHistoryWeeks = weeks;
                });
                _loadDownloadHistory();
              },
            ),
          ],
        ),
      ),
      DownloadHistoryCard(
        chartData: _downloadHistoryChartData,
        totalGB: _downloadHistoryTotalGB,
        periodLabel: _downloadHistoryPeriodLabel(_downloadHistoryWeeks),
      ),
      const SizedBox(height: 24),
    ];
  }

  String _downloadHistoryPeriodLabel(int weeksLookBack) {
    switch (weeksLookBack) {
      case 1:
        return 'unraid.DownloadHistoryPeriodWeek'.tr();
      case 2:
        return 'unraid.DownloadHistoryPeriodTwoWeeks'.tr();
      case 4:
        return 'unraid.DownloadHistoryPeriodMonth'.tr();
      default:
        return 'unraid.DownloadHistoryPeriodWeeks'
            .tr(args: [weeksLookBack.toString()]);
    }
  }

  List<Widget> _buildLidarrRecentSection() {
    print(
        '🎵 _buildLidarrRecentSection() called with ${_lidarrRecentlyDownloaded.length} albums');
    return [
      LidarrRecentlyDownloadedCard(
        albums: _lidarrRecentlyDownloaded,
        onSeeAll: () {
          // TODO: Navigate to full Lidarr history page
        },
        onAlbumTap: (album) {
          // TODO: Navigate to album details
        },
      ),
    ];
  }

  List<Widget> _buildReadarrRecentSection() {
    return [
      ReadarrRecentlyDownloadedCard(
        books: _readarrRecentlyDownloaded,
        onSeeAll: () {
          // TODO: Navigate to full Readarr history page
        },
        onBookTap: (book) {
          // TODO: Navigate to book details
        },
      ),
    ];
  }

  Future<void> _openServerSectionsEditor() async {
    final updated = await showServerSectionsEditorSheet(context);
    if (updated == true && mounted) {
      setState(() {
        _loadData();
      });
    }
  }
}

/// Simple class to hold server issue data with service metadata
class _ServerIssue {
  final String message;
  final String serviceType;
  final IconData icon;
  final Color color;

  _ServerIssue({
    required this.message,
    required this.serviceType,
    required this.icon,
    required this.color,
  });
}
