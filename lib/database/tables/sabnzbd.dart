import 'package:zagreus/database/table.dart';

enum SABnzbdDatabase<T> with ZagTableMixin<T> {
  NAVIGATION_INDEX<int>(0);

  @override
  ZagTable get table => ZagTable.sabnzbd;

  @override
  final T fallback;

  const SABnzbdDatabase(this.fallback);
}
