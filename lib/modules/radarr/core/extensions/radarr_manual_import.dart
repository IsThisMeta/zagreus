import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/int/bytes.dart';
import 'package:zagreus/modules/radarr.dart';

extension ZagRadarrManualImportExtension on RadarrManualImport {
  String? get zagLanguage {
    if ((this.languages?.length ?? 0) > 1) return 'Multi-Language';
    if ((this.languages?.length ?? 0) == 1) return this.languages![0].name;
    return ZagUI.TEXT_EMDASH;
  }

  String get zagQualityProfile {
    return this.quality?.quality?.name ?? ZagUI.TEXT_EMDASH;
  }

  String get zagSize {
    return this.size.asBytes();
  }

  String get zagMovie {
    if (this.movie == null) return ZagUI.TEXT_EMDASH;
    String title = this.movie!.title ?? ZagUI.TEXT_EMDASH;
    int? year = (this.movie!.year ?? 0) == 0 ? null : this.movie!.year;
    return [
      title,
      if (year != null) '($year)',
    ].join(' ');
  }
}
