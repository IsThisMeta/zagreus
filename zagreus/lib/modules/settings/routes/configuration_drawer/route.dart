import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';

class ConfigurationDrawerRoute extends StatefulWidget {
  const ConfigurationDrawerRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<ConfigurationDrawerRoute> createState() => _State();
}

class _State extends State<ConfigurationDrawerRoute>
    with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<ZagModule>? _modules;

  @override
  void initState() {
    super.initState();
    _modules = ZagDrawer.moduleOrderedList();
  }

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
      scrollControllers: [scrollController],
      title: 'settings.Drawer'.tr(),
    );
  }

  Widget _body() {
    return Column(
      children: [
        SizedBox(height: ZagUI.MARGIN_H_DEFAULT_V_HALF.bottom),
        ZagBlock(
          title: 'settings.AutomaticallyManageOrder'.tr(),
          body: [
            TextSpan(text: 'settings.AutomaticallyManageOrderDescription'.tr()),
          ],
          trailing: ZagreusDatabase.DRAWER_AUTOMATIC_MANAGE.listenableBuilder(
            builder: (context, _) => ZagSwitch(
              value: ZagreusDatabase.DRAWER_AUTOMATIC_MANAGE.read(),
              onChanged: ZagreusDatabase.DRAWER_AUTOMATIC_MANAGE.update,
            ),
          ),
        ),
        ZagDivider(),
        Expanded(
          child: ZagReorderableListViewBuilder(
            padding: MediaQuery.of(context).padding.copyWith(top: 0).add(
                EdgeInsets.only(bottom: ZagUI.MARGIN_H_DEFAULT_V_HALF.bottom)),
            controller: scrollController,
            itemCount: _modules!.length,
            itemBuilder: (context, index) => _reorderableModuleTile(index),
            onReorder: (oIndex, nIndex) {
              if (oIndex > _modules!.length) oIndex = _modules!.length;
              if (oIndex < nIndex) nIndex--;
              ZagModule module = _modules![oIndex];
              _modules!.remove(module);
              _modules!.insert(nIndex, module);
              ZagreusDatabase.DRAWER_MANUAL_ORDER.update(_modules!);
              // Clear cache so next read gets fresh data
              ZagDrawer.clearModuleOrderCache();
            },
          ),
        ),
      ],
    );
  }

  Widget _reorderableModuleTile(int index) {
    return ZagreusDatabase.DRAWER_AUTOMATIC_MANAGE.listenableBuilder(
      key: ObjectKey(_modules![index]),
      builder: (context, _) => ZagBlock(
        disabled: ZagreusDatabase.DRAWER_AUTOMATIC_MANAGE.read(),
        title: _modules![index].title,
        body: [TextSpan(text: _modules![index].description)],
        leading: ZagIconButton(icon: _modules![index].icon),
        trailing: ZagreusDatabase.DRAWER_AUTOMATIC_MANAGE.read()
            ? null
            : ZagReorderableListViewDragger(index: index),
      ),
    );
  }
}
