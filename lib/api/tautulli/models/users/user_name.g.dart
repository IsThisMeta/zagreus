// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_name.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TautulliUserName _$TautulliUserNameFromJson(Map<String, dynamic> json) =>
    TautulliUserName(
      userId: TautulliUtilities.ensureIntegerFromJson(json['user_id']),
      friendlyName:
          TautulliUtilities.ensureStringFromJson(json['friendly_name']),
    );

Map<String, dynamic> _$TautulliUserNameToJson(TautulliUserName instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('user_id', instance.userId);
  writeNotNull('friendly_name', instance.friendlyName);
  return val;
}
