import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/models/ssh_connection.dart';
import 'package:zagreus/modules/ssh/core/state.dart';
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
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_connection == null) {
      return ZagScaffold(
        scaffoldKey: _scaffoldKey,
        appBar: ZagAppBar(title: 'ssh.EditConnection'.tr()),
        body: const Center(child: Text('Connection not found')),
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
          _saveButton(),
        ],
      ),
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

  Widget _saveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ZagButton.text(
        text: 'ssh.Save'.tr(),
        icon: Icons.save_rounded,
        onTap: _save,
      ),
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
}
