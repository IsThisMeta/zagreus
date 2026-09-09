import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/tables/qbit.dart';
import 'package:zagreus/modules/qbit/core/dialogs.dart';
import 'package:zagreus/modules/qbit/widgets/navigation_bar.dart';

class ConfigurationQBitDefaultPagesRoute extends StatefulWidget {
  const ConfigurationQBitDefaultPagesRoute({Key? key}) : super(key: key);

  @override
  State<ConfigurationQBitDefaultPagesRoute> createState() => _State();
}

class _State extends State<ConfigurationQBitDefaultPagesRoute>
    with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
    return QBitDatabase.NAVIGATION_INDEX.listenableBuilder(
      builder: (context, _) {
        final index = QBitDatabase.NAVIGATION_INDEX.read();
        return ZagBlock(
          title: 'settings.DefaultPage'.tr(),
          body: [
            TextSpan(text: QBitNavigationBar.titles[index]),
          ],
          trailing: const ZagIconButton.arrow(),
          onTap: () async {
            final values = await QBitDialogs.defaultPage(context);
            if (values[0]) {
              QBitDatabase.NAVIGATION_INDEX.update(values[1]);
            }
          },
        );
      },
    );
  }
}
