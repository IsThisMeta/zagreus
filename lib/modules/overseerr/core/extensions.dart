import 'package:zagreus/core.dart';
import 'package:zagreus/modules/overseerr.dart';

extension OverseerrRequestExtension on OverseerrRequest {
  /// Get display status for request
  String getDisplayStatus() {
    final status = OverseerrRequestStatus.fromValue(this.status);
    switch (status) {
      case OverseerrRequestStatus.PENDING:
        return 'overseerr.Pending'.tr();
      case OverseerrRequestStatus.APPROVED:
        // Check media status for more detail
        final mediaStatus = OverseerrMediaStatus.fromValue(media.status);
        switch (mediaStatus) {
          case OverseerrMediaStatus.AVAILABLE:
            return 'overseerr.Available'.tr();
          case OverseerrMediaStatus.PARTIALLY_AVAILABLE:
            return 'overseerr.PartiallyAvailable'.tr();
          case OverseerrMediaStatus.PROCESSING:
            return 'overseerr.Processing'.tr();
          default:
            return 'overseerr.Approved'.tr();
        }
      case OverseerrRequestStatus.DECLINED:
        return 'overseerr.Declined'.tr();
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
        return 'overseerr.RelativeJustNow'.tr();
      } else if (difference.inMinutes < 60) {
        return 'overseerr.RelativeMinutesAgo'.tr(
          args: [difference.inMinutes.toString()],
        );
      } else if (difference.inHours < 24) {
        return 'overseerr.RelativeHoursAgo'.tr(
          args: [difference.inHours.toString()],
        );
      } else if (difference.inDays < 30) {
        return 'overseerr.RelativeDaysAgo'.tr(
          args: [difference.inDays.toString()],
        );
      } else if (difference.inDays < 365) {
        return 'overseerr.RelativeMonthsAgo'.tr(
          args: [(difference.inDays / 30).floor().toString()],
        );
      } else {
        return 'overseerr.RelativeYearsAgo'.tr(
          args: [(difference.inDays / 365).floor().toString()],
        );
      }
    } catch (e) {
      return '';
    }
  }
}

extension OverseerrIssueExtension on OverseerrIssue {
  /// Get display status for issue
  String getDisplayStatus() {
    final status = OverseerrIssueStatus.fromValue(this.status);
    switch (status) {
      case OverseerrIssueStatus.OPEN:
        return 'overseerr.Open'.tr();
      case OverseerrIssueStatus.RESOLVED:
        return 'overseerr.Resolved'.tr();
      default:
        return 'zagreus.Unknown'.tr();
    }
  }

  /// Get issue type string
  String getIssueTypeString() {
    final type = OverseerrIssueType.fromValue(issueType);
    switch (type) {
      case OverseerrIssueType.VIDEO:
        return 'overseerr.Video'.tr();
      case OverseerrIssueType.AUDIO:
        return 'overseerr.Audio'.tr();
      case OverseerrIssueType.SUBTITLE:
        return 'overseerr.Subtitles'.tr();
      case OverseerrIssueType.OTHER:
        return 'overseerr.Other'.tr();
      default:
        return 'overseerr.Other'.tr();
    }
  }

  /// Get relative time string
  String getRelativeTime() {
    try {
      final createdTime = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(createdTime);

      if (difference.inMinutes == 0) {
        return 'overseerr.RelativeJustNow'.tr();
      } else if (difference.inMinutes < 60) {
        return 'overseerr.RelativeMinutesAgo'.tr(
          args: [difference.inMinutes.toString()],
        );
      } else if (difference.inHours < 24) {
        return 'overseerr.RelativeHoursAgo'.tr(
          args: [difference.inHours.toString()],
        );
      } else if (difference.inDays < 30) {
        return 'overseerr.RelativeDaysAgo'.tr(
          args: [difference.inDays.toString()],
        );
      } else if (difference.inDays < 365) {
        return 'overseerr.RelativeMonthsAgo'.tr(
          args: [(difference.inDays / 30).floor().toString()],
        );
      } else {
        return 'overseerr.RelativeYearsAgo'.tr(
          args: [(difference.inDays / 365).floor().toString()],
        );
      }
    } catch (e) {
      return '';
    }
  }
}

extension OverseerrMediaExtension on OverseerrMedia {
  /// Get title from media (movie or series)
  String getTitle() {
    if (mediaType == 'movie') {
      return movie?.title ??
          'overseerr.TmdbId'.tr(args: [tmdbId.toString()]);
    } else if (mediaType == 'tv') {
      return series?.name ??
          'overseerr.TmdbId'.tr(args: [tmdbId.toString()]);
    }
    return 'overseerr.TmdbId'.tr(args: [tmdbId.toString()]);
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
        return 'overseerr.AvailableJustNow'.tr();
      } else if (difference.inMinutes < 60) {
        return 'overseerr.AvailableMinutesAgo'.tr(
          args: [difference.inMinutes.toString()],
        );
      } else if (difference.inHours < 24) {
        return 'overseerr.AvailableHoursAgo'.tr(
          args: [difference.inHours.toString()],
        );
      } else if (difference.inDays < 30) {
        return 'overseerr.AvailableDaysAgo'.tr(
          args: [difference.inDays.toString()],
        );
      } else {
        return 'overseerr.AvailableMonthsAgo'.tr(
          args: [(difference.inDays / 30).floor().toString()],
        );
      }
    } catch (e) {
      return '';
    }
  }
}
