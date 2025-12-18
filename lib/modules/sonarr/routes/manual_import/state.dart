import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/sonarr.dart';

class SonarrManualImportState extends ChangeNotifier {
  SonarrManualImportState(BuildContext context) {
    fetchDirectories(context, null);
  }

  String _currentPath = '';
  String get currentPath => _currentPath;
  set currentPath(String path) {
    _currentPath = path;
    updateTextControllerText();
    notifyListeners();
  }

  TextEditingController currentPathTextController = TextEditingController();
  void updateTextControllerText() {
    currentPathTextController.text = _currentPath;
    currentPathTextController.selection =
        TextSelection.fromPosition(TextPosition(offset: _currentPath.length));
  }

  Future<SonarrFileSystem>? _directories;
  Future<SonarrFileSystem>? get directories => _directories;
  void fetchDirectories(BuildContext context, String? path) {
    if (context.read<SonarrState>().enabled) {
      _directories = context
          .read<SonarrState>()
          .api!
          .filesystem
          .get(
            path: path,
            includeFiles: false,
            allowFoldersWithoutTrailingSlashes: false,
          )
          .whenComplete(() => currentPath = path ?? '');
    }
    notifyListeners();
  }
}
