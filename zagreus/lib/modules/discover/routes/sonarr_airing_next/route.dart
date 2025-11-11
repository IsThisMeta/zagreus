import 'dart:async';

import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/api/sonarr/sonarr.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/router/routes/sonarr.dart';

class SonarrAiringNextRoute extends StatefulWidget {
  final List<Map<String, dynamic>>? initialData;

  const SonarrAiringNextRoute({
    Key? key,
    this.initialData,
  }) : super(key: key);

  @override
  State<SonarrAiringNextRoute> createState() => _State();
}

class _State extends State<SonarrAiringNextRoute>
    with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Map<String, dynamic>> _airingNextShows = [];
  bool _isLoading = true;
  String? _error;
  int _daysAhead = 14; // Default to 14 days (2 weeks)

  @override
  void initState() {
    super.initState();
    if (widget.initialData?.isNotEmpty == true) {
      _airingNextShows = List<Map<String, dynamic>>.from(widget.initialData!);
      _isLoading = false;
      Future.microtask(() {
        if (mounted) {
          _loadAiringNextShows(silent: true);
        }
      });
    } else {
      _loadAiringNextShows();
    }
  }

  Future<void> _loadAiringNextShows({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    } else {
      _error = null;
    }

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

      // Get episodes airing in the next N days
      final now = DateTime.now();
      final endDate = now.add(Duration(days: _daysAhead));

      final calendar = await api.calendar.get(
        start: now,
        end: endDate,
        unmonitored: false, // Only get monitored episodes
        includeSeries: true,
        includeEpisodeFile: true,
      );

      // Filter to only monitored episodes that haven't aired yet
      final upcomingEpisodes = calendar.where((episode) {
        return episode.monitored == true &&
            episode.airDateUtc != null &&
            episode.airDateUtc!.isAfter(now);
      }).toList();

      // Sort by air date
      upcomingEpisodes.sort((a, b) => a.airDateUtc!.compareTo(b.airDateUtc!));

      // Map to UI format
      final shows = <Map<String, dynamic>>[];
      for (final episode in upcomingEpisodes) {
        final series = episode.series;

        if (series != null) {
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

          shows.add({
            'seriesTitle': series.title ?? 'Unknown Series',
            'episodeTitle': episode.title ?? 'Episode ${episode.episodeNumber}',
            'seasonNumber': episode.seasonNumber ?? 0,
            'episodeNumber': episode.episodeNumber ?? 0,
            'network': series.network ?? 'Network',
            'thumbnail': imageUrl,
            'airDateUtc': episode.airDateUtc,
            'seriesId': series.id,
            'episodeId': episode.id,
            'overview': episode.overview,
            'hasFile': episode.hasFile ?? false,
          });
        }
      }

      if (!mounted) return;
      setState(() {
        _airingNextShows = shows;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      print('Error loading Sonarr airing next: $e');
      if (!mounted) return;
      if (silent && _airingNextShows.isNotEmpty) {
        return;
      }
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatAiringTime(DateTime? airDateUtc, String? network) {
    if (airDateUtc == null) return '';

    // Convert UTC to local time
    final localTime = airDateUtc.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final episodeDay = DateTime(localTime.year, localTime.month, localTime.day);

    String dayLabel;
    if (episodeDay == today) {
      dayLabel = 'Today';
    } else if (episodeDay == tomorrow) {
      dayLabel = 'Tomorrow';
    } else {
      // Format as "Mon, Jan 15"
      final weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      dayLabel =
          '${weekdays[localTime.weekday % 7]}, ${months[localTime.month - 1]} ${localTime.day}';
    }

    // Format time as "3:00 PM"
    final hour = localTime.hour;
    final minute = localTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    // Truncate network name if too long
    final networkName = network ?? '';
    final truncatedNetwork = networkName.length > 12
        ? '${networkName.substring(0, 12)}...'
        : networkName;

    return '$dayLabel • $displayHour:$minute $period${truncatedNetwork.isNotEmpty ? ' on $truncatedNetwork' : ''}';
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
      title: 'Airing Next',
      actions: [
        PopupMenuButton<int>(
          icon: Icon(Icons.filter_list_rounded),
          onSelected: (days) {
            setState(() {
              _daysAhead = days;
            });
            _loadAiringNextShows();
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 1,
              child: Text('Next 24 hours'),
            ),
            PopupMenuItem(
              value: 3,
              child: Text('Next 3 days'),
            ),
            PopupMenuItem(
              value: 7,
              child: Text('Next week'),
            ),
            PopupMenuItem(
              value: 14,
              child: Text('Next 2 weeks'),
            ),
            PopupMenuItem(
              value: 30,
              child: Text('Next month'),
            ),
          ],
        ),
        IconButton(
          icon: Icon(Icons.refresh_rounded),
          onPressed: _loadAiringNextShows,
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

    if (_error != null && _airingNextShows.isEmpty) {
      return ZagMessage.error(
        onTap: _loadAiringNextShows,
      );
    }

    if (_airingNextShows.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.schedule_rounded,
              size: 60,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No Upcoming Episodes',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No monitored episodes airing in the next $_daysAhead days',
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
      onRefresh: _loadAiringNextShows,
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _airingNextShows.length,
        itemBuilder: (context, index) {
          final episode = _airingNextShows[index];
          return _episodeCard(episode);
        },
      ),
    );
  }

  Widget _episodeCard(Map<String, dynamic> episode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        height: 72,
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                Container(
                  width: 120,
                  height: 72,
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
                          '${episode['seasonNumber']}x${episode['episodeNumber'].toString().padLeft(2, '0')} • ${episode['episodeTitle']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _formatAiringTime(
                                    episode['airDateUtc'], episode['network']),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: ZagColours.blue,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (episode['hasFile'] == true) ...[
                          const SizedBox(height: 4),
                          const Text(
                            'Downloaded',
                            style: TextStyle(
                              fontSize: 11,
                              color: ZagColours.blue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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
}
