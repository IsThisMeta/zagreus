import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xterm/xterm.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/models/ssh_connection.dart';
import 'package:zagreus/modules.dart';
import 'package:zagreus/modules/ssh/core/state.dart';
import 'package:zagreus/modules/ssh/core/ssh_service.dart';
import 'package:zagreus/router/router.dart';

class SSHTerminalRoute extends StatefulWidget {
  final String connectionId;

  const SSHTerminalRoute({
    Key? key,
    required this.connectionId,
  }) : super(key: key);

  @override
  State<SSHTerminalRoute> createState() => _State();
}

class _State extends State<SSHTerminalRoute> {
  final Terminal _terminal = Terminal(
    maxLines: 10000,
  );

  late final TerminalController _terminalController;
  SSHConnection? _connection;
  StreamSubscription? _outputSubscription;
  StreamSubscription? _statusSubscription;
  bool _isConnecting = false;

  // Buffer for batching output writes to reduce UI updates
  final List<Uint8List> _outputBuffer = [];
  Timer? _outputFlushTimer;
  static const _outputFlushInterval = Duration(milliseconds: 16); // ~60fps

  @override
  void initState() {
    super.initState();
    _terminalController = TerminalController();
    _loadAndConnect();
  }

  void _loadAndConnect() {
    final connection = context.read<SSHState>().getConnection(widget.connectionId);
    if (connection != null) {
      _connection = connection;
      _connect();
    }
  }

