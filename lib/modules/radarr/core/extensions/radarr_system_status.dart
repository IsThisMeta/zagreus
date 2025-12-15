import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/duration/timestamp.dart';
import 'package:zagreus/extensions/string/string.dart';
import 'package:zagreus/modules/radarr.dart';

extension RadarrSystemStatusExtension on RadarrSystemStatus {
  String get zagVersion {
    if (this.version != null && this.version!.isNotEmpty) return this.version!;
    return ZagUI.TEXT_EMDASH;
  }

  String get zagPackageVersion {
    String? packageAuthor, packageVersion;
    if (this.packageVersion != null && this.packageVersion!.isNotEmpty)
      packageVersion = this.packageVersion;
    if (this.packageAuthor != null && this.packageAuthor!.isNotEmpty)
      packageAuthor = this.packageAuthor;
    return '${packageVersion ?? ZagUI.TEXT_EMDASH} by ${packageAuthor ?? ZagUI.TEXT_EMDASH}';
  }

  String get zagNetCore {
    if (this.isNetCore ?? false)
      return 'Yes (${this.runtimeVersion ?? ZagUI.TEXT_EMDASH})';
    return 'No';
  }

  bool get zagIsDocker {
    return this.isDocker ?? false;
  }

  String get zagDBMigration {
    if (this.migrationVersion != null) return '${this.migrationVersion}';
    return ZagUI.TEXT_EMDASH;
  }

  String get zagAppDataDirectory {
    if (this.appData != null && this.appData!.isNotEmpty) return this.appData!;
    return ZagUI.TEXT_EMDASH;
  }

  String get zagStartupDirectory {
    if (this.startupPath != null && this.startupPath!.isNotEmpty)
      return this.startupPath!;
    return ZagUI.TEXT_EMDASH;
  }

  String get zagMode {
    if (this.mode != null && this.mode!.isNotEmpty)
      return this.mode!.toTitleCase();
    return ZagUI.TEXT_EMDASH;
  }

  String get zagUptime {
    if (this.startTime != null && this.startTime!.isNotEmpty) {
      DateTime? _start = DateTime.tryParse(this.startTime!);
      if (_start != null)
        return DateTime.now().difference(_start).asWordsTimestamp();
    }
    return ZagUI.TEXT_EMDASH;
  }
}
