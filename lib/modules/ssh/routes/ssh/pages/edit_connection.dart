import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/models/ssh_connection.dart';
import 'package:zagreus/modules/ssh/core/state.dart';
import 'package:zagreus/modules/ssh/core/ssh_service.dart';
import 'package:zagreus/router/router.dart';

class SSHEditConnectionRoute extends StatefulWidget {
  final String connectionId;

  const SSHEditConnectionRoute({
    Key? key,
    required this.connectionId,
  }) : super(key: key);

  @override
  State<SSHEditConnectionRoute> createState() => _State();
}

class _State extends State<SSHEditConnectionRoute> with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  SSHConnection? _connection;
  late String _name;
  late String _host;
  late int _port;
  late String _username;
  late SSHAuthType _authType;
  late String _password;
  late String _privateKey;
  late String _passphrase;
  late String _localHost;
  late String _localSsids;

  @override
  void initState() {
    super.initState();
    _loadConnection();
  }

  void _loadConnection() {
    final connection = context.read<SSHState>().getConnection(widget.connectionId);
    if (connection != null) {
      _connection = connection;
      _name = connection.name;
      _host = connection.host;
      _port = connection.port;
      _username = connection.username;
      _authType = connection.authType;
      _password = connection.password;
      _privateKey = connection.privateKey;
      _passphrase = connection.passphrase;
      _localHost = connection.localHost;
      _localSsids = connection.localSsids;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_connection == null) {
      return ZagScaffold(
        scaffoldKey: _scaffoldKey,
        appBar: ZagAppBar(title: 'ssh.EditConnection'.tr()),
        body: Center(child: Text('ssh.ConnectionNotFound'.tr())),
      );
    }

    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: ZagAppBar(
        title: 'ssh.EditConnection'.tr(),
        scrollControllers: [scrollController],
      ),
      body: ZagListView(
        controller: scrollController,
        children: [
          _nameField(),
          _hostField(),
          _portField(),
          _usernameField(),
          ZagDivider(),
          ZagHeader(text: 'ssh.AuthType'.tr()),
          _authTypeToggle(),
          if (_authType == SSHAuthType.password) _passwordField() else _privateKeyField(),
          if (_authType == SSHAuthType.privateKey) _passphraseField(),
          ZagDivider(),
          ZagHeader(text: 'ssh.LocalNetwork'.tr()),
          _localHostField(),
          _localSsidsField(),
          ZagDivider(),
          _hostKeyFingerprintField(),
        ],
      ),
      bottomNavigationBar: _bottomActionBar(),
    );
  }

  Widget _nameField() {
    return ZagBlock(
      title: 'ssh.ConnectionName'.tr(),
      body: [TextSpan(text: _name)],
      trailing: const ZagIconButton.arrow(),
      onTap: () async {
        final result = await ZagDialogs().editText(
          context,
          'ssh.ConnectionName'.tr(),
          prefill: _name,
        );
        if (result.item1) {
          setState(() => _name = result.item2);
        }
      },
    );
  }

  Widget _hostField() {
    return ZagBlock(
      title: 'ssh.Host'.tr(),
      body: [TextSpan(text: _host)],
      trailing: const ZagIconButton.arrow(),
      onTap: () async {
        final result = await ZagDialogs().editText(
          context,
          'ssh.Host'.tr(),
          prefill: _host,
        );
        if (result.item1) {
          setState(() => _host = result.item2);
        }
      },
    );
  }

  Widget _portField() {
    return ZagBlock(
      title: 'ssh.Port'.tr(),
      body: [TextSpan(text: _port.toString())],
      trailing: const ZagIconButton.arrow(),
      onTap: () async {
        final result = await ZagDialogs().editText(
          context,
          'ssh.Port'.tr(),
          prefill: _port.toString(),
        );
        if (result.item1) {
          final port = int.tryParse(result.item2);
          if (port != null && port >= 1 && port <= 65535) {
            setState(() => _port = port);
          }
        }
      },
    );
  }

  Widget _usernameField() {
    return ZagBlock(
      title: 'ssh.Username'.tr(),
      body: [TextSpan(text: _username)],
      trailing: const ZagIconButton.arrow(),
      onTap: () async {
        final result = await ZagDialogs().editText(
          context,
          'ssh.Username'.tr(),
          prefill: _username,
        );
        if (result.item1) {
          setState(() => _username = result.item2);
        }
      },
    );
  }

  Widget _authTypeToggle() {
    return ZagBlock(
      title: 'ssh.AuthPassword'.tr(),
      body: [TextSpan(text: 'ssh.AuthPasswordDescription'.tr())],
      trailing: ZagSwitch(
        value: _authType == SSHAuthType.password,
        onChanged: (value) {
          setState(() {
            _authType = value ? SSHAuthType.password : SSHAuthType.privateKey;
          });
        },
      ),
    );
  }

  Widget _passwordField() {
    return ZagBlock(
      title: 'ssh.Password'.tr(),
      body: [TextSpan(text: _password.isEmpty ? 'zagreus.NotSet'.tr() : ZagUI.TEXT_OBFUSCATED_PASSWORD)],
      trailing: const ZagIconButton.arrow(),
      onTap: () async {
        final result = await ZagDialogs().editText(
          context,
          'ssh.Password'.tr(),
          prefill: _password,
        );
        if (result.item1) {
          setState(() => _password = result.item2);
        }
      },
    );
  }

  Widget _privateKeyField() {
    return ZagBlock(
      title: 'ssh.PrivateKey'.tr(),
      body: [TextSpan(text: _privateKey.isEmpty ? 'zagreus.NotSet'.tr() : 'ssh.PrivateKeySet'.tr())],
      trailing: const ZagIconButton.arrow(),
      onTap: () async {
        final result = await ZagDialogs().editText(
          context,
          'ssh.PrivateKey'.tr(),
          prefill: _privateKey,
        );
        if (result.item1) {
          setState(() => _privateKey = result.item2);
        }
      },
    );
  }

  Widget _passphraseField() {
    return ZagBlock(
      title: 'ssh.Passphrase'.tr(),
      body: [TextSpan(text: _passphrase.isEmpty ? 'zagreus.NotSet'.tr() : ZagUI.TEXT_OBFUSCATED_PASSWORD)],
      trailing: const ZagIconButton.arrow(),
      onTap: () async {
        final result = await ZagDialogs().editText(
          context,
          'ssh.Passphrase'.tr(),
          prefill: _passphrase,
        );
        if (result.item1) {
          setState(() => _passphrase = result.item2);
        }
      },
    );
  }

  Widget _localHostField() {
    return ZagBlock(
      title: 'ssh.LocalHost'.tr(),
      body: [TextSpan(text: _localHost.isEmpty ? 'zagreus.NotSet'.tr() : _localHost)],
      trailing: const ZagIconButton.arrow(),
      onTap: () async {
        final result = await ZagDialogs().editText(
          context,
          'ssh.LocalHost'.tr(),
          prefill: _localHost,
        );
        if (result.item1) {
          setState(() => _localHost = result.item2);
        }
      },
    );
  }

  Widget _localSsidsField() {
    return ZagBlock(
      title: 'ssh.LocalSsids'.tr(),
      body: [TextSpan(text: _localSsids.isEmpty ? 'zagreus.NotSet'.tr() : _localSsids)],
      trailing: const ZagIconButton.arrow(),
      onTap: () async {
        final result = await ZagDialogs().editText(
          context,
          'ssh.LocalSsids'.tr(),
          prefill: _localSsids,
        );
        if (result.item1) {
          setState(() => _localSsids = result.item2);
        }
      },
    );
  }

  Widget _hostKeyFingerprintField() {
    final value = _connection?.hostKeyFingerprint ?? '';
    final display = value.isEmpty ? 'zagreus.NotSet'.tr() : _formatFingerprint(value);

    return ZagBlock(
      title: 'ssh.HostKeyFingerprint'.tr(),
      body: [TextSpan(text: display)],
      trailing: value.isEmpty ? null : const ZagIconButton.arrow(),
      onTap: value.isEmpty ? null : _resetHostKeyFingerprint,
    );
  }

  String _formatFingerprint(String value) {
    final normalized = SSHService.normalizeFingerprint(value);
    final buffer = StringBuffer();
    for (var i = 0; i < normalized.length; i += 2) {
      if (i > 0) buffer.write(':');
      buffer.write(normalized.substring(i, i + 2));
    }
    return buffer.toString();
  }

  Future<void> _resetHostKeyFingerprint() async {
    bool confirmed = false;

    await ZagDialog.dialog(
      context: context,
      title: 'ssh.HostKeyResetTitle'.tr(),
      buttons: [
        ZagDialog.button(
          text: 'ssh.Clear'.tr(),
          textColor: ZagColours.red,
          onPressed: () {
            confirmed = true;
            Navigator.of(context, rootNavigator: true).pop();
          },
        ),
      ],
      content: [
        ZagDialog.textContent(text: 'ssh.HostKeyResetConfirm'.tr()),
      ],
      contentPadding: ZagDialog.textDialogContentPadding(),
    );

    if (!confirmed) return;

    setState(() {
      _connection = _connection?.copyWith(hostKeyFingerprint: '', hostKeyType: '');
    });
  }

  Widget _bottomActionBar() {
    return ZagBottomActionBar(
      actions: [
        ZagButton.text(
          text: 'ssh.Delete'.tr(),
          icon: Icons.delete_rounded,
          onTap: _delete,
        ),
        ZagButton.text(
          text: 'ssh.Save'.tr(),
          icon: Icons.save_rounded,
          onTap: _save,
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (_name.isEmpty || _host.isEmpty || _username.isEmpty) {
      showZagErrorSnackBar(
        title: 'ssh.Error'.tr(),
        message: 'ssh.FillAllFields'.tr(),
      );
      return;
    }

    if (_authType == SSHAuthType.password && _password.isEmpty) {
      showZagErrorSnackBar(
        title: 'ssh.Error'.tr(),
        message: 'ssh.PasswordRequired'.tr(),
      );
      return;
    }

    if (_authType == SSHAuthType.privateKey && _privateKey.isEmpty) {
      showZagErrorSnackBar(
        title: 'ssh.Error'.tr(),
        message: 'ssh.PrivateKeyRequired'.tr(),
      );
      return;
    }

    final updated = _connection!.copyWith(
      name: _name,
      host: _host,
      port: _port,
      username: _username,
      authType: _authType,
      password: _password,
      privateKey: _privateKey,
      passphrase: _passphrase,
      localHost: _localHost,
      localSsids: _localSsids,
      hostKeyFingerprint: _connection!.hostKeyFingerprint,
      hostKeyType: _connection!.hostKeyType,
    );

    await context.read<SSHState>().updateConnection(updated);

    if (mounted) {
      showZagSuccessSnackBar(
        title: 'ssh.ConnectionSaved'.tr(),
        message: null,
      );
      ZagRouter.router.pop();
    }
  }

  Future<void> _delete() async {
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
          text: 'ssh.DeleteConnectionConfirm'.tr(args: [_connection!.name]),
        ),
      ],
      contentPadding: ZagDialog.textDialogContentPadding(),
    );

    if (confirmed) {
      await context.read<SSHState>().deleteConnection(_connection!.id);
      if (mounted) {
        showZagSuccessSnackBar(
          title: 'ssh.ConnectionDeleted'.tr(),
          message: null,
        );
        ZagRouter.router.pop();
      }
    }
  }
}
