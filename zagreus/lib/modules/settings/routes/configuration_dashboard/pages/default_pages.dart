import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/tables/dashboard.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/modules/dashboard/core/dialogs.dart';
import 'package:zagreus/modules/dashboard/routes/dashboard/widgets/navigation_bar.dart';
import 'package:zagreus/utils/zagreus_pro.dart';

class ConfigurationDashboardDefaultPagesRoute extends StatefulWidget {
  const ConfigurationDashboardDefaultPagesRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<ConfigurationDashboardDefaultPagesRoute> createState() => _State();
}

class _State extends State<ConfigurationDashboardDefaultPagesRoute>
    with ZagScrollControllerMixin {
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
      title: 'settings.DefaultPages'.tr(),
      scrollControllers: [scrollController],
    );
  }

  Widget _body() {
    return ZagListView(
      controller: scrollController,
      children: [
        _defaultPageTile(),
      ],
    );
  }

  Widget _defaultPageTile() {
    if (ZagreusPro.isEnabled) return _discoverDefaultTabTile();
    return _dashboardDefaultPageTile();
  }

  Widget _dashboardDefaultPageTile() {
    const _db = DashboardDatabase.NAVIGATION_INDEX;
    return _db.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: 'zagreus.Home'.tr(),
        body: [TextSpan(text: HomeNavigationBar.titles[_db.read()])],
        trailing: ZagIconButton(icon: HomeNavigationBar.icons[_db.read()]),
        onTap: () async {
          final values = await DashboardDialogs().defaultPage(context);
          if (values.item1) _db.update(values.item2);
        },
      ),
    );
  }

  Widget _discoverDefaultTabTile() {
    return ZagBox.zagreus.listenableBuilder(
      selectItems: const [
        ZagreusDatabase.DISCOVER_DEFAULT_TAB,
        ZagreusDatabase.SHOW_LEGACY_MODULES_TAB,
      ],
      builder: (context, _) {
        final options = _discoverTabOptions();
        final storedKey =
            ZagreusDatabase.DISCOVER_DEFAULT_TAB.read() ?? options.first.key;
        _DiscoverTabOption current =
            options.firstWhere((opt) => opt.key == storedKey,
                orElse: () => options.first);
        if (current.key != storedKey) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ZagreusDatabase.DISCOVER_DEFAULT_TAB.update(current.key);
          });
        }
        return ZagBlock(
          title: 'zagreus.Home'.tr(),
          body: [TextSpan(text: current.label)],
          trailing: ZagIconButton(icon: current.icon),
          onTap: () async {
            final selection = await _selectDiscoverDefaultTab(options);
            if (selection != null) {
              ZagreusDatabase.DISCOVER_DEFAULT_TAB.update(selection);
            }
          },
        );
      },
    );
  }

  Future<String?> _selectDiscoverDefaultTab(
    List<_DiscoverTabOption> options,
  ) async {
    String? selected;
    await ZagDialog.dialog(
      context: context,
      title: 'zagreus.Page'.tr(),
      contentPadding: ZagDialog.listDialogContentPadding(),
      content: [
        for (int index = 0; index < options.length; index++)
          ZagDialog.tile(
            text: options[index].label,
            icon: options[index].icon,
            iconColor: ZagColours().byListIndex(index),
            onTap: () {
              selected = options[index].key;
              Navigator.of(context, rootNavigator: true).pop();
            },
          ),
      ],
    );
    return selected;
  }

  List<_DiscoverTabOption> _discoverTabOptions() {
    final showModules = ZagreusDatabase.SHOW_LEGACY_MODULES_TAB.read();
    final options = <_DiscoverTabOption>[];
    if (showModules) {
      options.add(
        const _DiscoverTabOption(
          key: 'modules',
          label: 'Modules',
          icon: Icons.workspaces_rounded,
        ),
      );
    }
    options.addAll(const [
      _DiscoverTabOption(
        key: 'movies',
        label: 'Movies',
        icon: Icons.movie_rounded,
      ),
      _DiscoverTabOption(
        key: 'shows',
        label: 'Shows',
        icon: Icons.tv_rounded,
      ),
      _DiscoverTabOption(
        key: 'calendar',
        label: 'Calendar',
        icon: Icons.calendar_today_rounded,
      ),
      _DiscoverTabOption(
        key: 'server',
        label: 'Server',
        icon: Icons.dns_rounded,
      ),
    ]);
    return options;
  }
}

class _DiscoverTabOption {
  final String key;
  final String label;
  final IconData icon;

  const _DiscoverTabOption({
    required this.key,
    required this.label,
    required this.icon,
  });
}
