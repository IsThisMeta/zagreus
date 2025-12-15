import 'package:zagreus/core.dart';
import 'package:zagreus/modules/radarr.dart';

extension ZagRadarrHistoryRecord on RadarrHistoryRecord {
  String get zagFileDeletedReasonMessage {
    if (this.eventType != RadarrEventType.MOVIE_FILE_DELETED ||
        this.data!['reason'] == null) return ZagUI.TEXT_EMDASH;
    switch (this.data!['reason']) {
      case 'Manual':
        return 'File was deleted manually';
      case 'MissingFromDisk':
        return 'Unable to find the file on disk';
      case 'Upgrade':
        return 'File was deleted to import an upgrade';
      default:
        return ZagUI.TEXT_EMDASH;
    }
  }
}
