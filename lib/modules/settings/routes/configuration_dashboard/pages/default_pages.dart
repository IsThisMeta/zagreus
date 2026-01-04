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
      builder: (context, _) => ZagreusDatabase.DASHBOARD_SHOW_MODULES_TAB.listenableBuilder(
        builder: (context, _) => ZagreusDatabase.SHOW_CALENDAR_TAB.listenableBuilder(
          builder: (context, _) {
            final visibleTitles = HomeNavigationBar.getVisibleTitles();
            final visibleIcons = HomeNavigationBar.getVisibleIcons();

            if (visibleTitles.isEmpty) {
              return const SizedBox.shrink();
            }

            // Ensure the index is within bounds
            int index = _db.read();
            if (index >= visibleTitles.length) {
              index = 0;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _db.update(0);
              });
            }

            return ZagBlock(
              title: 'zagreus.Home'.tr(),
              body: [TextSpan(text: visibleTitles[index])],
              trailing: ZagIconButton(icon: visibleIcons[index]),
              onTap: () async {
                final values = await DashboardDialogs().defaultPage(context);
                if (values.item1) _db.update(values.item2);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _discoverDefaultTabTile() {
    return ZagBox.zagreus.listenableBuilder(
      selectItems: const [
        ZagreusDatabase.DISCOVER_DEFAULT_TAB,
        ZagreusDatabase.DISCOVER_SHOW_MODULES_TAB,
        ZagreusDatabase.SHOW_CALENDAR_TAB,
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
          body: [TextSpan(text: current.labelKey.tr())],
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
            text: options[index].labelKey.tr(),
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
    final showModules = ZagreusDatabase.DISCOVER_SHOW_MODULES_TAB.read();
    final showCalendar = ZagreusDatabase.SHOW_CALENDAR_TAB.read();
    final options = <_DiscoverTabOption>[];
    if (showModules) {
      options.add(
        const _DiscoverTabOption(
          key: 'modules',
          labelKey: 'settings.DashboardTabModules',
          icon: Icons.workspaces_rounded,
        ),
      );
    }
    options.addAll([
      const _DiscoverTabOption(
        key: 'movies',
        labelKey: 'settings.DashboardTabMovies',
        icon: Icons.movie_rounded,
      ),
      const _DiscoverTabOption(
        key: 'shows',
        labelKey: 'settings.DashboardTabShows',
        icon: Icons.tv_rounded,
      ),
      if (showCalendar)
        const _DiscoverTabOption(
          key: 'calendar',
          labelKey: 'settings.DashboardTabCalendar',
          icon: Icons.calendar_today_rounded,
        ),
      const _DiscoverTabOption(
        key: 'server',
        labelKey: 'settings.DashboardTabServer',
        icon: Icons.dns_rounded,
      ),
    ]);
    return options;
  }
}

class _DiscoverTabOption {
  final String key;
  final String labelKey;
  final IconData icon;

  const _DiscoverTabOption({
    required this.key,
    required this.labelKey,
    required this.icon,
  });
}
