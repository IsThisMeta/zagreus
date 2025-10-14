import 'package:flutter/material.dart';

import 'package:zagreus/core.dart';
import 'package:zagreus/router/routes/settings.dart';
import 'package:zagreus/supabase/messaging.dart';
import 'package:zagreus/utils/zagreus_pro.dart';
import 'package:zagreus/utils/zagreus_mega.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/database/tables/bios.dart';
import 'package:zagreus/modules.dart';

class SettingsRoute extends StatefulWidget {
  const SettingsRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<SettingsRoute> createState() => _State();
}

class _State extends State<SettingsRoute> with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _checkAndSetProBootModule();
  }

  void _checkAndSetProBootModule() {
    // When Pro is activated, automatically set boot module to Discover
    final isPro = ZagreusPro.isEnabled;
    if (isPro) {
      final currentModule = BIOSDatabase.BOOT_MODULE.read();
      // Only set to Discover if it's the first Pro activation
      if (currentModule != ZagModule.DISCOVER &&
          ZagreusDatabase.USER_BOOT_MODULE.read().isEmpty) {
        // Save current module as user preference
        ZagreusDatabase.USER_BOOT_MODULE.update(currentModule.key);
        // Set to Discover
        BIOSDatabase.BOOT_MODULE.update(ZagModule.DISCOVER);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar(),
      drawer: _drawer(),
      body: _body(),
    );
  }

  Widget _drawer() => ZagDrawer(page: ZagModule.SETTINGS.key);

  PreferredSizeWidget _appBar() {
    return ZagAppBar(
      useDrawer: true,
      scrollControllers: [scrollController],
      title: ZagModule.SETTINGS.title,
    );
  }

  Widget _body() {
    return ZagListView(
      controller: scrollController,
      children: [
        ZagBlock(
          title: 'settings.Account'.tr(),
          body: [TextSpan(text: 'settings.AccountDescription'.tr())],
          trailing: const ZagIconButton(icon: Icons.account_circle_rounded),
          onTap: SettingsRoutes.ACCOUNT.go,
        ),
        ZagBlock(
          title: 'settings.Configuration'.tr(),
          body: [TextSpan(text: 'settings.ConfigurationDescription'.tr())],
          trailing: const ZagIconButton(icon: Icons.device_hub_rounded),
          onTap: SettingsRoutes.CONFIGURATION.go,
        ),
        if (ZagSupabaseMessaging.isSupported)
          ZagBlock(
            title: 'settings.Notifications'.tr(),
            body: [TextSpan(text: 'settings.NotificationsDescription'.tr())],
            trailing: const ZagIconButton(icon: Icons.notifications_rounded),
            onTap: SettingsRoutes.NOTIFICATIONS.go,
          ),
        ZagBlock(
          title: 'settings.Profiles'.tr(),
          body: [TextSpan(text: 'settings.ProfilesDescription'.tr())],
          trailing: const ZagIconButton(icon: Icons.switch_account_rounded),
          onTap: SettingsRoutes.PROFILES.go,
        ),
        ZagDivider(),
        ZagBlock(
          title: 'settings.Resources'.tr(),
          body: [TextSpan(text: 'settings.ResourcesDescription'.tr())],
          trailing: const ZagIconButton(icon: Icons.help_outline_rounded),
          onTap: SettingsRoutes.RESOURCES.go,
        ),
        ZagBlock(
          title: 'settings.System'.tr(),
          body: [TextSpan(text: 'settings.SystemDescription'.tr())],
          trailing: const ZagIconButton(icon: Icons.settings_rounded),
          onTap: SettingsRoutes.SYSTEM.go,
        ),
        ZagDivider(),
        _buildSubscriptionsButton(),
        _buildBootModuleToggle(),
      ],
    );
  }

  Widget _buildBootModuleToggle() {
    final bool isPro = ZagreusPro.isEnabled;

    // Show if user has Pro
    if (!isPro) return const SizedBox.shrink();

    return BIOSDatabase.BOOT_MODULE.listenableBuilder(builder: (context, _) {
      final currentModule = BIOSDatabase.BOOT_MODULE.read();
      final isDiscoverMode = currentModule == ZagModule.DISCOVER;
      final userModule = _getUserBootModule();

      return ZagBlock(
        title: 'Start with Discover',
        body: [
          TextSpan(
              text: isDiscoverMode
                  ? 'Opens Discover on launch'
                  : 'Opens ${userModule.title} on launch')
        ],
        trailing: ZagSwitch(
          value: isDiscoverMode,
          onChanged: (value) {
            if (value) {
              // Save current module as user preference if not already Discover
              if (currentModule != ZagModule.DISCOVER) {
                ZagreusDatabase.USER_BOOT_MODULE.update(currentModule.key);
              }
              // Set to Discover
              BIOSDatabase.BOOT_MODULE.update(ZagModule.DISCOVER);
            } else {
              // Restore user's previous module
              final userModuleKey = ZagreusDatabase.USER_BOOT_MODULE.read();
              final userModule =
                  ZagModule.fromKey(userModuleKey) ?? ZagModule.DASHBOARD;
              BIOSDatabase.BOOT_MODULE.update(userModule);
            }
          },
        ),
      );
    });
  }

  ZagModule _getUserBootModule() {
    final userModuleKey = ZagreusDatabase.USER_BOOT_MODULE.read();
    return ZagModule.fromKey(userModuleKey) ?? ZagModule.DASHBOARD;
  }

  Widget _buildSubscriptionsButton() {
    final bool isPro = ZagreusPro.isEnabled;
    final bool isMega = ZagreusMega.isEnabled;

    // Determine display text and icon
    String displayText;
    IconData displayIcon;
    Color displayColor;

    if (isMega) {
      displayText = 'Zagreus Mega Active';
      displayIcon = Icons.star_rounded;
      displayColor = ZagColours.purple;
    } else if (isPro) {
      displayText = 'Zagreus Pro Active';
      displayIcon = Icons.star_rounded;
      displayColor = ZagColours.orange;
    } else {
      displayText = 'Manage subscriptions';
      displayIcon = Icons.shopping_bag_outlined;
      displayColor = ZagColours.currentAccent;
    }

    return ZagBlock(
      title: 'Subscriptions',
      body: [
        TextSpan(text: displayText)
      ],
      trailing: ZagIconButton(
        icon: displayIcon,
        color: displayColor,
      ),
      onTap: SettingsRoutes.SUBSCRIPTIONS.go,
    );
  }
}
