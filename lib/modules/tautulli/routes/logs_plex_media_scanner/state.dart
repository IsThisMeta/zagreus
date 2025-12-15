import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/tautulli.dart';

class TautulliLogsPlexMediaScannerState extends ChangeNotifier {
  TautulliLogsPlexMediaScannerState(BuildContext context) {
    fetchLogs(context);
  }

  Future<List<TautulliPlexLog>>? _logs;
  Future<List<TautulliPlexLog>>? get logs => _logs;
  Future<void> fetchLogs(BuildContext context) async {
    if (context.read<TautulliState>().enabled) {
      _logs = context.read<TautulliState>().api!.miscellaneous.getPlexLog(
            window: TautulliDatabase.CONTENT_LOAD_LENGTH.read(),
            logType: TautulliPlexLogType.SCANNER,
          );
    }
    notifyListeners();
  }
}
