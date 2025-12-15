import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/datetime.dart';
import 'package:zagreus/extensions/int/bytes.dart';
import 'package:zagreus/modules/radarr.dart';

extension ZagRadarrMovieFileExtension on RadarrMovieFile {
  String get zagRelativePath {
    if (this.relativePath?.isNotEmpty ?? false) return this.relativePath!;
    return ZagUI.TEXT_EMDASH;
  }

  String get zagSize {
    if ((this.size ?? 0) != 0) return this.size.asBytes(decimals: 1);
    return ZagUI.TEXT_EMDASH;
  }

  String get zagLanguage {
    if (this.languages?.isEmpty ?? true) return ZagUI.TEXT_EMDASH;
    return this.languages!.map<String?>((lang) => lang.name).join('\n');
  }

  String get zagQuality {
    if (this.quality?.quality?.name != null)
      return this.quality!.quality!.name!;
    return ZagUI.TEXT_EMDASH;
  }

  String get zagDateAdded {
    if (this.dateAdded != null)
      return this.dateAdded!.asDateTime(delimiter: '\n');
    return ZagUI.TEXT_EMDASH;
  }

  String get zagCustomFormats {
    if (this.customFormats != null && this.customFormats!.isNotEmpty)
      return this
          .customFormats!
          .map<String?>((format) => format.name)
          .join('\n');
    return ZagUI.TEXT_EMDASH;
  }
}
