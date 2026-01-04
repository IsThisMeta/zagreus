// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'types.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SeerrRequestStatusAdapter extends TypeAdapter<SeerrRequestStatus> {
  @override
  final int typeId = 82;

  @override
  SeerrRequestStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SeerrRequestStatus.PENDING;
      case 1:
        return SeerrRequestStatus.APPROVED;
      case 2:
        return SeerrRequestStatus.DECLINED;
      case 3:
        return SeerrRequestStatus.UNKNOWN;
      default:
        return SeerrRequestStatus.PENDING;
    }
  }

  @override
  void write(BinaryWriter writer, SeerrRequestStatus obj) {
    switch (obj) {
      case SeerrRequestStatus.PENDING:
        writer.writeByte(0);
        break;
      case SeerrRequestStatus.APPROVED:
        writer.writeByte(1);
        break;
      case SeerrRequestStatus.DECLINED:
        writer.writeByte(2);
        break;
      case SeerrRequestStatus.UNKNOWN:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SeerrRequestStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SeerrIssueTypeAdapter extends TypeAdapter<SeerrIssueType> {
  @override
  final int typeId = 83;

  @override
  SeerrIssueType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SeerrIssueType.VIDEO;
      case 1:
        return SeerrIssueType.AUDIO;
      case 2:
        return SeerrIssueType.SUBTITLE;
      case 3:
        return SeerrIssueType.OTHER;
      default:
        return SeerrIssueType.VIDEO;
    }
  }

  @override
  void write(BinaryWriter writer, SeerrIssueType obj) {
    switch (obj) {
      case SeerrIssueType.VIDEO:
        writer.writeByte(0);
        break;
      case SeerrIssueType.AUDIO:
        writer.writeByte(1);
        break;
      case SeerrIssueType.SUBTITLE:
        writer.writeByte(2);
        break;
      case SeerrIssueType.OTHER:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SeerrIssueTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SeerrIssueStatusAdapter extends TypeAdapter<SeerrIssueStatus> {
  @override
  final int typeId = 84;

  @override
  SeerrIssueStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SeerrIssueStatus.OPEN;
      case 1:
        return SeerrIssueStatus.RESOLVED;
      default:
        return SeerrIssueStatus.OPEN;
    }
  }

  @override
  void write(BinaryWriter writer, SeerrIssueStatus obj) {
    switch (obj) {
      case SeerrIssueStatus.OPEN:
        writer.writeByte(0);
        break;
      case SeerrIssueStatus.RESOLVED:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SeerrIssueStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SeerrMediaStatusAdapter extends TypeAdapter<SeerrMediaStatus> {
  @override
  final int typeId = 85;

  @override
  SeerrMediaStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SeerrMediaStatus.UNKNOWN;
      case 1:
        return SeerrMediaStatus.PENDING;
      case 2:
        return SeerrMediaStatus.PROCESSING;
      case 3:
        return SeerrMediaStatus.PARTIALLY_AVAILABLE;
      case 4:
        return SeerrMediaStatus.AVAILABLE;
      default:
        return SeerrMediaStatus.UNKNOWN;
    }
  }

  @override
  void write(BinaryWriter writer, SeerrMediaStatus obj) {
    switch (obj) {
      case SeerrMediaStatus.UNKNOWN:
        writer.writeByte(0);
        break;
      case SeerrMediaStatus.PENDING:
        writer.writeByte(1);
        break;
      case SeerrMediaStatus.PROCESSING:
        writer.writeByte(2);
        break;
      case SeerrMediaStatus.PARTIALLY_AVAILABLE:
        writer.writeByte(3);
        break;
      case SeerrMediaStatus.AVAILABLE:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SeerrMediaStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