  Future<void> _connect() async {
    if (_connection == null || _isConnecting) return;

    setState(() => _isConnecting = true);
    _terminal.write(
      'ssh.TerminalConnectingTo'.tr(
        args: [
          _connection!.host,
          _connection!.port.toString(),
        ],
      ),
    );
    _terminal.write('\r\n');

    _outputSubscription = SSHService.instance.outputStream.listen((data) {
      _bufferOutput(data);
    });

    _statusSubscription = SSHService.instance.statusStream.listen((status) {
      if (status == SSHConnectionStatus.disconnected && mounted) {
        _terminal.write('\r\n${'ssh.TerminalDisconnected'.tr()}\r\n');
      } else if (status == SSHConnectionStatus.error && mounted) {
        _terminal.write(
          '\r\n${'ssh.TerminalError'.tr(
            args: [SSHService.instance.errorMessage ?? 'Unknown error'],
          )}\r\n',
        );
      }
    });

    _terminal.onOutput = (data) {
      SSHService.instance.write(data);
    };

    _terminal.onResize = (width, height, pixelWidth, pixelHeight) {
      SSHService.instance.resize(width, height);
    };

    final success = await SSHService.instance.connect(
      _connection!,
      onUnknownHostKey: _promptTrustHostKey,
    );

    if (mounted) {
      setState(() => _isConnecting = false);
      if (!success) {
        _terminal.write(
          '\r\n${'ssh.TerminalConnectionFailed'.tr(
            args: [SSHService.instance.errorMessage ?? 'Unknown error'],
          )}\r\n',
        );
      }
    }
  }

  Future<bool> _promptTrustHostKey(
    SSHConnection connection,
    String type,
    String fingerprint,
  ) async {
    if (!mounted) return false;

    bool accepted = false;

    await ZagDialog.dialog(
      context: context,
      title: 'ssh.HostKeyVerifyTitle'.tr(),
      buttons: [
        ZagDialog.button(
          text: 'ssh.Trust'.tr(),
          onPressed: () {
            accepted = true;
            Navigator.of(context, rootNavigator: true).pop();
          },
        ),
        ZagDialog.cancel(context),
      ],
      content: [
        ZagDialog.textContent(
          text: 'ssh.HostKeyVerifyMessage'.tr(
            args: [
              connection.host,
              type,
              fingerprint,
            ],
          ),
        ),
      ],
      contentPadding: ZagDialog.textDialogContentPadding(),
    );

    if (!accepted) return false;

    final normalized = SSHService.normalizeFingerprint(fingerprint);
    final updated = connection.copyWith(
      hostKeyFingerprint: normalized,
      hostKeyType: type,
    );

    _connection = updated;
    SSHService.instance.updateCurrentConnection(updated);
    await context.read<SSHState>().updateConnection(updated);
    return true;
  }

  void _bufferOutput(Uint8List data) {
    _outputBuffer.add(data);
    _outputFlushTimer ??= Timer(_outputFlushInterval, _flushOutputBuffer);
  }

  void _flushOutputBuffer() {
    _outputFlushTimer = null;
    if (_outputBuffer.isEmpty) return;

    // Combine all buffered data into single write
    final totalLength = _outputBuffer.fold<int>(0, (sum, data) => sum + data.length);
    final combined = Uint8List(totalLength);
    var offset = 0;
    for (final data in _outputBuffer) {
      combined.setRange(offset, offset + data.length, data);
      offset += data.length;
    }
    _outputBuffer.clear();

    // Write combined data to terminal
    _terminal.write(String.fromCharCodes(combined));
  }

  @override
  void dispose() {
    _outputFlushTimer?.cancel();
    _flushOutputBuffer(); // Flush any remaining data
    _outputSubscription?.cancel();
    _statusSubscription?.cancel();
    SSHService.instance.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    if (_connection == null) {
      return ZagScaffold(
        scaffoldKey: scaffoldKey,
        appBar: ZagAppBar(title: 'ssh.SshTitle'.tr()),
        body: Center(child: Text('ssh.ConnectionNotFound'.tr())),
      );
    }

    return ZagScaffold(
      scaffoldKey: scaffoldKey,
      appBar: ZagAppBar(
        title: _connection!.name,
        actions: [
          _statusIndicator(),
          ZagIconButton(
            icon: Icons.refresh_rounded,
            onPressed: _reconnect,
          ),
        ],
      ),
      body: _body(),
    );
  }

  Widget _statusIndicator() {
    return StreamBuilder<SSHConnectionStatus>(
      stream: SSHService.instance.statusStream,
      initialData: SSHService.instance.status,
      builder: (context, snapshot) {
        final status = snapshot.data ?? SSHConnectionStatus.disconnected;
        Color color;
        IconData icon;

        switch (status) {
          case SSHConnectionStatus.connected:
            color = Colors.green;
            icon = Icons.check_circle_rounded;
            break;
          case SSHConnectionStatus.connecting:
            color = Colors.orange;
            icon = Icons.sync_rounded;
            break;
          case SSHConnectionStatus.error:
            color = Colors.red;
            icon = Icons.error_rounded;
            break;
          case SSHConnectionStatus.disconnected:
            color = Colors.grey;
            icon = Icons.cancel_rounded;
            break;
        }

        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Icon(icon, color: color, size: 20),
        );
      },
    );
  }

  Widget _body() {
    return Container(
      color: Colors.black,
      child: GestureDetector(
        onLongPressStart: (details) => _showContextMenu(details.globalPosition),
        child: TerminalView(
          _terminal,
          controller: _terminalController,
          autofocus: true,
          backgroundOpacity: 1.0,
          theme: _terminalTheme(),
          textStyle: const TerminalStyle(
            fontSize: 14,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }

  void _showContextMenu(Offset position) {
    final selectedText = _terminalController.selection != null
        ? _terminal.buffer.getText(_terminalController.selection!)
        : null;
    final hasSelection = selectedText != null && selectedText.isNotEmpty;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      items: [
        if (hasSelection)
          PopupMenuItem<String>(
            value: 'copy',
            child: Row(
              children: [
                const Icon(Icons.copy_rounded, size: 20),
                const SizedBox(width: 12),
                Text('ssh.Copy'.tr()),
              ],
            ),
          ),
        PopupMenuItem<String>(
          value: 'paste',
          child: Row(
            children: [
              const Icon(Icons.paste_rounded, size: 20),
              const SizedBox(width: 12),
              Text('ssh.Paste'.tr()),
            ],
          ),
        ),
        if (hasSelection)
          PopupMenuItem<String>(
            value: 'clear_selection',
            child: Row(
              children: [
                const Icon(Icons.deselect_rounded, size: 20),
                const SizedBox(width: 12),
                Text('ssh.ClearSelection'.tr()),
              ],
            ),
          ),
      ],
    ).then((value) {
      if (value == null) return;
      switch (value) {
        case 'copy':
          if (selectedText != null) {
            Clipboard.setData(ClipboardData(text: selectedText));
            _terminalController.clearSelection();
          }
          break;
        case 'paste':
          _pasteFromClipboard();
          break;
        case 'clear_selection':
          _terminalController.clearSelection();
          break;
      }
    });
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      SSHService.instance.write(data.text!);
    }
  }

  TerminalTheme _terminalTheme() {
    return TerminalTheme(
      cursor: ZagModule.SSH.color,
      selection: ZagModule.SSH.color.withOpacity(0.3),
      foreground: Colors.white,
      background: Colors.black,
      black: Colors.black,
      red: Colors.red.shade400,
      green: Colors.green.shade400,
      yellow: Colors.yellow.shade400,
      blue: Colors.blue.shade400,
      magenta: Colors.purple.shade400,
      cyan: Colors.cyan.shade400,
      white: Colors.white,
      brightBlack: Colors.grey.shade600,
      brightRed: Colors.red.shade300,
      brightGreen: Colors.green.shade300,
      brightYellow: Colors.yellow.shade300,
      brightBlue: Colors.blue.shade300,
      brightMagenta: Colors.purple.shade300,
      brightCyan: Colors.cyan.shade300,
      brightWhite: Colors.white,
      searchHitBackground: Colors.yellow.withOpacity(0.3),
      searchHitBackgroundCurrent: Colors.orange.withOpacity(0.5),
      searchHitForeground: Colors.black,
    );
  }

  Future<void> _reconnect() async {
    await SSHService.instance.disconnect();
    _terminal.write('\r\n${'ssh.TerminalReconnecting'.tr()}\r\n');
    await _connect();
  }
}
