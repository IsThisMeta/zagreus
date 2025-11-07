import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/services/device_id_service.dart';
import 'package:zagreus/services/z_assistant_service.dart';

class ZAgentSettingsRoute extends StatefulWidget {
  const ZAgentSettingsRoute({Key? key}) : super(key: key);

  @override
  State<ZAgentSettingsRoute> createState() => _State();
}

class _State extends State<ZAgentSettingsRoute> with ZagScrollControllerMixin, WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<String> _availableUsers = [];
  bool _loadingUsers = false;
  String? _selectedUser;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _selectedUser = ZagreusDatabase.Z_ASSISTANT_SELECTED_USER_ALIAS.read();
    _loadAvailableUsers();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Reload users when app comes back to foreground
      _loadAvailableUsers();
    }
  }

  Future<void> _loadAvailableUsers() async {
    if (!ZagreusDatabase.Z_ASSISTANT_WATCH_HISTORY_CACHE_ENABLED.read()) {
      print('⏭️  Skipping user load - watch history cache disabled');
      return;
    }

    setState(() => _loadingUsers = true);

    try {
      final deviceId = DeviceIdService().deviceId;
      print('📥 Loading available users for device: ${deviceId.substring(0, 8)}...');

      final service = ZAssistantService();
      final response = await service.getAvailableUsers(deviceId);

      print('📥 Response success: ${response.success}');
      print('📥 Response data: ${response.data}');
      print('📥 Response error: ${response.error}');

      if (response.success && response.data != null) {
        final users = List<String>.from(response.data!['users'] ?? []);
        print('✅ Found ${users.length} available users: $users');

        setState(() {
          _availableUsers = users;
          final serverSelected = response.data!['selected_user_alias'];
          if (serverSelected != null && serverSelected != _selectedUser) {
            _selectedUser = serverSelected;
            ZagreusDatabase.Z_ASSISTANT_SELECTED_USER_ALIAS.update(serverSelected);
          }
        });
      } else {
        print('❌ Failed to load users: ${response.error}');
        if (mounted) {
          showZagErrorSnackBar(
            title: 'Failed to Load Users',
            message: response.error ?? 'Unknown error',
          );
        }
      }
    } catch (e, stack) {
      print('❌ Error loading available users: $e');
      print('Stack trace: $stack');
      if (mounted) {
        showZagErrorSnackBar(
          title: 'Error',
          message: 'Failed to load Tautulli users: $e',
        );
      }
    } finally {
      setState(() => _loadingUsers = false);
    }
  }

  Future<void> _selectUser(String userAlias) async {
    try {
      final deviceId = DeviceIdService().deviceId;
      final service = ZAssistantService();
      final response = await service.selectUser(deviceId, userAlias);

      if (response.success) {
        setState(() => _selectedUser = userAlias);
        ZagreusDatabase.Z_ASSISTANT_SELECTED_USER_ALIAS.update(userAlias);
        showZagSuccessSnackBar(
          title: 'User Selected',
          message: 'Z Agent will now focus on $userAlias\'s viewing history',
        );
      } else {
        showZagErrorSnackBar(
          title: 'Error',
          message: response.error ?? 'Failed to select user',
        );
      }
    } catch (e) {
      showZagErrorSnackBar(
        title: 'Error',
        message: 'Failed to select user: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar() as PreferredSizeWidget?,
      body: _body(),
    );
  }

  Widget _appBar() {
    return ZagAppBar(
      title: 'Z Agent',
      scrollControllers: [scrollController],
    );
  }

  Widget _body() {
    return ZagListView(
      controller: scrollController,
      children: [
        ZagreusDatabase.Z_ASSISTANT_LIBRARY_CACHE_ENABLED.listenableBuilder(
          builder: (context, _) {
            final enabled = ZagreusDatabase.Z_ASSISTANT_LIBRARY_CACHE_ENABLED.read();
            return ZagBlock(
              title: 'Library Cache',
          body: [
            TextSpan(
              text: enabled
                  ? 'Library is synced to Z Agent'
                  : 'Let Z Agent analyze your library',
            ),
          ],
              trailing: ZagSwitch(
                value: enabled,
                onChanged: (value) {
                  ZagreusDatabase.Z_ASSISTANT_LIBRARY_CACHE_ENABLED.update(value);
                  if (value) {
                    showZagInfoSnackBar(
                      title: 'Library Cache Enabled',
                      message: 'Z Agent will now sync your library periodically',
                    );
                  } else {
                    showZagInfoSnackBar(
                      title: 'Library Cache Disabled',
                      message: 'Z Agent will no longer sync your library',
                    );
                  }
                },
              ),
            );
          },
        ),
        ZagreusDatabase.Z_ASSISTANT_WATCH_HISTORY_CACHE_ENABLED.listenableBuilder(
          builder: (context, _) {
            final enabled = ZagreusDatabase.Z_ASSISTANT_WATCH_HISTORY_CACHE_ENABLED.read();
            return ZagBlock(
              title: 'Watch History Cache',
          body: [
            TextSpan(
              text: enabled
                  ? 'Tautulli watch history synced to Z Agent'
                  : 'Sync your Tautulli watch history',
            ),
          ],
              trailing: ZagSwitch(
                value: enabled,
                onChanged: (value) {
                  ZagreusDatabase.Z_ASSISTANT_WATCH_HISTORY_CACHE_ENABLED.update(value);
                  if (value) {
                    showZagInfoSnackBar(
                      title: 'Watch History Cache Enabled',
                      message: 'Z Agent will now sync your Tautulli watch history',
                    );
                    _loadAvailableUsers();
                  } else {
                    showZagInfoSnackBar(
                      title: 'Watch History Cache Disabled',
                      message: 'Z Agent will no longer sync watch history',
                    );
                  }
                },
              ),
            );
          },
        ),
        if (ZagreusDatabase.Z_ASSISTANT_WATCH_HISTORY_CACHE_ENABLED.read() && _availableUsers.isNotEmpty)
          ZagBlock(
            title: 'Select Your Tautulli User',
            body: [
              TextSpan(
                text: _selectedUser != null
                    ? 'AI recommendations personalized for $_selectedUser'
                    : 'Choose which Tautulli user you are',
              ),
            ],
            bottom: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                ..._availableUsers.map((userAlias) {
                  final isSelected = _selectedUser == userAlias;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ZagButton.text(
                      text: userAlias,
                      icon: isSelected ? Icons.check_circle : Icons.circle_outlined,
                      onTap: () => _selectUser(userAlias),
                      backgroundColor: isSelected ? ZagColours.currentAccent : null,
                    ),
                  );
                }).toList(),
                if (_loadingUsers)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
            bottomHeight: (_availableUsers.length * 54.0) + (_loadingUsers ? 40 : 0) + 12,
          ),
      ],
    );
  }
}
