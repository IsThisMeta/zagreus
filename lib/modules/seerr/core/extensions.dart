import 'package:zagreus/core.dart';
import 'package:zagreus/modules/seerr.dart';

extension SeerrRequestExtension on SeerrRequest {
  /// Get display status for request
  String getDisplayStatus() {
    final status = SeerrRequestStatus.fromValue(this.status);
    switch (status) {
      case SeerrRequestStatus.PENDING:
        return 'seerr.Pending'.tr();
      case SeerrRequestStatus.APPROVED:
        // Check media status for more detail
        final mediaStatus = SeerrMediaStatus.fromValue(media.status);
        switch (mediaStatus) {
          case SeerrMediaStatus.AVAILABLE:
            return 'seerr.Available'.tr();
          case SeerrMediaStatus.PARTIALLY_AVAILABLE:
            return 'seerr.PartiallyAvailable'.tr();
          case SeerrMediaStatus.PROCESSING:
            return 'seerr.Processing'.tr();
          default:
            return 'seerr.Approved'.tr();
        }
      case SeerrRequestStatus.DECLINED:
        return 'seerr.Declined'.tr();
      default:
        return 'zagreus.Unknown'.tr();
    }
  }

  /// Get relative time string
  String getRelativeTime() {
    try {
      final createdTime = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(createdTime);

      if (difference.inMinutes == 0) {
        return 'seerr.RelativeJustNow'.tr();
      } else if (difference.inMinutes < 60) {
        return 'seerr.RelativeMinutesAgo'.tr(
          args: [difference.inMinutes.toString()],
        );
      } else if (difference.inHours < 24) {
        return 'seerr.RelativeHoursAgo'.tr(
          args: [difference.inHours.toString()],
        );
      } else if (difference.inDays < 30) {
        return 'seerr.RelativeDaysAgo'.tr(
          args: [difference.inDays.toString()],
        );
      } else if (difference.inDays < 365) {
        return 'seerr.RelativeMonthsAgo'.tr(
          args: [(difference.inDays / 30).floor().toString()],
        );
      } else {
        return 'seerr.RelativeYearsAgo'.tr(
          args: [(difference.inDays / 365).floor().toString()],
        );
      }
    } catch (e) {
      return '';
    }
  }
}

extension SeerrIssueExtension on SeerrIssue {
  /// Get display status for issue
  String getDisplayStatus() {
    final status = SeerrIssueStatus.fromValue(this.status);
    switch (status) {
      case SeerrIssueStatus.OPEN:
        return 'seerr.Open'.tr();
      case SeerrIssueStatus.RESOLVED:
        return 'seerr.Resolved'.tr();
      default:
        return 'zagreus.Unknown'.tr();
    }
  }

  /// Get issue type string
  String getIssueTypeString() {
    final type = SeerrIssueType.fromValue(issueType);
    switch (type) {
      case SeerrIssueType.VIDEO:
        return 'seerr.Video'.tr();
      case SeerrIssueType.AUDIO:
        return 'seerr.Audio'.tr();
      case SeerrIssueType.SUBTITLE:
        return 'seerr.Subtitles'.tr();
      case SeerrIssueType.OTHER:
        return 'seerr.Other'.tr();
      default:
        return 'seerr.Other'.tr();
    }
  }

  /// Get relative time string
  String getRelativeTime() {
    try {
      final createdTime = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(createdTime);

      if (difference.inMinutes == 0) {
        return 'seerr.RelativeJustNow'.tr();
      } else if (difference.inMinutes < 60) {
        return 'seerr.RelativeMinutesAgo'.tr(
          args: [difference.inMinutes.toString()],
        );
      } else if (difference.inHours < 24) {
        return 'seerr.RelativeHoursAgo'.tr(
          args: [difference.inHours.toString()],
        );
      } else if (difference.inDays < 30) {
        return 'seerr.RelativeDaysAgo'.tr(
          args: [difference.inDays.toString()],
        );
      } else if (difference.inDays < 365) {
        return 'seerr.RelativeMonthsAgo'.tr(
          args: [(difference.inDays / 30).floor().toString()],
        );
      } else {
        return 'seerr.RelativeYearsAgo'.tr(
          args: [(difference.inDays / 365).floor().toString()],
        );
      }
    } catch (e) {
      return '';
    }
  }
}

