import 'package:zagreus/database/table.dart';
import 'package:zagreus/vendor.dart';

enum UnraidDatabase<T> with ZagTableMixin<T> {
  NAVIGATION_INDEX<int>(0),
  SECTION_ORDER<List>(const ['disk_space', 'download_history', 'server_issues', 'overseerr_requests', 'tautulli_streams']),
  OVERSEERR_REQUEST_FILTER<String>('pending'),
  OVERSEERR_REQUEST_SORT<String>('added');

  @override
  void register() {
    // No custom adapters to register
  }

  @override
  ZagTable get table => ZagTable.unraid;

  @override
  final T fallback;

  const UnraidDatabase(this.fallback);
}
