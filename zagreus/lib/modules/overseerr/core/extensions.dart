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
      return movie?.title ?? 'Loading...';
    } else if (mediaType == 'tv') {
      return series?.name ?? 'Loading...';
    }
    return '';
  }

  /// Get year from media (movie or series)
  String getYear() {
    if (mediaType == 'movie') {
      return movie?.releaseDate?.substring(0, 4) ?? '';
    } else if (mediaType == 'tv') {
      return series?.firstAirDate?.substring(0, 4) ?? '';
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
}
