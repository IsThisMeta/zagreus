import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/box.dart';
import 'package:zagreus/database/models/ssh_connection.dart';
import 'package:zagreus/modules.dart';
import 'package:zagreus/modules/ssh/core/state.dart';
import 'package:zagreus/router/routes/settings.dart';

class ConfigurationSSHRoute extends StatefulWidget {
  const ConfigurationSSHRoute({Key? key}) : super(key: key);

  @override
  State<ConfigurationSSHRoute> createState() => _State();
}

class _State extends State<ConfigurationSSHRoute> with ZagScrollControllerMixin {
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
      title: ZagModule.SSH.title,
      scrollControllers: [scrollController],
    );
  }

  Widget _body() {
    return ZagBox.sshConnections.listenableBuilder(
      builder: (context, _) {
        final connections = context.watch<SSHState>().connections;

        return ZagListView(
          controller: scrollController,
          children: [
            ZagModule.SSH.informationBanner(),
            _enabledToggle(),
            ZagDivider(),
            ZagHeader(text: 'ssh.Connections'.tr()),
            ...connections.map((connection) => _connectionTile(connection)),
            _addConnectionButton(),
          ],
        );
      },
    );
  }

  Widget _enabledToggle() {
    return ZagBox.profiles.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: 'settings.EnableModule'.tr(args: [ZagModule.SSH.title]),
        trailing: ZagSwitch(
          value: ZagProfile.current.sshEnabled,
          onChanged: (value) {
            ZagProfile.current.sshEnabled = value;
            ZagProfile.current.save();
            context.read<SSHState>().reset();
          },
        ),
      ),
    );
  }

  Widget _connectionTile(SSHConnection connection) {
    return ZagBlock(
      title: connection.name,
      body: [
        TextSpan(
          text: '${connection.username}@${connection.host}:${connection.port}',
        ),
      ],
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ZagIconButton(
            icon: Icons.edit_rounded,
            onPressed: () => _editConnection(connection),
          ),
          ZagIconButton(
            icon: Icons.delete_rounded,
            onPressed: () => _deleteConnection(connection),
          ),
        ],
      ),
    );
  }

  Widget _addConnectionButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ZagButton.text(
        text: 'ssh.AddConnection'.tr(),
        icon: Icons.add_rounded,
        onTap: () => SettingsRoutes.CONFIGURATION_SSH_ADD_CONNECTION.go(),
      ),
    );
  }

  void _editConnection(SSHConnection connection) {
    SettingsRoutes.CONFIGURATION_SSH_EDIT_CONNECTION.go(
      params: {'connectionId': connection.id},
    );
  }

  Future<void> _deleteConnection(SSHConnection connection) async {
    bool confirmed = false;

    await ZagDialog.dialog(
      context: context,
      title: 'ssh.DeleteConnection'.tr(),
      buttons: [
        ZagDialog.button(
          text: 'ssh.Delete'.tr(),
          textColor: ZagColours.red,
          onPressed: () {
            confirmed = true;
            Navigator.of(context, rootNavigator: true).pop();
          },
        ),
      ],
      content: [
        ZagDialog.textContent(
          text: 'ssh.DeleteConnectionConfirm'.tr(args: [connection.name]),
        ),
      ],
      contentPadding: ZagDialog.textDialogContentPadding(),
    );

    if (confirmed) {
      await context.read<SSHState>().deleteConnection(connection.id);
      if (mounted) {
        showZagSuccessSnackBar(
          title: 'ssh.ConnectionDeleted'.tr(),
          message: null,
        );
      }
    }
  }
}
