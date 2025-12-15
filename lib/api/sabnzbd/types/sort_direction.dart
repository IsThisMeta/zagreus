import 'package:zagreus/types/enum/readable.dart';
import 'package:zagreus/types/enum/serializable.dart';
import 'package:zagreus/vendor.dart';

enum SABnzbdSortDirection with EnumSerializable, EnumReadable {
  ASCENDING('asc'),
  DESCENDING('desc');

  @override
  final String value;

  const SABnzbdSortDirection(this.value);

  @override
  String get readable {
    switch (this) {
      case SABnzbdSortDirection.ASCENDING:
        return 'sabnzbd.Ascending'.tr();
      case SABnzbdSortDirection.DESCENDING:
        return 'sabnzbd.Descending'.tr();
    }
  }
}
