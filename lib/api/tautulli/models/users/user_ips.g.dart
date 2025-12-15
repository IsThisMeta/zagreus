// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_ips.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TautulliUserIPs _$TautulliUserIPsFromJson(Map<String, dynamic> json) =>
    TautulliUserIPs(
      recordsFiltered:
          TautulliUtilities.ensureIntegerFromJson(json['recordsFiltered']),
      recordsTotal:
          TautulliUtilities.ensureIntegerFromJson(json['recordsTotal']),
      draw: TautulliUtilities.ensureIntegerFromJson(json['draw']),
      ips: TautulliUserIPs._ipsFromJson(json['data'] as List),
    );

Map<String, dynamic> _$TautulliUserIPsToJson(TautulliUserIPs instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('recordsFiltered', instance.recordsFiltered);
  writeNotNull('recordsTotal', instance.recordsTotal);
  writeNotNull('draw', instance.draw);
  writeNotNull('data', TautulliUserIPs._ipsToJson(instance.ips));
  return val;
}
