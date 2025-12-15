import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/external_modules/routes/external_modules/widgets/module_tile.dart';

class ExternalModulesRoute extends StatefulWidget {
  const ExternalModulesRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<ExternalModulesRoute> createState() => _State();
}

class _State extends State<ExternalModulesRoute>
    with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      module: ZagModule.EXTERNAL_MODULES,
      appBar: _appBar(),
      drawer: _drawer(),
      body: _body(),
    );
  }

  PreferredSizeWidget _appBar() {
    return ZagAppBar(
      useDrawer: true,
      title: ZagModule.EXTERNAL_MODULES.title,
      scrollControllers: [scrollController],
    );
  }

  Widget _drawer() => ZagDrawer(page: ZagModule.EXTERNAL_MODULES.key);

  Widget _body() {
    if (ZagBox.externalModules.isEmpty) {
      return ZagMessage.moduleNotEnabled(
        context: context,
        module: ZagModule.EXTERNAL_MODULES.title,
      );
    }
    return ZagListView(
      controller: scrollController,
      itemExtent: ZagBlock.calculateItemExtent(1),
      children: _list,
    );
  }

  List<Widget> get _list {
    final list = ZagBox.externalModules.data
        .map((module) => ExternalModulesModuleTile(module: module))
        .toList();
    list.sort((a, b) => a.module!.displayName
        .toLowerCase()
        .compareTo(b.module!.displayName.toLowerCase()));

    return list;
  }
}
