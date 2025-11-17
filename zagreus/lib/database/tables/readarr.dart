import 'package:zagreus/database/table.dart';
import 'package:zagreus/types/list_view_option.dart';
import 'package:zagreus/vendor.dart';

enum ReadarrDatabase<T> with ZagTableMixin<T> {
  NAVIGATION_INDEX<int>(0),
  NAVIGATION_INDEX_AUTHOR_DETAILS<int>(0),
  NAVIGATION_INDEX_ADD_AUTHOR<int>(0),
  DEFAULT_VIEW_AUTHORS<ZagListViewOption>(ZagListViewOption.BLOCK_VIEW),
  ADD_AUTHOR_DEFAULT_MONITORED_STATE<bool>(true),
  ADD_AUTHOR_DEFAULT_MONITOR_NEW_ITEMS<String>('all'),
  ADD_AUTHOR_DEFAULT_ROOT_FOLDER_ID<int?>(null),
  ADD_AUTHOR_DEFAULT_QUALITY_PROFILE_ID<int?>(null),
  ADD_AUTHOR_DEFAULT_METADATA_PROFILE_ID<int?>(null),
  ADD_AUTHOR_DEFAULT_TAGS<List>([]),
  ADD_AUTHOR_SEARCH_FOR_MISSING_BOOKS<bool>(false),
  QUEUE_PAGE_SIZE<int>(50),
  QUEUE_REFRESH_RATE<int>(60),
  QUEUE_BLOCKLIST<bool>(false),
  QUEUE_REMOVE_FROM_CLIENT<bool>(false),
  REMOVE_AUTHOR_IMPORT_LIST<bool>(false),
  REMOVE_AUTHOR_DELETE_FILES<bool>(false),
  CONTENT_PAGE_SIZE<int>(10);

  @override
  void register() {
    // No custom adapters to register for Readarr yet
  }

  @override
  ZagTable get table => ZagTable.readarr;

  @override
  final T fallback;

  const ReadarrDatabase(this.fallback);

  @override
  dynamic export() {
    ReadarrDatabase db = this;
    switch (db) {
      case ReadarrDatabase.DEFAULT_VIEW_AUTHORS:
        return ReadarrDatabase.DEFAULT_VIEW_AUTHORS.read().key;
      default:
        return super.export();
    }
  }

  @override
  void import(dynamic value) {
    ReadarrDatabase db = this;
    dynamic result;

    switch (db) {
      case ReadarrDatabase.DEFAULT_VIEW_AUTHORS:
        result = ZagListViewOption.fromKey(value.toString());
        break;
      default:
        result = value;
        break;
    }

    return super.import(result);
  }
}
