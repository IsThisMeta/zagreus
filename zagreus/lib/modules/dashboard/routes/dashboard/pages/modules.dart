import 'package:flutter/material.dart';

import 'package:zagreus/modules.dart';
import 'package:zagreus/database/models/profile.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/vendor.dart';
import 'package:zagreus/widgets/ui.dart';
import 'package:zagreus/api/wake_on_lan/wake_on_lan.dart';
import 'package:zagreus/modules/dashboard/routes/dashboard/widgets/navigation_bar.dart';
import 'package:zagreus/utils/zagreus_pro.dart';
import 'package:zagreus/services/settings_lock_service.dart';
import 'package:zagreus/system/network/local_switching_service.dart';

class ModulesPage extends StatefulWidget {
  final ScrollController? controller;
  const ModulesPage({
    Key? key,
    this.controller,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<ModulesPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _list();
  }

  Widget _list() {
    if (!(ZagProfile.current.isAnythingEnabled())) {
      return ZagMessage(
        text: 'zagreus.NoModulesEnabled'.tr(),
        buttonText: 'zagreus.GoToSettings'.tr(),
        onTap: () => ZagModule.SETTINGS.launch(restore: false),
      );
    }

    // Listen to SSID changes to update "• Local" indicators
    return ValueListenableBuilder<String?>(
      valueListenable: ZagLocalConnectionService().currentSsid,
      builder: (context, ssid, child) {
        return ZagListView(
          controller: widget.controller ?? HomeNavigationBar.scrollControllers[0],
          itemExtent: ZagBlock.calculateItemExtent(1),
          children: ZagreusDatabase.DRAWER_AUTOMATIC_MANAGE.read()
              ? _buildAlphabeticalList()
              : _buildManuallyOrderedList(),
        );
      },
    );
  }

  List<Widget> _buildAlphabeticalList() {
    List<Widget> modules = [];
    int index = 0;
    ZagModule.active
      ..sort((a, b) => a.title.toLowerCase().compareTo(
            b.title.toLowerCase(),
          ))
      ..forEach((module) {
        // Skip premium modules if not Pro
        if (_requiresPro(module) && !ZagreusPro.isEnabled) {
          return;
        }

        // Skip Discover module for premium users (redundant - they're already in it)
        if (module == ZagModule.DISCOVER && ZagreusPro.isEnabled) {
          return;
        }

        if (module.isEnabled) {
          if (module == ZagModule.WAKE_ON_LAN) {
            modules.add(_buildWakeOnLAN(context, index));
          } else {
            modules.add(_buildFromZagModule(context, module, index));
          }
          index++;
        }
      });
    modules.add(_buildFromZagModule(context, ZagModule.SETTINGS, index));
    return modules;
  }

  List<Widget> _buildManuallyOrderedList() {
    List<Widget> modules = [];
    int index = 0;
    ZagDrawer.moduleOrderedList().forEach((module) {
      // Skip premium modules if not Pro
      if (_requiresPro(module) && !ZagreusPro.isEnabled) {
        return;
      }

      // Skip Discover module for premium users (redundant - they're already in it)
      if (module == ZagModule.DISCOVER && ZagreusPro.isEnabled) {
        return;
      }

      if (module.isEnabled) {
        if (module == ZagModule.WAKE_ON_LAN) {
          modules.add(_buildWakeOnLAN(context, index));
        } else {
          modules.add(_buildFromZagModule(context, module, index));
        }
        index++;
      }
    });
    modules.add(_buildFromZagModule(context, ZagModule.SETTINGS, index));
    return modules;
  }

  Widget _buildFromZagModule(BuildContext context, ZagModule module, int listIndex) {
    VoidCallback? onTap;
    if (module == ZagModule.SETTINGS) {
      onTap = () {
        SettingsLockService.instance.ensureUnlocked(context).then((unlocked) {
          if (unlocked) module.launch(restore: false);
        });
      };
    } else {
      onTap = () {
        module.launch(restore: false);
      };
    }

    // Build description with "• Local" suffix if module is using local endpoint
    final isUsingLocal = ZagLocalConnectionService().isModuleUsingLocal(module);
    final description = isUsingLocal
        ? '${module.description} • Local'
        : module.description;

    return ZagBlock(
      title: module.title,
      body: [TextSpan(text: description)],
      trailing: ZagIconButton(icon: module.icon, color: module.color),
      onTap: onTap,
    );
  }

  Widget _buildWakeOnLAN(BuildContext context, int listIndex) {
    return ZagBlock(
      title: ZagModule.WAKE_ON_LAN.title,
      body: [TextSpan(text: ZagModule.WAKE_ON_LAN.description)],
      trailing: ZagIconButton(
        icon: ZagModule.WAKE_ON_LAN.icon,
        color: ZagModule.WAKE_ON_LAN.color,
      ),
      onTap: () async => ZagWakeOnLAN().wake(),
    );
  }

  bool _requiresPro(ZagModule module) =>
      module == ZagModule.DISCOVER ||
      module == ZagModule.OVERSEERR ||
      module == ZagModule.UNRAID;
}
