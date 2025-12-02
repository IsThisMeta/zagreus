import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/settings.dart';
import 'package:zagreus/router/routes/settings.dart';
import 'package:zagreus/system/quick_actions/quick_actions.dart';
import 'package:zagreus/utils/profile_tools.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/modules.dart';
import 'package:zagreus/utils/zagreus_pro.dart';
import 'package:zagreus/services/revenuecat_service.dart';

class ConfigurationRoute extends StatefulWidget {
  const ConfigurationRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<ConfigurationRoute> createState() => _State();
}

class _State extends State<ConfigurationRoute> with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
      title: 'settings.Configuration'.tr(),
      scrollControllers: [scrollController],
      actions: [_enabledProfile()],
    );
  }

  Widget _enabledProfile() {
    return ZagBox.profiles.listenableBuilder(
      builder: (context, _) {
        if (ZagBox.profiles.size < 2) return const SizedBox();
        return ZagIconButton(
          icon: Icons.switch_account_rounded,
          onPressed: () async {
            final dialogs = SettingsDialogs();
            final enabledProfile = ZagreusDatabase.ENABLED_PROFILE.read();
            final profiles = ZagProfile.list;
            profiles.removeWhere((p) => p == enabledProfile);

            if (profiles.isEmpty) {
              showZagInfoSnackBar(
                title: 'settings.NoProfilesFound'.tr(),
                message: 'settings.NoAdditionalProfilesAdded'.tr(),
              );
              return;
            }

            final selected = await dialogs.enabledProfile(
              ZagState.context,
              profiles,
            );
            if (selected.item1) {
              ZagProfileTools().changeTo(selected.item2);
            }
          },
        );
      },
    );
  }

  Widget _body() {
    return ZagListView(
      controller: scrollController,
      children: [
        ZagBlock(
          title: 'settings.General'.tr(),
          body: [TextSpan(text: 'settings.GeneralDescription'.tr())],
          trailing: const ZagIconButton(icon: Icons.app_settings_alt_rounded),
          onTap: SettingsRoutes.CONFIGURATION_GENERAL.go,
        ),
        ZagBlock(
          title: 'settings.Appearance'.tr(),
          body: const [
            TextSpan(text: 'Adjust theme and color preferences'),
          ],
          trailing: const ZagIconButton(icon: Icons.palette_rounded),
          onTap: SettingsRoutes.CONFIGURATION_APPEARANCE.go,
        ),
        ZagBlock(
          title: 'Navigation',
          body: const [
            TextSpan(text: 'Configure navigation settings'),
          ],
          trailing: const ZagIconButton(icon: Icons.navigation_rounded),
          onTap: SettingsRoutes.CONFIGURATION_NAVIGATION.go,
        ),
        ZagBlock(
          title: 'settings.Drawer'.tr(),
          body: [TextSpan(text: 'settings.DrawerDescription'.tr())],
          trailing: const ZagIconButton(icon: Icons.menu_rounded),
          onTap: SettingsRoutes.CONFIGURATION_DRAWER.go,
        ),
        if (ZagQuickActions.isSupported)
          ZagBlock(
            title: 'settings.QuickActions'.tr(),
            body: [TextSpan(text: 'settings.QuickActionsDescription'.tr())],
            trailing: const ZagIconButton(icon: Icons.rounded_corner_rounded),
            onTap: SettingsRoutes.CONFIGURATION_QUICK_ACTIONS.go,
          ),
        ZagDivider(),
        ..._moduleList(),
        // ZagBlock(
        //   title: 'Z Agent',
        //   body: [const TextSpan(text: 'Configure Z Agent')],
        //   trailing: const ZagIconButton(icon: Icons.smart_toy),
        //   onTap: SettingsRoutes.Z_AGENT.go,
        // ),
      ],
    );
  }

  List<Widget> _moduleList() {
    final bool isPro = ZagreusPro.isEnabled;
    final modules = [ZagModule.DASHBOARD, ...ZagModule.active]
        .where((module) => module.settingsRoute != null)
        .toList();

    // Remove Pro-locked modules if user doesn't have Pro
    if (!isPro) {
      modules.removeWhere(
        (module) =>
            module == ZagModule.DISCOVER ||
            module == ZagModule.OVERSEERR ||
            module == ZagModule.UNRAID,
      );
    }

    // Remove Discover module (redundant - settings moved elsewhere)
    modules.removeWhere(
      (module) => module == ZagModule.DISCOVER,
    );

    modules.sort(
      (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
    );

    return modules.map(_tileFromModuleMap).toList();
  }

  Widget _tileFromModuleMap(ZagModule module) {
    return ZagBlock(
      title: module.title,
      body: [
        TextSpan(
          text: 'settings.ConfigureModule'.tr(args: [module.title])
        )
      ],
      trailing: ZagIconButton(
        icon: module.icon,
      ),
      onTap: module.settingsRoute!.go,
    );
  }
  
  void _showProPurchaseDialog(BuildContext context) {
    ZagDialog.dialog(
      context: context,
      title: 'Zagreus Pro',
      customContent: ZagDialog.content(
        children: [
          Padding(
            padding: ZagDialog.textDialogContentPadding(),
            child: Text(
              'Zagreus Pro unlocks Dashboard with limited Ask Z access.\n\n'
              '• Beautiful movie & TV discovery\n'
              '• Trending & popular content\n'
              '• Recommended based on your library\n'
              '• Missing movies from collections\n\n'
              'Choose a plan:',
              style: const TextStyle(
                fontSize: ZagUI.FONT_SIZE_H2,
              ),
            ),
          ),
          ZagDialog.tile(
            icon: Icons.calendar_month_rounded,
            iconColor: ZagColours.currentAccent,
            text: 'Monthly • \$0.99/month',
            onTap: () {
              Navigator.of(context).pop();
              _mockPurchase(true);
            },
          ),
          ZagDialog.tile(
            icon: Icons.star_rounded,
            iconColor: ZagColours.currentAccent,
            text: 'Yearly • \$4.99/year',
            onTap: () {
              Navigator.of(context).pop();
              _mockPurchase(false);
            },
          ),
        ],
      ),
      contentPadding: ZagDialog.listDialogContentPadding(),
    );
  }
  
  void _mockPurchase(bool isMonthly) async {
    final iapService = RevenueCatService();

    // Check if IAP is available
    if (!iapService.isAvailable) {
      // Disabled debug fallback - was causing Pro to auto-enable
      // if (const bool.fromEnvironment('dart.vm.product') == false) {
      //   ZagreusPro.enablePro(isMonthly: isMonthly);
      //   setState(() {});
      //   showZagInfoSnackBar(
      //     title: '[DEBUG] Welcome to Zagreus Pro!',
      //     message: 'Discover module is now unlocked (Test Mode)',
      //   );
      // } else {
      showZagInfoSnackBar(
        title: 'Unavailable',
        message: 'In-app purchases are not available',
      );
      // }
      return;
    }
    
    // Attempt real purchase
    showZagInfoSnackBar(
      title: 'Processing',
      message: 'Connecting to App Store...',
    );
    
    final bool success = isMonthly 
      ? await iapService.purchaseMonthly()
      : await iapService.purchaseYearly();
    
    if (success) {
      setState(() {});
    }
  }
}
