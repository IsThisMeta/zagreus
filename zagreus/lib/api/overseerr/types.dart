import 'package:zagreus/vendor.dart';

part 'types.g.dart';

@HiveType(typeId: 82, adapterName: 'OverseerrRequestStatusAdapter')
enum OverseerrRequestStatus {
  @HiveField(0)
  PENDING(1),
  @HiveField(1)
  APPROVED(2),
  @HiveField(2)
  DECLINED(3),
  @HiveField(3)
  UNKNOWN(-1);

  final int value;
  const OverseerrRequestStatus(this.value);

  static OverseerrRequestStatus fromValue(int value) {
    switch (value) {
      case 1:
        return OverseerrRequestStatus.PENDING;
      case 2:
        return OverseerrRequestStatus.APPROVED;
      case 3:
        return OverseerrRequestStatus.DECLINED;
      default:
        return OverseerrRequestStatus.UNKNOWN;
    }
  }
}

@HiveType(typeId: 83, adapterName: 'OverseerrIssueTypeAdapter')
enum OverseerrIssueType {
  @HiveField(0)
  VIDEO(1),
  @HiveField(1)
  AUDIO(2),
  @HiveField(2)
  SUBTITLE(3),
  @HiveField(3)
  OTHER(4);

  final int value;
  const OverseerrIssueType(this.value);

  static OverseerrIssueType fromValue(int value) {
    switch (value) {
      case 1:
        return OverseerrIssueType.VIDEO;
      case 2:
        return OverseerrIssueType.AUDIO;
      case 3:
        return OverseerrIssueType.SUBTITLE;
      default:
        return OverseerrIssueType.OTHER;
    }
  }
}

@HiveType(typeId: 84, adapterName: 'OverseerrIssueStatusAdapter')
enum OverseerrIssueStatus {
  @HiveField(0)
  OPEN(1),
  @HiveField(1)
  RESOLVED(2);

  final int value;
  const OverseerrIssueStatus(this.value);

  static OverseerrIssueStatus fromValue(int value) {
    switch (value) {
      case 1:
        return OverseerrIssueStatus.OPEN;
      case 2:
        return OverseerrIssueStatus.RESOLVED;
      default:
        return OverseerrIssueStatus.OPEN;
    }
  }
}

@HiveType(typeId: 85, adapterName: 'OverseerrMediaStatusAdapter')
enum OverseerrMediaStatus {
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
  const OverseerrMediaStatus(this.value);

  static OverseerrMediaStatus fromValue(int value) {
    switch (value) {
      case 1:
        return OverseerrMediaStatus.UNKNOWN;
      case 2:
        return OverseerrMediaStatus.PENDING;
      case 3:
        return OverseerrMediaStatus.PROCESSING;
      case 4:
        return OverseerrMediaStatus.PARTIALLY_AVAILABLE;
      case 5:
        return OverseerrMediaStatus.AVAILABLE;
      default:
        return OverseerrMediaStatus.UNKNOWN;
    }
  }
}
