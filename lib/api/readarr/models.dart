/// Library containing all model definitions for Readarr data.
library readarr_models;

/// Author
export 'models/author/author.dart';
export 'models/author/author_statistics.dart';
export 'models/author/author_ratings.dart';
export 'models/author/author_links.dart';

/// Book
export 'models/book/book.dart';
export 'models/book/book_statistics.dart';
export 'models/book/book_ratings.dart';
export 'models/book/book_author_metadata.dart';

/// Edition
export 'models/edition/edition.dart';

/// Book File
export 'models/book_file/book_file.dart';
export 'models/book_file/book_file_quality.dart';
export 'models/book_file/book_file_quality_quality.dart';
export 'models/book_file/book_file_quality_revision.dart';
export 'models/book_file/book_file_media_info.dart';

/// Calendar
export 'models/calendar/calendar.dart';

/// Command
export 'models/command/command.dart';
export 'models/command/command_body.dart';

/// Filesystem
export 'models/filesystem/disk_space.dart';

/// Health Check
export 'models/health_check/health_check.dart';

/// History
export 'models/history/history.dart';
export 'models/history/history_record.dart';

/// Import List
export 'models/import_list/exclusion.dart';

/// Notification
export 'models/notification/notification.dart';

/// Profile
export 'models/profile/quality_profile.dart';
export 'models/profile/quality_profile_item.dart';
export 'models/profile/quality_profile_item_quality.dart';
export 'models/profile/quality_profile_cutoff.dart';
export 'models/profile/metadata_profile.dart';
export 'models/profile/metadata_profile_item.dart';

/// Queue
export 'models/queue/queue.dart';
export 'models/queue/queue_record.dart';

/// Release
export 'models/release/release.dart';

/// Root Folder
export 'models/root_folder/root_folder.dart';

/// Series (for Readarr, this represents authors in series)
export 'models/series/series.dart';
export 'models/series/series_book_link.dart';

/// System
export 'models/system/status.dart';

/// Tag
export 'models/tag/tag.dart';

/// Image
export 'models/image/image.dart';

/// Manual Import
export 'models/manual_import/manual_import.dart';
export 'models/manual_import/manual_import_item.dart';
