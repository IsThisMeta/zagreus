// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'indexer.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ZagIndexerAdapter extends TypeAdapter<ZagIndexer> {
  @override
  final int typeId = 1;

  @override
  ZagIndexer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ZagIndexer(
      displayName: fields[0] == null ? '' : fields[0] as String?,
      host: fields[1] == null ? '' : fields[1] as String?,
      apiKey: fields[2] == null ? '' : fields[2] as String?,
      headers:
          fields[3] == null ? {} : (fields[3] as Map?)?.cast<String, String>(),
      isProwlarr: fields[4] == null ? false : fields[4] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, ZagIndexer obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.displayName)
      ..writeByte(1)
      ..write(obj.host)
      ..writeByte(2)
      ..write(obj.apiKey)
      ..writeByte(3)
      ..write(obj.headers)
      ..writeByte(4)
      ..write(obj.isProwlarr);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ZagIndexerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ZagIndexer _$ZagIndexerFromJson(Map<String, dynamic> json) => ZagIndexer(
      displayName: json['displayName'] as String?,
      host: json['host'] as String?,
      apiKey: json['key'] as String?,
      headers: (json['headers'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      isProwlarr: json['isProwlarr'] as bool? ?? false,
    );

Map<String, dynamic> _$ZagIndexerToJson(ZagIndexer instance) =>
    <String, dynamic>{
      'displayName': instance.displayName,
      'host': instance.host,
      'key': instance.apiKey,
      'headers': instance.headers,
      'isProwlarr': instance.isProwlarr,
    };
