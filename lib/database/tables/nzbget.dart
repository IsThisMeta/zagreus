import 'package:zagreus/database/table.dart';

enum NZBGetDatabase<T> with ZagTableMixin<T> {
  NAVIGATION_INDEX<int>(0);

  @override
  ZagTable get table => ZagTable.nzbget;

  @override
  final T fallback;

  const NZBGetDatabase(this.fallback);
}
