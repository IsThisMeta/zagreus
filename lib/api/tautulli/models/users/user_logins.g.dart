// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_logins.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TautulliUserLogins _$TautulliUserLoginsFromJson(Map<String, dynamic> json) =>
    TautulliUserLogins(
      recordsFiltered:
          TautulliUtilities.ensureIntegerFromJson(json['recordsFiltered']),
      recordsTotal:
          TautulliUtilities.ensureIntegerFromJson(json['recordsTotal']),
      draw: TautulliUtilities.ensureIntegerFromJson(json['draw']),
      logins: TautulliUserLogins._loginsFromJson(json['data'] as List),
    );

Map<String, dynamic> _$TautulliUserLoginsToJson(TautulliUserLogins instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('recordsFiltered', instance.recordsFiltered);
  writeNotNull('recordsTotal', instance.recordsTotal);
  writeNotNull('draw', instance.draw);
  writeNotNull('data', TautulliUserLogins._loginsToJson(instance.logins));
  return val;
}
