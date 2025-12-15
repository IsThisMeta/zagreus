// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users_table.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TautulliUsersTable _$TautulliUsersTableFromJson(Map<String, dynamic> json) =>
    TautulliUsersTable(
      users: TautulliUsersTable._usersFromJson(json['data'] as List),
      draw: TautulliUtilities.ensureIntegerFromJson(json['draw']),
      recordsTotal:
          TautulliUtilities.ensureIntegerFromJson(json['recordsTotal']),
      recordsFiltered:
          TautulliUtilities.ensureIntegerFromJson(json['recordsFiltered']),
    );

Map<String, dynamic> _$TautulliUsersTableToJson(TautulliUsersTable instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('data', TautulliUsersTable._usersToJson(instance.users));
  writeNotNull('draw', instance.draw);
  writeNotNull('recordsTotal', instance.recordsTotal);
  writeNotNull('recordsFiltered', instance.recordsFiltered);
  return val;
}
