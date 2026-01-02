import 'package:zagreus/core.dart';
import 'package:zagreus/database/box.dart';
import 'package:zagreus/database/models/ssh_connection.dart';

class SSHState extends ZagModuleState {
  SSHState() {
    reset();
  }

  @override
  void reset() {
    resetProfile();
    notifyListeners();
  }

  ///////////////
  /// PROFILE ///
  ///////////////

  bool _enabled = false;
  bool get enabled => _enabled;

  String _localHost = '';
  String get localHost => _localHost;

  String _localSsids = '';
  String get localSsids => _localSsids;

  bool get isConfigured => _enabled;

  void resetProfile() {
    ZagLogger().debug('SSHState.resetProfile called');
    ZagProfile profile = ZagProfile.current;
    _enabled = profile.sshEnabled;
    _localHost = profile.sshLocalHost;
    _localSsids = profile.sshLocalSsids;
  }

  //////////////////
  /// CONNECTIONS ///
  //////////////////

  List<SSHConnection> get connections {
    return ZagBox.sshConnections.data.toList();
  }

  SSHConnection? getConnection(String id) {
    try {
      return connections.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addConnection(SSHConnection connection) async {
    await ZagBox.sshConnections.update(connection.id, connection);
    notifyListeners();
  }

  Future<void> updateConnection(SSHConnection connection) async {
    await ZagBox.sshConnections.update(connection.id, connection);
    notifyListeners();
  }

  Future<void> deleteConnection(String id) async {
    await ZagBox.sshConnections.delete(id);
    notifyListeners();
  }
}
