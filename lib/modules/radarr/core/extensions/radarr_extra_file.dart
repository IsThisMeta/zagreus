import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/string/string.dart';
import 'package:zagreus/modules/radarr.dart';

extension ZagRadarrExtraFileExtension on RadarrExtraFile {
  String get zagRelativePath {
    if (this.relativePath?.isNotEmpty ?? false) return this.relativePath!;
    return ZagUI.TEXT_EMDASH;
  }

  String get zagExtension {
    if (this.extension?.isNotEmpty ?? false) return this.extension!;
    return ZagUI.TEXT_EMDASH;
  }

  String get zagType {
    if (this.type?.isNotEmpty ?? false) return this.type!.toTitleCase();
    return ZagUI.TEXT_EMDASH;
  }
}
