// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'types.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OverseerrRequestStatusAdapter
    extends TypeAdapter<OverseerrRequestStatus> {
  @override
  final int typeId = 82;

  @override
  OverseerrRequestStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return OverseerrRequestStatus.PENDING;
      case 1:
        return OverseerrRequestStatus.APPROVED;
      case 2:
        return OverseerrRequestStatus.DECLINED;
      case 3:
        return OverseerrRequestStatus.UNKNOWN;
      default:
        return OverseerrRequestStatus.PENDING;
    }
  }

  @override
  void write(BinaryWriter writer, OverseerrRequestStatus obj) {
    switch (obj) {
      case OverseerrRequestStatus.PENDING:
        writer.writeByte(0);
        break;
      case OverseerrRequestStatus.APPROVED:
        writer.writeByte(1);
        break;
      case OverseerrRequestStatus.DECLINED:
        writer.writeByte(2);
        break;
      case OverseerrRequestStatus.UNKNOWN:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OverseerrRequestStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OverseerrIssueTypeAdapter extends TypeAdapter<OverseerrIssueType> {
  @override
  final int typeId = 83;

  @override
  OverseerrIssueType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return OverseerrIssueType.VIDEO;
      case 1:
        return OverseerrIssueType.AUDIO;
      case 2:
        return OverseerrIssueType.SUBTITLE;
      case 3:
        return OverseerrIssueType.OTHER;
      default:
        return OverseerrIssueType.VIDEO;
    }
  }

  @override
  void write(BinaryWriter writer, OverseerrIssueType obj) {
    switch (obj) {
      case OverseerrIssueType.VIDEO:
        writer.writeByte(0);
        break;
      case OverseerrIssueType.AUDIO:
        writer.writeByte(1);
        break;
      case OverseerrIssueType.SUBTITLE:
        writer.writeByte(2);
        break;
      case OverseerrIssueType.OTHER:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OverseerrIssueTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OverseerrIssueStatusAdapter extends TypeAdapter<OverseerrIssueStatus> {
  @override
  final int typeId = 84;

  @override
  OverseerrIssueStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return OverseerrIssueStatus.OPEN;
      case 1:
        return OverseerrIssueStatus.RESOLVED;
      default:
        return OverseerrIssueStatus.OPEN;
    }
  }

  @override
  void write(BinaryWriter writer, OverseerrIssueStatus obj) {
    switch (obj) {
      case OverseerrIssueStatus.OPEN:
        writer.writeByte(0);
        break;
      case OverseerrIssueStatus.RESOLVED:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OverseerrIssueStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OverseerrMediaStatusAdapter extends TypeAdapter<OverseerrMediaStatus> {
  @override
  final int typeId = 85;

  @override
  OverseerrMediaStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return OverseerrMediaStatus.UNKNOWN;
      case 1:
        return OverseerrMediaStatus.PENDING;
      case 2:
        return OverseerrMediaStatus.PROCESSING;
      case 3:
        return OverseerrMediaStatus.PARTIALLY_AVAILABLE;
      case 4:
        return OverseerrMediaStatus.AVAILABLE;
      default:
        return OverseerrMediaStatus.UNKNOWN;
    }
  }

  @override
  void write(BinaryWriter writer, OverseerrMediaStatus obj) {
    switch (obj) {
      case OverseerrMediaStatus.UNKNOWN:
        writer.writeByte(0);
        break;
      case OverseerrMediaStatus.PENDING:
        writer.writeByte(1);
        break;
      case OverseerrMediaStatus.PROCESSING:
        writer.writeByte(2);
        break;
      case OverseerrMediaStatus.PARTIALLY_AVAILABLE:
        writer.writeByte(3);
        break;
      case OverseerrMediaStatus.AVAILABLE:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OverseerrMediaStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
