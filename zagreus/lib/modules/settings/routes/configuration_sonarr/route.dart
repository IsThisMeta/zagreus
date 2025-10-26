import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/router/routes/settings.dart';
import 'package:zagreus/supabase/core.dart';
import 'package:zagreus/api/sonarr/sonarr.dart';
import 'package:zagreus/modules/sonarr/core/webhook_manager.dart';

class ConfigurationSonarrRoute extends StatefulWidget {
  const ConfigurationSonarrRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<ConfigurationSonarrRoute> createState() => _State();
}

class _State extends State<ConfigurationSonarrRoute>
    with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Sync webhook when page loads
    _syncWebhook();
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
      title: ZagModule.SONARR.title,
      scrollControllers: [scrollController],
    );
  }

  Widget _body() {
    return ZagListView(
      controller: scrollController,
      children: [
        ZagModule.SONARR.informationBanner(),
        _enabledToggle(),
        _connectionDetailsPage(),
        ZagDivider(),
        _defaultOptionsPage(),
        _defaultPagesPage(),
        _queueSize(),
      ],
    );
  }

  Widget _enabledToggle() {
    return ZagBox.profiles.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: 'settings.EnableModule'.tr(args: [ZagModule.SONARR.title]),
        trailing: ZagSwitch(
          value: ZagProfile.current.sonarrEnabled,
          onChanged: (value) {
            ZagProfile.current.sonarrEnabled = value;
            ZagProfile.current.save();
            context.read<SonarrState>().reset();
          },
        ),
      ),
    );
  }

  Widget _connectionDetailsPage() {
    return ZagBlock(
      title: 'settings.ConnectionDetails'.tr(),
      body: [
        TextSpan(
          text: 'settings.ConnectionDetailsDescription'.tr(
            args: [ZagModule.SONARR.title],
          ),
        )
      ],
      trailing: const ZagIconButton.arrow(),
      onTap: SettingsRoutes.CONFIGURATION_SONARR_CONNECTION_DETAILS.go,
    );
  }

  Widget _defaultPagesPage() {
    return ZagBlock(
      title: 'settings.DefaultPages'.tr(),
      body: [TextSpan(text: 'settings.DefaultPagesDescription'.tr())],
      trailing: const ZagIconButton.arrow(),
      onTap: SettingsRoutes.CONFIGURATION_SONARR_DEFAULT_PAGES.go,
    );
  }

  Widget _defaultOptionsPage() {
    return ZagBlock(
      title: 'settings.DefaultOptions'.tr(),
      body: [
        TextSpan(text: 'settings.DefaultOptionsDescription'.tr()),
      ],
      trailing: const ZagIconButton.arrow(),
      onTap: SettingsRoutes.CONFIGURATION_SONARR_DEFAULT_OPTIONS.go,
    );
  }

  Widget _queueSize() {
    const _db = SonarrDatabase.QUEUE_PAGE_SIZE;
    return _db.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: 'sonarr.QueueSize'.tr(),
        body: [
          TextSpan(
            text: _db.read() == 1
                ? 'zagreus.OneItem'.tr()
                : 'zagreus.Items'.tr(args: [_db.read().toString()]),
          ),
        ],
        trailing: const ZagIconButton(icon: Icons.queue_play_next_rounded),
        onTap: () async {
          Tuple2<bool, int> result =
              await SonarrDialogs().setQueuePageSize(context);
          if (result.item1) _db.update(result.item2);
        },
      ),
    );
  }

  void _syncWebhook() async {
    try {
      // Only sync if user is authenticated
      if (ZagSupabase.isSupported &&
          ZagSupabase.client.auth.currentUser != null) {
        final profile = ZagProfile.current;

        final effectiveHost = profile.effectiveSonarrHost();
        if (profile.sonarrEnabled &&
            effectiveHost.isNotEmpty &&
            profile.sonarrKey.isNotEmpty) {
          final api = SonarrAPI(
            host: effectiveHost,
            apiKey: profile.sonarrKey,
            headers: Map<String, dynamic>.from(profile.sonarrHeaders),
          );

          await SonarrWebhookManager.syncWebhook(api);
        }
      }
    } catch (e, stack) {
      ZagLogger().error('Failed to sync webhook on page load', e, stack);
    }
  }
}
