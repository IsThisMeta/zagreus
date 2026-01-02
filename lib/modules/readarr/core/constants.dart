import 'package:zagreus/core.dart';

class ReadarrConstants {
  ReadarrConstants._();

  static String eventTypeMessage(String eventType) {
    switch (eventType) {
      case 'bookFileRenamed':
        return 'readarr.BookFileRenamed'.tr();
      case 'bookFileDeleted':
        return 'readarr.BookFileDeleted'.tr();
      case 'bookFileImported':
        return 'readarr.BookFileImported'.tr();
      case 'bookFileRetagged':
        return 'readarr.BookFileRetagged'.tr();
      case 'bookImportIncomplete':
        return 'readarr.BookImportIncomplete'.tr();
      case 'downloadImported':
        return 'readarr.DownloadImported'.tr();
      case 'downloadFailed':
        return 'readarr.DownloadFailed'.tr();
      case 'grabbed':
        return 'readarr.GrabbedFrom'.tr();
      default:
        return eventType;
    }
  }
}
