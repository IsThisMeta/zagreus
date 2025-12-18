import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/sonarr.dart';

class SonarrManualImportDetailsState extends ChangeNotifier {
  final String path;

  SonarrManualImportDetailsState(
    BuildContext context, {
    required this.path,
  }) {
    fetchManualImport(context);
  }

  bool canExecuteAction = false;
  ZagLoadingState _loadingState = ZagLoadingState.INACTIVE;
  ZagLoadingState get loadingState => _loadingState;
  set loadingState(ZagLoadingState state) {
    _loadingState = state;
    notifyListeners();
  }

  Future<List<SonarrManualImport>>? _manualImport;
  Future<List<SonarrManualImport>>? get manualImport => _manualImport;
  Future<void> fetchManualImport(BuildContext context) async {
    if (context.read<SonarrState>().enabled)
      _manualImport = context.read<SonarrState>().api!.manualImport.get(
            folder: path,
            filterExistingFiles: true,
          );
    notifyListeners();
  }

  List<int> _selectedFiles = [];
  List<int> get selectedFiles => _selectedFiles;
  set selectedFiles(List<int> selectedFiles) {
    _selectedFiles = selectedFiles;
    notifyListeners();
  }

  void addSelectedFile(int id) {
    if (_selectedFiles.contains(id)) return;
    _selectedFiles.add(id);
    notifyListeners();
  }

  void removeSelectedFile(int id) {
    if (!_selectedFiles.contains(id)) return;
    _selectedFiles.remove(id);
    notifyListeners();
  }

  void toggleSelectedFile(int id) {
    _selectedFiles.contains(id) ? removeSelectedFile(id) : addSelectedFile(id);
  }

  void setSelectedFile(int id, bool state) {
    if (!_selectedFiles.contains(id) && state) addSelectedFile(id);
    if (_selectedFiles.contains(id) && !state) removeSelectedFile(id);
  }
}
