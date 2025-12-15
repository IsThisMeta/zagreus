import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';

class NotEnabledPage extends StatelessWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final String module;

  NotEnabledPage({
    Key? key,
    required this.module,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      drawer: ZagDrawer(page: module),
      appBar: ZagAppBar(
        title: module,
        useDrawer: true,
      ),
      body: ZagMessage.moduleNotEnabled(
        context: context,
        module: module,
      ),
    );
  }
}
