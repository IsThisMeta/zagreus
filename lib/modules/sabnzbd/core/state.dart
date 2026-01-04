import 'package:zagreus/core.dart';

class SABnzbdState extends ZagModuleState {
  SABnzbdState() {
    reset();
  }

  @override
  void reset() {
    _selectedQueueIds.clear();
    _isMultiSelectMode = false;
  }

  // Multi-select state
  final Set<String> _selectedQueueIds = {};
  Set<String> get selectedQueueIds => _selectedQueueIds;

  bool _isMultiSelectMode = false;
  bool get isMultiSelectMode => _isMultiSelectMode;

  void enterMultiSelectMode(String initialId) {
    _isMultiSelectMode = true;
    _selectedQueueIds.add(initialId);
    notifyListeners();
  }

  void exitMultiSelectMode() {
    _isMultiSelectMode = false;
    _selectedQueueIds.clear();
    notifyListeners();
  }

  void toggleSelection(String id) {
    if (_selectedQueueIds.contains(id)) {
      _selectedQueueIds.remove(id);
      // Auto-exit multi-select if nothing selected
      if (_selectedQueueIds.isEmpty) {
        _isMultiSelectMode = false;
      }
    } else {
      _selectedQueueIds.add(id);
    }
    notifyListeners();
  }

  void selectAll(List<String> ids) {
    _selectedQueueIds.addAll(ids);
    notifyListeners();
  }

  bool isSelected(String id) => _selectedQueueIds.contains(id);

  int get selectedCount => _selectedQueueIds.length;

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

  int _navigationIndex = 0;
  int get navigationIndex => _navigationIndex;
  set navigationIndex(int navigationIndex) {
    _navigationIndex = navigationIndex;
    notifyListeners();
  }

  String _historySearchFilter = '';
  String get historySearchFilter => _historySearchFilter;
  set historySearchFilter(String historySearchFilter) {
    _historySearchFilter = historySearchFilter;
    notifyListeners();
  }

  bool _historyHideFailed = false;
  bool get historyHideFailed => _historyHideFailed;
  set historyHideFailed(bool historyHideFailed) {
    _historyHideFailed = historyHideFailed;
    notifyListeners();
  }

  String _currentSpeed = '0.0 B/s';
  String get currentSpeed => _currentSpeed;
  set currentSpeed(String currentSpeed) {
    _currentSpeed = currentSpeed;
    notifyListeners();
  }

  String _queueSizeLeft = '0.0 B';
  String get queueSizeLeft => _queueSizeLeft;
  set queueSizeLeft(String queueSizeLeft) {
    _queueSizeLeft = queueSizeLeft;
    notifyListeners();
  }

  String _queueTimeLeft = '0:00:00';
  String get queueTimeLeft => _queueTimeLeft;
  set queueTimeLeft(String queueTimeLeft) {
    _queueTimeLeft = queueTimeLeft;
    notifyListeners();
  }

  int _speedLimit = 0;
  int get speedLimit => _speedLimit;
  set speedLimit(int speedLimit) {
    _speedLimit = speedLimit;
    notifyListeners();
  }
}
