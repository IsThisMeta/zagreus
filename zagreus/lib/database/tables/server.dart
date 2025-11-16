import 'package:zagreus/database/table.dart';
import 'package:zagreus/vendor.dart';

enum ServerDatabase<T> with ZagTableMixin<T> {
  NAVIGATION_INDEX<int>(0),
  SECTION_ORDER<List>(const ['server_issues', 'overseerr_requests', 'disk_space', 'download_history']);

  @override
  void register() {
    // No custom adapters to register
  }

  @override
  ZagTable get table => ZagTable.server;

  @override
  final T fallback;

  const ServerDatabase(this.fallback);
}
