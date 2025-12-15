// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifier_parameter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TautulliNotifierParameter _$TautulliNotifierParameterFromJson(
        Map<String, dynamic> json) =>
    TautulliNotifierParameter(
      name: TautulliUtilities.ensureStringFromJson(json['name']),
      type: TautulliUtilities.ensureStringFromJson(json['type']),
      value: TautulliUtilities.ensureStringFromJson(json['value']),
    );

Map<String, dynamic> _$TautulliNotifierParameterToJson(
    TautulliNotifierParameter instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('name', instance.name);
  writeNotNull('type', instance.type);
  writeNotNull('value', instance.value);
  return val;
}
