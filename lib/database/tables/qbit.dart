import 'package:zagreus/database/table.dart';

enum QBitDatabase<T> with ZagTableMixin<T> {
  NAVIGATION_INDEX<int>(0);

  @override
  ZagTable get table => ZagTable.qbit;

  @override
  final T fallback;

  const QBitDatabase(this.fallback);
}
