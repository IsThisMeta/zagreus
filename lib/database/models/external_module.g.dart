// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'external_module.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ZagExternalModuleAdapter extends TypeAdapter<ZagExternalModule> {
  @override
  final int typeId = 26;

  @override
  ZagExternalModule read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ZagExternalModule(
      displayName: fields[0] == null ? '' : fields[0] as String,
      host: fields[1] == null ? '' : fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ZagExternalModule obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.displayName)
      ..writeByte(1)
      ..write(obj.host);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ZagExternalModuleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ZagExternalModule _$ZagExternalModuleFromJson(Map<String, dynamic> json) =>
    ZagExternalModule(
      displayName: json['displayName'] as String? ?? '',
      host: json['host'] as String? ?? '',
    );

Map<String, dynamic> _$ZagExternalModuleToJson(ZagExternalModule instance) =>
    <String, dynamic>{
      'displayName': instance.displayName,
      'host': instance.host,
    };
