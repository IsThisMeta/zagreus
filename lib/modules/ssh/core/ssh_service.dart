import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dartssh2/dartssh2.dart';
import 'package:zagreus/database/models/ssh_connection.dart';
import 'package:zagreus/system/logger.dart';

enum SSHConnectionStatus {
  disconnected,
  connecting,
  connected,
  error,
}

class SSHService {
  SSHService._();
  static final SSHService instance = SSHService._();

  SSHClient? _client;
  SSHSession? _shell;
  SSHConnectionStatus _status = SSHConnectionStatus.disconnected;
  String? _errorMessage;
  SSHConnection? _currentConnection;

  SSHConnectionStatus get status => _status;
  String? get errorMessage => _errorMessage;
  SSHConnection? get currentConnection => _currentConnection;
  bool get isConnected => _status == SSHConnectionStatus.connected;

  final StreamController<SSHConnectionStatus> _statusController =
      StreamController<SSHConnectionStatus>.broadcast();
  Stream<SSHConnectionStatus> get statusStream => _statusController.stream;

  final StreamController<Uint8List> _outputController =
      StreamController<Uint8List>.broadcast();
  Stream<Uint8List> get outputStream => _outputController.stream;

  void _setStatus(SSHConnectionStatus status, [String? error]) {
    _status = status;
    _errorMessage = error;
    _statusController.add(status);
  }

  Future<bool> connect(SSHConnection connection) async {
    if (_status == SSHConnectionStatus.connecting) {
      return false;
    }

    await disconnect();

    _setStatus(SSHConnectionStatus.connecting);
    _currentConnection = connection;

    try {
      ZagLogger().debug('SSH: Connecting to ${connection.host}:${connection.port}');

      final socket = await SSHSocket.connect(
        connection.host,
        connection.port,
        timeout: const Duration(seconds: 30),
      );

      if (connection.authType == SSHAuthType.password) {
        _client = SSHClient(
          socket,
          username: connection.username,
          onPasswordRequest: () => connection.password,
        );
      } else {
        _client = SSHClient(
          socket,
          username: connection.username,
          identities: SSHKeyPair.fromPem(
            connection.privateKey,
            connection.passphrase.isNotEmpty ? connection.passphrase : null,
          ),
        );
      }

      ZagLogger().debug('SSH: Authenticated successfully');

      _shell = await _client!.shell(
        pty: SSHPtyConfig(
          width: 80,
          height: 24,
        ),
      );

      _shell!.stdout.listen(
        (data) {
          _outputController.add(data);
        },
        onError: (error) {
          ZagLogger().error('SSH stdout error', error, StackTrace.current);
        },
        onDone: () {
          ZagLogger().debug('SSH: Shell stdout closed');
          _handleDisconnect();
        },
      );

      _shell!.stderr.listen(
        (data) {
          _outputController.add(data);
        },
        onError: (error) {
          ZagLogger().error('SSH stderr error', error, StackTrace.current);
        },
      );

      _setStatus(SSHConnectionStatus.connected);
      ZagLogger().debug('SSH: Connected and shell ready');
      return true;
    } catch (e, stack) {
      ZagLogger().error('SSH: Connection failed', e, stack);
      _setStatus(SSHConnectionStatus.error, e.toString());
      await disconnect();
      return false;
    }
  }

  void _handleDisconnect() {
    if (_status != SSHConnectionStatus.disconnected) {
      _setStatus(SSHConnectionStatus.disconnected);
      _cleanup();
    }
  }

  Future<void> disconnect() async {
    _cleanup();
    _setStatus(SSHConnectionStatus.disconnected);
    _currentConnection = null;
    ZagLogger().debug('SSH: Disconnected');
  }

  void _cleanup() {
    try {
      _shell?.close();
    } catch (_) {}
    try {
      _client?.close();
    } catch (_) {}
    _shell = null;
    _client = null;
  }

  void write(String data) {
    if (_shell != null && isConnected) {
      _shell!.write(utf8.encode(data));
    }
  }

  void writeBytes(Uint8List data) {
    if (_shell != null && isConnected) {
      _shell!.write(data);
    }
  }

  void resize(int width, int height) {
    if (_shell != null && isConnected) {
      _shell!.resizeTerminal(width, height);
    }
  }

  Future<bool> testConnection(SSHConnection connection) async {
    try {
      ZagLogger().debug('SSH: Testing connection to ${connection.host}:${connection.port}');

      final socket = await SSHSocket.connect(
        connection.host,
        connection.port,
        timeout: const Duration(seconds: 10),
      );

      SSHClient client;
      if (connection.authType == SSHAuthType.password) {
        client = SSHClient(
          socket,
          username: connection.username,
          onPasswordRequest: () => connection.password,
        );
      } else {
        client = SSHClient(
          socket,
          username: connection.username,
          identities: SSHKeyPair.fromPem(
            connection.privateKey,
            connection.passphrase.isNotEmpty ? connection.passphrase : null,
          ),
        );
      }

      client.close();
      ZagLogger().debug('SSH: Test connection successful');
      return true;
    } catch (e, stack) {
      ZagLogger().error('SSH: Test connection failed', e, stack);
      return false;
    }
  }

  void dispose() {
    disconnect();
    _statusController.close();
    _outputController.close();
  }
}