extension SeerrMediaExtension on SeerrMedia {
  /// Get title from media (movie or series)
  String getTitle() {
    if (mediaType == 'movie') {
      return movie?.title ??
          'seerr.TmdbId'.tr(args: [tmdbId.toString()]);
    } else if (mediaType == 'tv') {
      return series?.name ??
          'seerr.TmdbId'.tr(args: [tmdbId.toString()]);
    }
    return 'seerr.TmdbId'.tr(args: [tmdbId.toString()]);
  }

  /// Get year from media (movie or series)
  String getYear() {
    if (mediaType == 'movie') {
      if (movie?.releaseDate != null && movie!.releaseDate!.length >= 4) {
        return movie!.releaseDate!.substring(0, 4);
      }
    } else if (mediaType == 'tv') {
      if (series?.firstAirDate != null && series!.firstAirDate!.length >= 4) {
        return series!.firstAirDate!.substring(0, 4);
      }
    }
    return '';
  }

  /// Get poster path from media (movie or series)
  String? getPosterPath() {
    if (mediaType == 'movie') {
      return movie?.posterPath;
    } else if (mediaType == 'tv') {
      return series?.posterPath;
    }
    return null;
  }

  /// Get backdrop path from media (movie or series)
  String? getBackdropPath() {
    if (mediaType == 'movie') {
      return movie?.backdropPath;
    } else if (mediaType == 'tv') {
      return series?.backdropPath;
    }
    return null;
  }

  /// Check if media has active downloads
  bool hasActiveDownloads() {
    return downloadStatus.isNotEmpty || downloadStatus4k.isNotEmpty;
  }

  /// Get total download size in bytes
  int getTotalDownloadSize() {
    int total = 0;
    for (final download in downloadStatus) {
      total += download.size;
    }
    for (final download in downloadStatus4k) {
      total += download.size;
    }
    return total;
  }

  /// Get formatted download size string
  String getFormattedDownloadSize() {
    final bytes = getTotalDownloadSize();
    if (bytes == 0) return '';

    const kb = 1024;
    const mb = kb * 1024;
    const gb = mb * 1024;

    if (bytes >= gb) {
      return '${(bytes / gb).toStringAsFixed(2)} GB';
    } else if (bytes >= mb) {
      return '${(bytes / mb).toStringAsFixed(1)} MB';
    } else if (bytes >= kb) {
      return '${(bytes / kb).toStringAsFixed(0)} KB';
    } else {
      return '$bytes B';
    }
  }

  /// Get download count (number of files downloading)
  int getDownloadCount() {
    return downloadStatus.length + downloadStatus4k.length;
  }

  /// Check if media was recently made available (within 7 days)
  bool isRecentlyAvailable() {
    if (mediaAddedAt == null) return false;
    try {
      final addedDate = DateTime.parse(mediaAddedAt!);
      final now = DateTime.now();
      final difference = now.difference(addedDate);
      return difference.inDays <= 7;
    } catch (e) {
      return false;
    }
  }

  /// Get relative time since media became available
  String getAvailableRelativeTime() {
    if (mediaAddedAt == null) return '';
    try {
      final addedDate = DateTime.parse(mediaAddedAt!);
      final now = DateTime.now();
      final difference = now.difference(addedDate);

      if (difference.inMinutes == 0) {
        return 'seerr.AvailableJustNow'.tr();
      } else if (difference.inMinutes < 60) {
        return 'seerr.AvailableMinutesAgo'.tr(
          args: [difference.inMinutes.toString()],
        );
      } else if (difference.inHours < 24) {
        return 'seerr.AvailableHoursAgo'.tr(
          args: [difference.inHours.toString()],
        );
      } else if (difference.inDays < 30) {
        return 'seerr.AvailableDaysAgo'.tr(
          args: [difference.inDays.toString()],
        );
      } else {
        return 'seerr.AvailableMonthsAgo'.tr(
          args: [(difference.inDays / 30).floor().toString()],
        );
      }
    } catch (e) {
      return '';
    }
  }
}
