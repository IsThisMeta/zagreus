import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/api/wake_on_lan/wake_on_lan.dart';
import 'package:zagreus/utils/zagreus_pro.dart';

class ZagDrawer extends StatelessWidget {
  final String page;

  const ZagDrawer({
    Key? key,
    required this.page,
  }) : super(key: key);

  static List<ZagModule> moduleAlphabeticalList() {
    final modules = ZagModule.active.toList()
          ..sort((a, b) =>
              a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    return modules;
  }

  // Cache for module ordered list
  static List<ZagModule>? _cachedOrderedList;
  static List? _lastStoredModules;

  static List<ZagModule> moduleOrderedList() {
    try {
      const db = ZagreusDatabase.DRAWER_MANUAL_ORDER;
      final storedModules = db.read() as List?;

      // Return cached result if the stored modules haven't changed
      if (_cachedOrderedList != null && _lastStoredModules == storedModules) {
        return _cachedOrderedList!;
      }

      print('[DEBUG] moduleOrderedList - stored modules: $storedModules');
      final modules = (storedModules ?? const [])
          .whereType<ZagModule>()
          .toList();
      final missing = ZagModule.active.toList();

      missing.retainWhere((m) => !modules.contains(m));
      modules.addAll(missing);
      modules.retainWhere((m) => m.featureFlag);

      print(
          '[DEBUG] moduleOrderedList - final modules: ${modules.map((m) => m.key).toList()}');

      // Cache the result
      _cachedOrderedList = modules;
      _lastStoredModules = storedModules;

      return modules;
    } catch (error, stack) {
      ZagLogger().error('Failed to create ordered module list', error, stack);
      return moduleAlphabeticalList();
    }
  }

  // Clear cache when order changes
  static void clearModuleOrderCache() {
    _cachedOrderedList = null;
    _lastStoredModules = null;
  }

  @override
  Widget build(BuildContext context) {
    return ZagreusDatabase.ENABLED_PROFILE.listenableBuilder(
      builder: (context, _) => ZagBox.indexers.listenableBuilder(
        builder: (context, _) => Drawer(
          elevation: ZagUI.ELEVATION,
          backgroundColor: Theme.of(context).primaryColor,
          child: ZagreusDatabase.DRAWER_AUTOMATIC_MANAGE.listenableBuilder(
            builder: (context, _) => Column(
              children: [
                ZagDrawerHeader(page: page),
                Expanded(
                  child: ZagListView(
                    controller: PrimaryScrollController.of(context),
                    children: _moduleList(
                      context,
                      () {
                        final autoManage =
                            ZagreusDatabase.DRAWER_AUTOMATIC_MANAGE.read();
                        print(
                            '[DEBUG] Drawer - DRAWER_AUTOMATIC_MANAGE: $autoManage');
                        if (autoManage) {
                          print('[DEBUG] Using alphabetical list');
                          return moduleAlphabeticalList();
                        } else {
                          print('[DEBUG] Using manual ordered list');
                          return moduleOrderedList();
                        }
                      }(),
                    ),
                    physics: const ClampingScrollPhysics(),
                    padding: MediaQuery.of(context).padding.copyWith(top: 0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _sharedHeader(BuildContext context) {
    final modules = <ZagModule>[];
    if (ZagreusPro.isEnabled) {
      modules.add(ZagModule.DISCOVER);
    } else {
      modules.add(ZagModule.DASHBOARD);
    }

    return modules
        .map(
          (module) => _buildEntry(
            context: context,
            module: module,
          ),
        )
        .toList();
  }

  List<Widget> _moduleList(BuildContext context, List<ZagModule> modules) {
    final currentProfile = ZagreusDatabase.ENABLED_PROFILE.read();
    
    return <Widget>[
      ..._sharedHeader(context),
      ...modules.expand((module) {
        if (ZagreusPro.isEnabled && module == ZagModule.DISCOVER) {
          return <Widget>[];
        }
        if (ZagreusPro.isEnabled && module == ZagModule.DASHBOARD) {
          return <Widget>[];
        }
        // Hide premium modules when the user is not Pro
        if ((module == ZagModule.DISCOVER ||
                module == ZagModule.OVERSEERR ||
                module == ZagModule.UNRAID) &&
            !ZagreusPro.isEnabled) {
          return <Widget>[];
        }

        if (!module.isEnabled) {
          return <Widget>[];
        }

        final entries = <Widget>[];
        
        // Add main module entry
        entries.add(_buildEntry(
          context: context,
          module: module,
          onTap: module == ZagModule.WAKE_ON_LAN ? _wakeOnLAN : null,
        ));

        // Add shadow instance entries for this module
        final instances = ZagProfile.getInstancesForModule(currentProfile, module.key);
        for (final instanceKey in instances) {
          final displayName = ZagProfile.getInstanceDisplayName(instanceKey);
          if (displayName != null) {
            entries.add(_buildInstanceEntry(
              context: context,
              module: module,
              instanceKey: instanceKey,
              displayName: displayName,
            ));
          }
        }

        return entries;
      }),
    ];
  }

  Widget _buildInstanceEntry({
    required BuildContext context,
    required ZagModule module,
    required String instanceKey,
    required String displayName,
  }) {
    // Check if this instance is currently active
    final activeInstance = ZagInstanceContext().getActiveInstance(module.key);
    final isCurrentPage = page == module.key.toLowerCase() && activeInstance == instanceKey;
    
    final theme = Theme.of(context);
    final isLightTheme = theme.brightness == Brightness.light;
    final selectedColor = module.color;
    final unselectedColor = isLightTheme ? Colors.black87 : ZagColours.white;

    return SizedBox(
      height: ZagTextInputBar.defaultAppBarHeight,
      child: InkWell(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              child: Icon(
                module.icon,
                color: isCurrentPage ? selectedColor : unselectedColor,
                size: module == ZagModule.UNRAID ? 22 : null,
              ),
              padding: ZagUI.MARGIN_DEFAULT_HORIZONTAL * 1.5,
            ),
            Text(
              '${module.title} $displayName',
              style: TextStyle(
                color: isCurrentPage ? selectedColor : unselectedColor,
                fontWeight: ZagUI.FONT_WEIGHT_BOLD,
              ),
            ),
          ],
        ),
        onTap: () async {
          Navigator.of(context).pop();
          ZagGlobalCubeManager.instance.trackModuleLaunch(module.key);
          // Set the active instance before launching
          ZagInstanceContext().setActiveInstance(module.key, instanceKey);
          // Reset the module state to pick up the new profile
          module.state(context)?.reset();
          module.launch(restore: false);
        },
      ),
    );
  }

  Widget _buildEntry({
    required BuildContext context,
    required ZagModule module,
    void Function()? onTap,
  }) {
    // Only show as current if on this page AND no instance is active
    final activeInstance = ZagInstanceContext().getActiveInstance(module.key);
    bool currentPage = page == module.key.toLowerCase() && activeInstance == null;
    final theme = Theme.of(context);
    final isLightTheme = theme.brightness == Brightness.light;
    final selectedColor = module.color;
    final unselectedColor = isLightTheme ? Colors.black87 : ZagColours.white;

    return SizedBox(
      height: ZagTextInputBar.defaultAppBarHeight,
      child: InkWell(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              child: Icon(
                module.icon,
                color: currentPage ? selectedColor : unselectedColor,
                size: module == ZagModule.UNRAID ? 22 : null,
              ),
              padding: ZagUI.MARGIN_DEFAULT_HORIZONTAL * 1.5,
            ),
            Text(
              module.title,
              style: TextStyle(
                color: currentPage ? selectedColor : unselectedColor,
                fontWeight: ZagUI.FONT_WEIGHT_BOLD,
              ),
            ),
          ],
        ),
        onTap: onTap ??
            () async {
              Navigator.of(context).pop();
              if (!currentPage) {
                ZagGlobalCubeManager.instance.trackModuleLaunch(module.key);
                // Clear any active instance to use the main profile
                ZagInstanceContext().clearActiveInstance(module.key);
                module.state(context)?.reset();
                module.launch(restore: false);
              }
            },
      ),
    );
  }

  Future<void> _wakeOnLAN() async => ZagWakeOnLAN().wake();
}
