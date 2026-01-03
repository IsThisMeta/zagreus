import 'package:zagreus/vendor.dart';

part 'types.g.dart';

@HiveType(typeId: 82, adapterName: 'SeerrRequestStatusAdapter')
enum SeerrRequestStatus {
  @HiveField(0)
  PENDING(1),
  @HiveField(1)
  APPROVED(2),
  @HiveField(2)
  DECLINED(3),
  @HiveField(3)
  UNKNOWN(-1);

  final int value;
  const SeerrRequestStatus(this.value);

  static SeerrRequestStatus fromValue(int value) {
    switch (value) {
      case 1:
        return SeerrRequestStatus.PENDING;
      case 2:
        return SeerrRequestStatus.APPROVED;
      case 3:
        return SeerrRequestStatus.DECLINED;
      default:
        return SeerrRequestStatus.UNKNOWN;
    }
  }
}

@HiveType(typeId: 83, adapterName: 'SeerrIssueTypeAdapter')
enum SeerrIssueType {
  @HiveField(0)
  VIDEO(1),
  @HiveField(1)
  AUDIO(2),
  @HiveField(2)
  SUBTITLE(3),
  @HiveField(3)
  OTHER(4);

  final int value;
  const SeerrIssueType(this.value);

  static SeerrIssueType fromValue(int value) {
    switch (value) {
      case 1:
        return SeerrIssueType.VIDEO;
      case 2:
        return SeerrIssueType.AUDIO;
      case 3:
        return SeerrIssueType.SUBTITLE;
      default:
        return SeerrIssueType.OTHER;
    }
  }
}

@HiveType(typeId: 84, adapterName: 'SeerrIssueStatusAdapter')
enum SeerrIssueStatus {
  @HiveField(0)
  OPEN(1),
  @HiveField(1)
  RESOLVED(2);

  final int value;
  const SeerrIssueStatus(this.value);

  static SeerrIssueStatus fromValue(int value) {
    switch (value) {
      case 1:
        return SeerrIssueStatus.OPEN;
      case 2:
        return SeerrIssueStatus.RESOLVED;
      default:
        return SeerrIssueStatus.OPEN;
    }
  }
}

@HiveType(typeId: 85, adapterName: 'SeerrMediaStatusAdapter')
enum SeerrMediaStatus {
  @HiveField(0)
  UNKNOWN(1),
  @HiveField(1)
  PENDING(2),
  @HiveField(2)
  PROCESSING(3),
  @HiveField(3)
  PARTIALLY_AVAILABLE(4),
  @HiveField(4)
  AVAILABLE(5);

  final int value;
  const SeerrMediaStatus(this.value);

  static SeerrMediaStatus fromValue(int value) {
    switch (value) {
      case 1:
        return SeerrMediaStatus.UNKNOWN;
      case 2:
        return SeerrMediaStatus.PENDING;
      case 3:
        return SeerrMediaStatus.PROCESSING;
      case 4:
        return SeerrMediaStatus.PARTIALLY_AVAILABLE;
      case 5:
        return SeerrMediaStatus.AVAILABLE;
      default:
        return SeerrMediaStatus.UNKNOWN;
    }
  }
}
