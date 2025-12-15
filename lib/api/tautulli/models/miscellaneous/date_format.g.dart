// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'date_format.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TautulliDateFormat _$TautulliDateFormatFromJson(Map<String, dynamic> json) =>
    TautulliDateFormat(
      dateFormat: TautulliUtilities.ensureStringFromJson(json['date_format']),
      timeFormat: TautulliUtilities.ensureStringFromJson(json['time_format']),
    );

Map<String, dynamic> _$TautulliDateFormatToJson(TautulliDateFormat instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('date_format', instance.dateFormat);
  writeNotNull('time_format', instance.timeFormat);
  return val;
}
