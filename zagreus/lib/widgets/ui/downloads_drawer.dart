import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';

class ZagDownloadsDrawer extends StatefulWidget {
  const ZagDownloadsDrawer({Key? key}) : super(key: key);

  @override
  State<ZagDownloadsDrawer> createState() => _ZagDownloadsDrawerState();
}

class _ZagDownloadsDrawerState extends State<ZagDownloadsDrawer> {
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
            // Header
            Padding(
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
                  Text(
                    'Downloads',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Content
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    // Check if SABnzbd or NZBGet are enabled
    final sabnzbdEnabled = ZagBox.profiles.read(ZagreusDatabase.ENABLED_PROFILE.read())?.sabnzbdEnabled ?? false;
    final nzbgetEnabled = ZagBox.profiles.read(ZagreusDatabase.ENABLED_PROFILE.read())?.nzbgetEnabled ?? false;

    if (!sabnzbdEnabled && !nzbgetEnabled) {
      return _buildEmptyState();
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (sabnzbdEnabled) _buildSabnzbdSection(),
        if (sabnzbdEnabled && nzbgetEnabled) const SizedBox(height: 24),
        if (nzbgetEnabled) _buildNzbgetSection(),
      ],
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

  Widget _buildSabnzbdSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              ZagIcons.SABNZBD,
              color: ZagModule.SABNZBD.color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'SABnzbd',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ZagModule.SABNZBD.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildSabnzbdQueue(),
      ],
    );
  }

  Widget _buildNzbgetSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              ZagIcons.NZBGET,
              color: ZagModule.NZBGET.color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'NZBGet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ZagModule.NZBGET.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildNzbgetQueue(),
      ],
    );
  }

  Widget _buildSabnzbdQueue() {
    // TODO: Implement actual SABnzbd queue fetching
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          'Queue loading...',
          style: TextStyle(
            color: (Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black)
                .withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildNzbgetQueue() {
    // TODO: Implement actual NZBGet queue fetching
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          'Queue loading...',
          style: TextStyle(
            color: (Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black)
                .withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}
