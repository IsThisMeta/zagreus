enum ReadarrMonitorStatus {
  ALL,
  FUTURE,
  MISSING,
  EXISTING,
  ONLY_FIRST_BOOK,
  ONLY_LAST_BOOK,
  NONE,
}

extension ReadarrMonitorStatusExtension on ReadarrMonitorStatus {
  ReadarrMonitorStatus? fromKey(String key) {
    switch (key) {
      case 'all':
        return ReadarrMonitorStatus.ALL;
      case 'future':
        return ReadarrMonitorStatus.FUTURE;
      case 'missing':
        return ReadarrMonitorStatus.MISSING;
      case 'existing':
        return ReadarrMonitorStatus.EXISTING;
      case 'first':
        return ReadarrMonitorStatus.ONLY_FIRST_BOOK;
      case 'latest':
        return ReadarrMonitorStatus.ONLY_LAST_BOOK;
      case 'none':
        return ReadarrMonitorStatus.NONE;
      default:
        return null;
    }
  }

  String get key {
    switch (this) {
      case ReadarrMonitorStatus.ALL:
        return 'all';
      case ReadarrMonitorStatus.FUTURE:
        return 'future';
      case ReadarrMonitorStatus.MISSING:
        return 'missing';
      case ReadarrMonitorStatus.EXISTING:
        return 'existing';
      case ReadarrMonitorStatus.ONLY_FIRST_BOOK:
        return 'first';
      case ReadarrMonitorStatus.ONLY_LAST_BOOK:
        return 'latest';
      case ReadarrMonitorStatus.NONE:
        return 'none';
    }
  }

  String get readable {
    switch (this) {
      case ReadarrMonitorStatus.ALL:
        return 'All Books';
      case ReadarrMonitorStatus.FUTURE:
        return 'Future Books';
      case ReadarrMonitorStatus.MISSING:
        return 'Missing Books';
      case ReadarrMonitorStatus.EXISTING:
        return 'Existing Books';
      case ReadarrMonitorStatus.ONLY_FIRST_BOOK:
        return 'Only First Book';
      case ReadarrMonitorStatus.ONLY_LAST_BOOK:
        return 'Only Latest Book';
      case ReadarrMonitorStatus.NONE:
        return 'None';
    }
  }
}
