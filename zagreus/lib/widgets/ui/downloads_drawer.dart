import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/sabnzbd.dart';
import 'package:zagreus/modules/nzbget.dart';

class ZagDownloadsDrawer extends StatefulWidget {
  const ZagDownloadsDrawer({Key? key}) : super(key: key);

  @override
  State<ZagDownloadsDrawer> createState() => _ZagDownloadsDrawerState();
}

class _ZagDownloadsDrawerState extends State<ZagDownloadsDrawer>
    with SingleTickerProviderStateMixin {
  String? _selectedService;
  AnimationController? _playPauseController;

  @override
  void initState() {
    super.initState();
    _setupPlayPauseController();
    // Auto-select first enabled service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoSelectService();
    });
  }

  void _setupPlayPauseController() {
    _playPauseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: ZagUI.ANIMATION_SPEED),
    );
  }

  @override
  void dispose() {
    _playPauseController?.dispose();
    super.dispose();
  }

  void _autoSelectService() {
    final sabnzbdEnabled = ZagBox.profiles.read(ZagreusDatabase.ENABLED_PROFILE.read())?.sabnzbdEnabled ?? false;
    final nzbgetEnabled = ZagBox.profiles.read(ZagreusDatabase.ENABLED_PROFILE.read())?.nzbgetEnabled ?? false;

    if (_selectedService == null) {
      if (sabnzbdEnabled) {
        setState(() => _selectedService = 'sabnzbd');
      } else if (nzbgetEnabled) {
        setState(() => _selectedService = 'nzbget');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: ZagUI.ELEVATION,
      backgroundColor: Theme.of(context).primaryColor,
      width: 320,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Static Header
            _buildHeader(),
            const Divider(height: 1),
            // Scrollable Content
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final sabnzbdEnabled = ZagBox.profiles.read(ZagreusDatabase.ENABLED_PROFILE.read())?.sabnzbdEnabled ?? false;
    final nzbgetEnabled = ZagBox.profiles.read(ZagreusDatabase.ENABLED_PROFILE.read())?.nzbgetEnabled ?? false;
    final bothEnabled = sabnzbdEnabled && nzbgetEnabled;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            Icons.download_rounded,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black87,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Queue',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
          ),
          if (bothEnabled) ...[
            // Service switcher buttons
            _buildServiceButton('sabnzbd', ZagIcons.SABNZBD, ZagModule.SABNZBD.color),
            const SizedBox(width: 8),
            _buildServiceButton('nzbget', ZagIcons.NZBGET, ZagModule.NZBGET.color),
          ],
        ],
      ),
    );
  }

  Widget _buildServiceButton(String service, IconData icon, Color color) {
    final isSelected = _selectedService == service;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedService = service),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: color.withOpacity(0.5), width: 2)
              : Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Icon(
          icon,
          color: isSelected ? color : Colors.grey,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildContent() {
    final sabnzbdEnabled = ZagBox.profiles.read(ZagreusDatabase.ENABLED_PROFILE.read())?.sabnzbdEnabled ?? false;
    final nzbgetEnabled = ZagBox.profiles.read(ZagreusDatabase.ENABLED_PROFILE.read())?.nzbgetEnabled ?? false;

    if (!sabnzbdEnabled && !nzbgetEnabled) {
      return _buildEmptyState();
    }

    // Show selected service, or first enabled one
    if (_selectedService == 'sabnzbd' && sabnzbdEnabled) {
      return _buildServiceView(_buildSabnzbdQueue());
    } else if (_selectedService == 'nzbget' && nzbgetEnabled) {
      return _buildServiceView(_buildNzbgetQueue());
    } else if (sabnzbdEnabled) {
      return _buildServiceView(_buildSabnzbdQueue());
    } else if (nzbgetEnabled) {
      return _buildServiceView(_buildNzbgetQueue());
    }

    return _buildEmptyState();
  }

  Widget _buildServiceView(Widget queueWidget) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: queueWidget,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.download_rounded,
              size: 64,
              color: (Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black)
                  .withOpacity(0.2),
            ),
            const SizedBox(height: 16),
            Text(
              'No download clients configured',
              style: TextStyle(
                fontSize: 16,
                color: (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black)
                    .withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Enable SABnzbd or NZBGet in settings',
              style: TextStyle(
                fontSize: 14,
                color: (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black)
                    .withOpacity(0.3),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSabnzbdQueue() {
    return FutureBuilder(
      future: _fetchSabnzbdQueue(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (snapshot.hasError) {
          return _buildErrorState('Failed to load SABnzbd queue');
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return _buildEmptyQueueState('SABnzbd');
        }

        final queue = snapshot.data!;
        return _buildQueueContent(
          serviceName: 'SABnzbd',
          serviceColor: ZagModule.SABNZBD.color,
          serviceIcon: ZagIcons.SABNZBD,
          queue: queue,
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _fetchSabnzbdQueue() async {
    try {
      final profile = ZagBox.profiles.read(ZagreusDatabase.ENABLED_PROFILE.read());
      if (profile == null || profile.sabnzbdHost == null) return null;

      // Use the SABnzbd API directly
      final api = SABnzbdAPI.from(profile);
      final response = await api.getStatusAndQueue(limit: 50);
      
      final status = response[0] as SABnzbdStatusData;
      final queue = response[1] as List<SABnzbdQueueData>;

      return {
        'paused': status.paused,
        'speed': status.speed.toStringAsFixed(1),
        'timeLeft': status.timeLeft,
        'size': '0',
        'sizeLeft': status.sizeLeft.toStringAsFixed(2),
        'slots': queue.map((item) => {
          'filename': item.name,
          'status': item.status,
          'size': item.sizeTotal.toString(),
          'sizeLeft': item.sizeLeft.toString(),
          'percentage': item.sizeTotal > 0
              ? ((item.sizeTotal - item.sizeLeft) / item.sizeTotal * 100).toStringAsFixed(1)
              : '0',
        }).toList(),
      };
    } catch (e) {
      print('Error fetching SABnzbd queue: $e');
      return null;
    }
  }

  Widget _buildNzbgetQueue() {
    return FutureBuilder(
      future: _fetchNzbgetQueue(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (snapshot.hasError) {
          return _buildErrorState('Failed to load NZBGet queue');
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return _buildEmptyQueueState('NZBGet');
        }

        final queue = snapshot.data!;
        return _buildQueueContent(
          serviceName: 'NZBGet',
          serviceColor: ZagModule.NZBGET.color,
          serviceIcon: ZagIcons.NZBGET,
          queue: queue,
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _fetchNzbgetQueue() async {
    try {
      final profile = ZagBox.profiles.read(ZagreusDatabase.ENABLED_PROFILE.read());
      if (profile == null || profile.nzbgetHost == null) return null;

      // Use the NZBGet API directly  
      final api = NZBGetAPI.from(profile);
      final response = await api.getHistory(hidden: false);
      
      // NZBGet uses history API - filter for recent/active items
      final recentItems = response.take(10).toList();
      
      return {
        'paused': false,
        'speed': '0',
        'timeLeft': '0:00:00',
        'size': '0',
        'sizeLeft': '0',
        'slots': recentItems.map((item) => {
          'filename': item.name,
          'status': item.statusString,
          'size': item.sizeReadable,
          'sizeLeft': '0 MB',
          'percentage': '100',
        }).toList(),
      };
    } catch (e) {
      print('Error fetching NZBGet queue: $e');
      return null;
    }
  }

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(ZagColours.currentAccent),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black)
                    .withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyQueueState(String serviceName) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 48,
              color: Colors.green.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No active downloads',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black)
                    .withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$serviceName queue is empty',
              style: TextStyle(
                color: (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black)
                    .withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueContent({
    required String serviceName,
    required Color serviceColor,
    required IconData serviceIcon,
    required Map<String, dynamic> queue,
  }) {
    final slots = (queue['slots'] as List?) ?? [];
    final paused = queue['paused'] as bool? ?? false;
    final speed = queue['speed'] as String? ?? '0';
    final timeLeft = queue['timeLeft'] as String? ?? '0:00:00';

    // Update animation controller based on paused state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_playPauseController != null) {
        if (paused) {
          _playPauseController!.forward();
        } else {
          _playPauseController!.reverse();
        }
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with stats and play/pause button
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: serviceColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(serviceIcon, color: serviceColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    serviceName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: serviceColor,
                    ),
                  ),
                  const Spacer(),
                  if (paused)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'PAUSED',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem('Speed', '$speed KB/s'),
                  ),
                  Expanded(
                    child: _buildStatItem('Time Left', timeLeft),
                  ),
                  // Play/Pause button
                  Transform.translate(
                    offset: const Offset(-13, 0),
                    child: IconButton(
                      icon: AnimatedIcon(
                        icon: AnimatedIcons.pause_play,
                        progress: _playPauseController!,
                        color: serviceColor,
                      ),
                      iconSize: 32,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _togglePlayPause(serviceName, paused),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Queue items
        if (slots.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Queue is empty',
                style: TextStyle(
                  color: (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black)
                      .withOpacity(0.5),
                ),
              ),
            ),
          )
        else
          ...slots.map((slot) => _buildQueueItem(slot, serviceColor)).toList(),
      ],
    );
  }

  Future<void> _togglePlayPause(String serviceName, bool isPaused) async {
    try {
      final profile = ZagBox.profiles.read(ZagreusDatabase.ENABLED_PROFILE.read());
      if (profile == null) return;

      HapticFeedback.lightImpact();

      if (serviceName == 'SABnzbd') {
        final api = SABnzbdAPI.from(profile);
        if (isPaused) {
          await api.resumeQueue();
          showZagSuccessSnackBar(
            title: 'SABnzbd Queue',
            message: 'Resumed',
          );
        } else {
          await api.pauseQueue();
          showZagSuccessSnackBar(
            title: 'SABnzbd Queue',
            message: 'Paused',
          );
        }
      } else if (serviceName == 'NZBGet') {
        final api = NZBGetAPI.from(profile);
        if (isPaused) {
          await api.resumeQueue();
          showZagSuccessSnackBar(
            title: 'NZBGet Queue',
            message: 'Resumed',
          );
        } else {
          await api.pauseQueue();
          showZagSuccessSnackBar(
            title: 'NZBGet Queue',
            message: 'Paused',
          );
        }
      }

      // Refresh the drawer after toggle
      setState(() {});
    } catch (e) {
      showZagErrorSnackBar(
        title: 'Failed to ${isPaused ? 'Resume' : 'Pause'} Queue',
        error: e,
      );
    }
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: (Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black)
                .withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildQueueItem(Map<String, dynamic> slot, Color serviceColor) {
    final filename = slot['filename'] as String? ?? 'Unknown';
    final status = slot['status'] as String? ?? 'Unknown';
    final percentage = slot['percentage'] as String? ?? '0';
    final size = slot['size'] as String? ?? '0';
    final sizeLeft = slot['sizeLeft'] as String? ?? '0';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            filename,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                status,
                style: TextStyle(
                  fontSize: 11,
                  color: serviceColor,
                ),
              ),
              const Spacer(),
              Text(
                '$sizeLeft / $size MB',
                style: TextStyle(
                  fontSize: 11,
                  color: (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black)
                      .withOpacity(0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: double.tryParse(percentage)?.clamp(0, 100) ?? 0 / 100,
              backgroundColor: serviceColor.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(serviceColor),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
