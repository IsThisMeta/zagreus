import 'package:zagreus/database/table.dart';
import 'package:zagreus/modules.dart';

enum BIOSDatabase<T> with ZagTableMixin<T> {
  BOOT_MODULE<ZagModule>(ZagModule.DASHBOARD),
  FIRST_BOOT<bool>(true);

  @override
  ZagTable get table => ZagTable.bios;

  @override
  final T fallback;

  const BIOSDatabase(this.fallback);

  @override
  dynamic export() {
    BIOSDatabase db = this;
    switch (db) {
      case BIOSDatabase.BOOT_MODULE:
        return BIOSDatabase.BOOT_MODULE.read().key;
      default:
        return super.export();
    }
  }

  @override
  void import(dynamic value) {
    BIOSDatabase db = this;
    dynamic result;

    switch (db) {
      case BIOSDatabase.BOOT_MODULE:
        result = ZagModule.fromKey(value.toString());
        break;
      default:
        result = value;
        break;
    }

    return super.import(result);
  }
}
