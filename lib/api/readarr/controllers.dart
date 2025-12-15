/// Library containing all logic and accessors to make calls to Readarr's API.
library readarr_commands;

import 'package:zagreus/api/readarr/models.dart';
import 'package:dio/dio.dart';

// Author
part 'controllers/author.dart';
part 'controllers/author/get_all_authors.dart';
part 'controllers/author/get_author.dart';
part 'controllers/author/add_author.dart';
part 'controllers/author/update_author.dart';
part 'controllers/author/delete_author.dart';

// Author Lookup
part 'controllers/author_lookup.dart';
part 'controllers/author_lookup/lookup.dart';

// Book
part 'controllers/book.dart';
part 'controllers/book/get_books_by_author.dart';
part 'controllers/book/get_book.dart';
part 'controllers/book/update_book.dart';
part 'controllers/book/set_monitored.dart';

// Book File
part 'controllers/book_file.dart';
part 'controllers/book_file/delete_book_file.dart';
part 'controllers/book_file/delete_book_files.dart';
part 'controllers/book_file/get_book_file.dart';
part 'controllers/book_file/get_author_book_files.dart';

// Calendar
part 'controllers/calendar.dart';
part 'controllers/calendar/get_calendar.dart';

// Command
part 'controllers/command.dart';
part 'controllers/command/author_search.dart';
part 'controllers/command/book_search.dart';
part 'controllers/command/missing_book_search.dart';
part 'controllers/command/refresh_author.dart';
part 'controllers/command/refresh_book.dart';
part 'controllers/command/rescan_folders.dart';
part 'controllers/command/rss_sync.dart';

// Filesystem
part 'controllers/filesystem.dart';
part 'controllers/filesystem/get_disk_space.dart';

// Health Check
part 'controllers/health_check.dart';
part 'controllers/health_check/get_health.dart';

// History
part 'controllers/history.dart';
part 'controllers/history/get_history.dart';
part 'controllers/history/get_history_by_author.dart';

// Import List
part 'controllers/import_list.dart';
part 'controllers/import_list/get_exclusion_list.dart';

// Manual Import
part 'controllers/manual_import.dart';
part 'controllers/manual_import/get_manual_import.dart';
part 'controllers/manual_import/update_manual_import.dart';

// Notification
part 'controllers/notification.dart';
part 'controllers/notification/get_notifications.dart';

// Profile
part 'controllers/profile.dart';
part 'controllers/profile/get_quality_profiles.dart';
part 'controllers/profile/get_metadata_profiles.dart';

// Queue
part 'controllers/queue.dart';
part 'controllers/queue/get_queue.dart';
part 'controllers/queue/delete_queue.dart';

// Release
part 'controllers/release.dart';
part 'controllers/release/get_releases.dart';
part 'controllers/release/add_release.dart';

// Root Folder
part 'controllers/root_folder.dart';
part 'controllers/root_folder/get_root_folders.dart';

// System
part 'controllers/system.dart';
part 'controllers/system/get_status.dart';

// Tag
part 'controllers/tag.dart';
part 'controllers/tag/get_all_tags.dart';
part 'controllers/tag/get_tag.dart';
part 'controllers/tag/add_tag.dart';
part 'controllers/tag/update_tag.dart';
part 'controllers/tag/delete_tag.dart';
