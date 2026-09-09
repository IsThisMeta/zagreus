import 'package:zagreus/core.dart';

class QBitState extends ZagModuleState {
  QBitState() {
    reset();
  }

  @override
  void reset() {
    _error = false;
    _paused = true;
    _downloadSpeed = 0;
    _uploadSpeed = 0;
    _currentDownloadSpeed = '0.0 B/s';
    _currentUploadSpeed = '0.0 B/s';
    _queueSearchFilter = '';
    _historySearchFilter = '';
    notifyListeners();
  }

  bool _error = false;
  bool get error => _error;
  set error(bool error) {
    _error = error;
    notifyListeners();
  }

  bool _paused = true;
  bool get paused => _paused;
  set paused(bool paused) {
    _paused = paused;
    notifyListeners();
  }

  int _downloadSpeed = 0;
  int get downloadSpeed => _downloadSpeed;
  set downloadSpeed(int downloadSpeed) {
    _downloadSpeed = downloadSpeed;
    notifyListeners();
  }

  int _uploadSpeed = 0;
  int get uploadSpeed => _uploadSpeed;
  set uploadSpeed(int uploadSpeed) {
    _uploadSpeed = uploadSpeed;
    notifyListeners();
  }

  String _currentDownloadSpeed = '0.0 B/s';
  String get currentDownloadSpeed => _currentDownloadSpeed;
  set currentDownloadSpeed(String currentDownloadSpeed) {
    _currentDownloadSpeed = currentDownloadSpeed;
    notifyListeners();
  }

  String _currentUploadSpeed = '0.0 B/s';
  String get currentUploadSpeed => _currentUploadSpeed;
  set currentUploadSpeed(String currentUploadSpeed) {
    _currentUploadSpeed = currentUploadSpeed;
    notifyListeners();
  }

  String _queueSearchFilter = '';
  String get queueSearchFilter => _queueSearchFilter;
  set queueSearchFilter(String queueSearchFilter) {
    _queueSearchFilter = queueSearchFilter;
    notifyListeners();
  }

  String _historySearchFilter = '';
  String get historySearchFilter => _historySearchFilter;
  set historySearchFilter(String historySearchFilter) {
    _historySearchFilter = historySearchFilter;
    notifyListeners();
  }
}
