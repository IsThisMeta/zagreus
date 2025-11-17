import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'status.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ReadarrStatus {
  @JsonKey(name: 'appName')
  String? appName;

  @JsonKey(name: 'version')
  String? version;

  @JsonKey(name: 'buildTime')
  DateTime? buildTime;

  @JsonKey(name: 'isDebug')
  bool? isDebug;

  @JsonKey(name: 'isProduction')
  bool? isProduction;

  @JsonKey(name: 'isAdmin')
  bool? isAdmin;

  @JsonKey(name: 'isUserInteractive')
  bool? isUserInteractive;

  @JsonKey(name: 'startupPath')
  String? startupPath;

  @JsonKey(name: 'appData')
  String? appData;

  @JsonKey(name: 'osName')
  String? osName;

  @JsonKey(name: 'osVersion')
  String? osVersion;

  @JsonKey(name: 'isNetCore')
  bool? isNetCore;

  @JsonKey(name: 'isMono')
  bool? isMono;

  @JsonKey(name: 'isLinux')
  bool? isLinux;

  @JsonKey(name: 'isOsx')
  bool? isOsx;

  @JsonKey(name: 'isWindows')
  bool? isWindows;

  @JsonKey(name: 'branch')
  String? branch;

  @JsonKey(name: 'authentication')
  String? authentication;

  @JsonKey(name: 'sqliteVersion')
  String? sqliteVersion;

  @JsonKey(name: 'urlBase')
  String? urlBase;

  @JsonKey(name: 'runtimeVersion')
  String? runtimeVersion;

  @JsonKey(name: 'runtimeName')
  String? runtimeName;

  @JsonKey(name: 'startTime')
  DateTime? startTime;

  @JsonKey(name: 'packageVersion')
  String? packageVersion;

  @JsonKey(name: 'packageAuthor')
  String? packageAuthor;

  @JsonKey(name: 'packageUpdateMechanism')
  String? packageUpdateMechanism;

  ReadarrStatus({
    this.appName,
    this.version,
    this.buildTime,
    this.isDebug,
    this.isProduction,
    this.isAdmin,
    this.isUserInteractive,
    this.startupPath,
    this.appData,
    this.osName,
    this.osVersion,
    this.isNetCore,
    this.isMono,
    this.isLinux,
    this.isOsx,
    this.isWindows,
    this.branch,
    this.authentication,
    this.sqliteVersion,
    this.urlBase,
    this.runtimeVersion,
    this.runtimeName,
    this.startTime,
    this.packageVersion,
    this.packageAuthor,
    this.packageUpdateMechanism,
  });

  factory ReadarrStatus.fromJson(Map<String, dynamic> json) =>
      _$ReadarrStatusFromJson(json);

  Map<String, dynamic> toJson() => _$ReadarrStatusToJson(this);

  @override
  String toString() => json.encode(toJson());
}
