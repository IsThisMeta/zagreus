import 'package:zagreus/database/table.dart';
import 'package:zagreus/vendor.dart';

enum UIPreferencesDatabase<T> with ZagTableMixin<T> {
  NAVIGATION_INDEX<int>(0),
  SECTION_ORDER<List>(const ['disk_space', 'download_history', 'server_issues', 'seerr_requests', 'tautulli_streams']),
  SEERR_REQUEST_FILTER<String>('pending'),
  SEERR_REQUEST_SORT<String>('added');

  @override
  void register() {
    // No custom adapters to register
  }

  @override
  ZagTable get table => ZagTable.uiPreferences;

  @override
  final T fallback;

  const UIPreferencesDatabase(this.fallback);
}
