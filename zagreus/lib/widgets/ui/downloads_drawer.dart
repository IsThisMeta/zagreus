import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';

class ZagDownloadsDrawer extends StatefulWidget {
  const ZagDownloadsDrawer({Key? key}) : super(key: key);

  @override
  State<ZagDownloadsDrawer> createState() => _ZagDownloadsDrawerState();
}

class _ZagDownloadsDrawerState extends State<ZagDownloadsDrawer> {
  String? _selectedService;

  @override
  void initState() {
    super.initState();
    // Auto-select first enabled service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoSelectService();
    });
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
            // Header with service switcher
            _buildHeader(),
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
              'Downloads',
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [queueWidget],
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
    // TODO: Implement actual SABnzbd queue fetching
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
              'SABnzbd Queue',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ZagModule.SABNZBD.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
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
        ),
      ],
    );
  }

  Widget _buildNzbgetQueue() {
    // TODO: Implement actual NZBGet queue fetching
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
              'NZBGet Queue',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ZagModule.NZBGET.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
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
        ),
      ],
    );
  }
}
