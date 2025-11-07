import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/api/wake_on_lan/wake_on_lan.dart';
import 'package:zagreus/utils/zagreus_pro.dart';
import 'package:zagreus/database/tables/zagreus.dart';

class ZagDrawer extends StatelessWidget {
  final String page;

  const ZagDrawer({
    Key? key,
    required this.page,
  }) : super(key: key);

  static List<ZagModule> moduleAlphabeticalList() {
    return ZagModule.active
      ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
  }

  static List<ZagModule> moduleOrderedList() {
    try {
      const db = ZagreusDatabase.DRAWER_MANUAL_ORDER;
      final storedModules = db.read();
      print('[DEBUG] moduleOrderedList - stored modules: $storedModules');
      final modules = List.from(storedModules);
      final missing = ZagModule.active;

      missing.retainWhere((m) => !modules.contains(m));
      modules.addAll(missing);
      modules.retainWhere((m) => (m as ZagModule).featureFlag);

      print('[DEBUG] moduleOrderedList - final modules: ${modules.map((m) => (m as ZagModule).key).toList()}');
      return modules.cast<ZagModule>();
    } catch (error, stack) {
      ZagLogger().error('Failed to create ordered module list', error, stack);
      return moduleAlphabeticalList();
    }
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
                        final autoManage = ZagreusDatabase.DRAWER_AUTOMATIC_MANAGE.read();
                        print('[DEBUG] Drawer - DRAWER_AUTOMATIC_MANAGE: $autoManage');
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
    return [
      _buildEntry(
        context: context,
        module: ZagModule.DASHBOARD,
      ),
    ];
  }

  List<Widget> _moduleList(BuildContext context, List<ZagModule> modules) {
    return <Widget>[
      ..._sharedHeader(context),
      ...modules.map((module) {
        // Hide premium modules when the user is not Pro
        if ((module == ZagModule.DISCOVER ||
                module == ZagModule.OVERSEERR ||
                module == ZagModule.SERVER) &&
            !ZagreusPro.isEnabled) {
          return const SizedBox(height: 0.0);
        }
        
        if (module.isEnabled) {
          return _buildEntry(
            context: context,
            module: module,
            onTap: module == ZagModule.WAKE_ON_LAN ? _wakeOnLAN : null,
          );
        }
        return const SizedBox(height: 0.0);
      }),
    ];
  }

  Widget _buildEntry({
    required BuildContext context,
    required ZagModule module,
    void Function()? onTap,
  }) {
    bool currentPage = page == module.key.toLowerCase();
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
              if (!currentPage) module.launch();
            },
      ),
    );
  }

  Future<void> _wakeOnLAN() async => ZagWakeOnLAN().wake();
}
