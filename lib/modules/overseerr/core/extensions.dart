import 'package:zagreus/modules/overseerr.dart';

extension OverseerrRequestExtension on OverseerrRequest {
  /// Get display status for request
  String getDisplayStatus() {
    final status = OverseerrRequestStatus.fromValue(this.status);
    switch (status) {
      case OverseerrRequestStatus.PENDING:
        return 'Pending';
      case OverseerrRequestStatus.APPROVED:
        // Check media status for more detail
        final mediaStatus = OverseerrMediaStatus.fromValue(media.status);
        switch (mediaStatus) {
          case OverseerrMediaStatus.AVAILABLE:
            return 'Available';
          case OverseerrMediaStatus.PARTIALLY_AVAILABLE:
            return 'Partially Available';
          case OverseerrMediaStatus.PROCESSING:
            return 'Processing';
          default:
            return 'Approved';
        }
      case OverseerrRequestStatus.DECLINED:
        return 'Declined';
      default:
        return 'Unknown';
    }
  }

  /// Get relative time string
  String getRelativeTime() {
    try {
      final createdTime = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(createdTime);

      if (difference.inMinutes == 0) {
        return 'just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 30) {
        return '${difference.inDays}d ago';
      } else if (difference.inDays < 365) {
        return '${(difference.inDays / 30).floor()}mth ago';
      } else {
        return '${(difference.inDays / 365).floor()}yr ago';
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
        return 'Open';
      case OverseerrIssueStatus.RESOLVED:
        return 'Resolved';
      default:
        return 'Unknown';
    }
  }

  /// Get issue type string
  String getIssueTypeString() {
    final type = OverseerrIssueType.fromValue(issueType);
    switch (type) {
      case OverseerrIssueType.VIDEO:
        return 'Video';
      case OverseerrIssueType.AUDIO:
        return 'Audio';
      case OverseerrIssueType.SUBTITLE:
        return 'Subtitles';
      case OverseerrIssueType.OTHER:
        return 'Other';
      default:
        return 'Other';
    }
  }

  /// Get relative time string
  String getRelativeTime() {
    try {
      final createdTime = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(createdTime);

      if (difference.inMinutes == 0) {
        return 'just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 30) {
        return '${difference.inDays}d ago';
      } else if (difference.inDays < 365) {
        return '${(difference.inDays / 30).floor()}mth ago';
      } else {
        return '${(difference.inDays / 365).floor()}yr ago';
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
      return movie?.title ?? 'TMDB ID: $tmdbId';
    } else if (mediaType == 'tv') {
      return series?.name ?? 'TMDB ID: $tmdbId';
    }
    return 'TMDB ID: $tmdbId';
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
        return 'Available just now';
      } else if (difference.inMinutes < 60) {
        return 'Available ${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return 'Available ${difference.inHours}h ago';
      } else if (difference.inDays < 30) {
        return 'Available ${difference.inDays}d ago';
      } else {
        return 'Available ${(difference.inDays / 30).floor()}mth ago';
      }
    } catch (e) {
      return '';
    }
  }
}
