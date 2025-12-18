import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/api/sonarr/sonarr.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/router/routes/sonarr.dart';
import 'package:zagreus/modules/sonarr/core/dialogs.dart';
import 'package:zagreus/modules/discover/core/session_cache.dart';

const double _recentlyDownloadedEpisodeThumbWidth = 90;
const double _recentlyDownloadedEpisodeThumbHeight = 53;

class SonarrRecentlyDownloadedRoute extends StatefulWidget {
  final List<Map<String, dynamic>>? initialData;

  const SonarrRecentlyDownloadedRoute({
    Key? key,
    this.initialData,
  }) : super(key: key);

  @override
  State<SonarrRecentlyDownloadedRoute> createState() => _State();
}

class _State extends State<SonarrRecentlyDownloadedRoute>
    with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Map<String, dynamic>> _recentlyDownloadedShows = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Always load fresh data to ensure we have the latest including file sizes
    // But check cache first
    final cached = DiscoverSessionCache().get('SonarrRecentlyDownloadedRoute');
    if (cached != null) {
      _recentlyDownloadedShows = List<Map<String, dynamic>>.from(cached.items);
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.jumpTo(cached.scrollOffset);
        }
      });
      // Optionally reload in background to refresh file sizes?
      // The user wants "have it there", implying fast restoration.
      // If we want fresh data, we might trigger a silent reload.
      Future.microtask(() {
        if (mounted) {
          // We don't have a silent mode for _loadRecentlyDownloadedShows.
          // It sets _isLoading=true immediately.
          // So we keep cached data. Pull to refresh is available.
        }
      });
    } else {
      _loadRecentlyDownloadedShows();
    }
  }

  @override
  void dispose() {
    if (_recentlyDownloadedShows.isNotEmpty) {
      DiscoverSessionCache().set(
        'SonarrRecentlyDownloadedRoute',
        DiscoverRouteState(
          items: _recentlyDownloadedShows,
          currentPage: 1,
          scrollOffset:
              scrollController.hasClients ? scrollController.offset : 0.0,
          hasMorePages: false,
        ),
      );
    }
    super.dispose();
  }

  Future<void> _loadRecentlyDownloadedShows() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final sonarrState = context.read<SonarrState>();
      if (!sonarrState.enabled || sonarrState.api == null) {
        setState(() {
          _error = 'Sonarr is not enabled';
          _isLoading = false;
        });
        return;
      }

      final api = sonarrState.api!;

      // Fetch history sorted by date descending
      final history = await api.history.get(
        page: 1,
        pageSize: 100,
        sortKey: SonarrHistorySortKey.DATE,
        sortDirection: SonarrSortDirection.DESCENDING,
        includeEpisode: true,
        includeSeries: true,
      );

      // Filter to only downloadFolderImported events and dedupe by episodeId
      final downloadedRecords = <SonarrHistoryRecord>[];
      final seenEpisodeIds = <int>{};

      for (final record in history.records ?? []) {
        if (record.eventType == SonarrEventType.DOWNLOAD_FOLDER_IMPORTED &&
            record.episodeId != null &&
            !seenEpisodeIds.contains(record.episodeId)) {
          seenEpisodeIds.add(record.episodeId!);
          downloadedRecords.add(record);
          if (downloadedRecords.length >= 50)
            break; // Show more items on dedicated page
        }
      }

      // Map to UI format
      final shows = <Map<String, dynamic>>[];
      for (final record in downloadedRecords) {
        final episode = record.episode;
        final series = record.series;

        if (episode != null && series != null) {
          // Get fanart or poster image
          String? imageUrl;
          for (final image in series.images ?? []) {
            if (image.coverType == 'fanart') {
              imageUrl = image.remoteUrl ?? image.url;
              break;
            }
          }
          // Fallback to poster if no fanart
          if (imageUrl == null) {
            for (final image in series.images ?? []) {
              if (image.coverType == 'poster') {
                imageUrl = image.remoteUrl ?? image.url;
                break;
              }
            }
          }

          // Pull file size from record.data (size is stored there for download events)
          double? sizeGb;
          final dynamic rawSize = record.data?['size'];

          if (rawSize != null) {
            if (rawSize is num) {
              sizeGb = rawSize / (1024 * 1024 * 1024);
            } else if (rawSize is String) {
              final parsed = num.tryParse(rawSize);
              if (parsed != null) {
                sizeGb = parsed / (1024 * 1024 * 1024);
              }
            }
          }

          shows.add({
            'seriesTitle': series.title ?? 'Unknown Series',
            'episodeTitle': episode.title ?? 'Episode ${episode.episodeNumber}',
            'seasonNumber': episode.seasonNumber ?? 0,
            'episodeNumber': episode.episodeNumber ?? 0,
            'network': 'Downloaded',
            'thumbnail': imageUrl,
            'airDateUtc': episode.airDateUtc,
            'seriesId': series.id,
            'episodeId': episode.id,
            'date': record.date,
            'sizeGb': sizeGb,
          });
        }
      }

      setState(() {
        _recentlyDownloadedShows = shows;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading Sonarr history: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar(),
      body: _body(),
    );
  }

  PreferredSizeWidget _appBar() {
    return ZagAppBar(
      title: 'discover.section.recently_downloaded_shows'.tr(),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh_rounded),
          onPressed: _loadRecentlyDownloadedShows,
        ),
      ],
    ) as PreferredSizeWidget;
  }

  Widget _body() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(ZagColours.currentAccent),
        ),
      );
    }

    if (_error != null) {
      return ZagMessage.error(
        onTap: _loadRecentlyDownloadedShows,
      );
    }

    if (_recentlyDownloadedShows.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.download_done_rounded,
              size: 60,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No Recently Downloaded Episodes',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Downloaded episodes will appear here',
              style: const TextStyle(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRecentlyDownloadedShows,
      child: ListView.builder(
        cacheExtent: 2000.0,
        controller: scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _recentlyDownloadedShows.length,
        itemBuilder: (context, index) {
          final episode = _recentlyDownloadedShows[index];
          return _episodeCard(episode);
        },
      ),
    );
  }

  Widget _episodeCard(Map<String, dynamic> episode) {
    final secondaryTextColor =
        Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.65) ??
            Colors.grey.shade700;
    final seasonEpisode =
        '${episode['seasonNumber']}x${(episode['episodeNumber'] ?? 0).toString().padLeft(2, '0')}';
    final sizeGb = episode['sizeGb'] is num ? episode['sizeGb'] as num : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        constraints: const BoxConstraints(
          minHeight: _recentlyDownloadedEpisodeThumbHeight,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              if (episode['seriesId'] != null) {
                SonarrRoutes.SERIES.go(
                  params: {
                    'series': episode['seriesId'].toString(),
                  },
                );
              }
            },
            onLongPress: () {
              final seriesId = episode['seriesId'];
              if (seriesId is int) {
                _showSeriesActions(seriesId, episode['seriesTitle'] as String?);
              }
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                Container(
                  width: _recentlyDownloadedEpisodeThumbWidth,
                  height: _recentlyDownloadedEpisodeThumbHeight,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    color: Colors.grey.shade800,
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    child: episode['thumbnail'] != null
                        ? Image.network(
                            episode['thumbnail'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _thumbnailPlaceholder();
                            },
                          )
                        : _thumbnailPlaceholder(),
                  ),
                ),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          episode['seriesTitle'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          episode['episodeTitle'] ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: secondaryTextColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                seasonEpisode,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.color
                                          ?.withOpacity(0.55) ??
                                      Colors.grey.shade700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (sizeGb != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                '${sizeGb.toStringAsFixed(2)} GB',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: ZagColours.currentAccent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _thumbnailPlaceholder() {
    return Container(
      color: Colors.grey.shade700,
      child: Center(
        child: Icon(
          Icons.tv_rounded,
          size: 30,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }

  Future<void> _showSeriesActions(int seriesId, String? seriesTitle) async {
    final sonarrState = context.read<SonarrState>();
    if (!sonarrState.enabled || sonarrState.api == null) {
      showZagSnackBar(
        title: seriesTitle ?? 'Sonarr',
        message: 'Connect Sonarr to manage shows from Dashboard.',
        type: ZagSnackbarType.INFO,
      );
      return;
    }

    try {
      SonarrSeries? series;
      Map<int, SonarrSeries>? cached;
      if (sonarrState.series != null) {
        cached = await sonarrState.series!;
        series = cached[seriesId];
      }

      if (series == null) {
        series = await sonarrState.api!.series
            .get(seriesId: seriesId, includeSeasonImages: true);
        if (series != null && sonarrState.series != null) {
          cached ??= await sonarrState.series!;
          cached[series.id!] = series;
        }
      }

      if (series == null) {
        showZagSnackBar(
          title: seriesTitle ?? 'Sonarr',
          message: 'Unable to load this series from Sonarr.',
          type: ZagSnackbarType.ERROR,
        );
        return;
      }

      HapticFeedback.lightImpact();
      final result = await SonarrDialogs().seriesSettings(context, series);
      if (!mounted) return;
      if (result.item1 && result.item2 != null) {
        result.item2!.execute(context, series);
      }
    } catch (error, stack) {
      ZagLogger().error(
        'Failed to open Sonarr actions for series $seriesId',
        error,
        stack,
      );
      if (!mounted) return;
      showZagSnackBar(
        title: seriesTitle ?? 'Sonarr',
        message: 'Unable to open Sonarr actions right now.',
        type: ZagSnackbarType.ERROR,
      );
    }
  }
}
