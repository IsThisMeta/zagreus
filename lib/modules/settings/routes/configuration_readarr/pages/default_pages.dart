import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/readarr.dart';

class ConfigurationReadarrDefaultPagesRoute extends StatefulWidget {
  const ConfigurationReadarrDefaultPagesRoute({
    super.key,
  });

  @override
  State<ConfigurationReadarrDefaultPagesRoute> createState() => _State();
}

class _State extends State<ConfigurationReadarrDefaultPagesRoute>
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
        _homePage(),
      ],
    );
  }

  Widget _homePage() {
    const _db = ReadarrDatabase.NAVIGATION_INDEX;
    return _db.listenableBuilder(
      builder: (context, _) {
        final index = _db.read().clamp(0, ReadarrNavigationBar.icons.length - 1);
        return ZagBlock(
          title: 'zagreus.Home'.tr(),
          body: [TextSpan(text: ReadarrNavigationBar.titles[index])],
          trailing: ZagIconButton(
            icon: ReadarrNavigationBar.icons[index],
          ),
          onTap: () async {
            final values = await ReadarrDialogs.defaultPage(context);
            if (values[0]) _db.update(values[1]);
          },
        );
      },
    );
  }
}
