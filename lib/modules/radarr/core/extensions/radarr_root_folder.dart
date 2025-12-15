import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/int/bytes.dart';
import 'package:zagreus/modules/radarr.dart';

extension ZagRadarrRootFolderExtension on RadarrRootFolder? {
  String get zagPath {
    if (this?.path?.isNotEmpty ?? false) return this!.path!;
    return ZagUI.TEXT_EMDASH;
  }

  String get zagSpace {
    return this?.freeSpace.asBytes() ?? ZagUI.TEXT_EMDASH;
  }

  String get zagUnmappedFolders {
    int length = this?.unmappedFolders?.length ?? 0;
    if (this!.unmappedFolders!.length == 1) return 'radarr.UnmappedFolder'.tr();
    return 'radarr.UnmappedFolders'.tr(args: [length.toString()]);
  }
}
