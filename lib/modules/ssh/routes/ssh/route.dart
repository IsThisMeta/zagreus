import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/box.dart';
import 'package:zagreus/database/models/ssh_connection.dart';
import 'package:zagreus/modules.dart';
import 'package:zagreus/modules/ssh/core/state.dart';
import 'package:zagreus/modules/ssh/routes/ssh/widgets/connection_card.dart';
import 'package:zagreus/router/routes/settings.dart';
import 'package:zagreus/router/routes/ssh.dart';

class SSHRoute extends StatefulWidget {
  const SSHRoute({Key? key}) : super(key: key);

  @override
  State<SSHRoute> createState() => _State();
}

class _State extends State<SSHRoute> with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ZagGlobalCubeManager.instance.injectCube(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      module: ZagModule.SSH,
      drawer: ZagDrawer(page: ZagModule.SSH.key),
      appBar: ZagAppBar(
        title: 'ssh.Connections'.tr(),
        useDrawer: true,
        scrollControllers: [scrollController],
      ),
      body: _body(),
    );
  }

  Widget _body() {
    return ZagBox.sshConnections.listenableBuilder(
      builder: (context, _) {
        final connections = context.watch<SSHState>().connections;

        if (connections.isEmpty) {
          return _emptyState();
        }

        return ZagListView(
          controller: scrollController,
          children: [
            ZagModule.SSH.informationBanner(),
            ...connections.map((connection) => SSHConnectionCard(
              connection: connection,
              onConnect: () => _connectToServer(connection),
            )),
          ],
        );
      },
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.terminal_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'ssh.NoConnections'.tr(),
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          ZagButton.text(
            text: 'ssh.AddConnection'.tr(),
            icon: Icons.add_rounded,
            onTap: () => SettingsRoutes.CONFIGURATION_SSH.go(),
          ),
        ],
      ),
    );
  }

  void _connectToServer(SSHConnection connection) {
    SSHRoutes.TERMINAL.go(
      params: {'connectionId': connection.id},
    );
  }
}
