// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifier_config_actions.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TautulliNotifierConfigActions _$TautulliNotifierConfigActionsFromJson(
        Map<String, dynamic> json) =>
    TautulliNotifierConfigActions(
      onPlay: TautulliUtilities.ensureBooleanFromJson(json['on_play']),
      onBuffer: TautulliUtilities.ensureBooleanFromJson(json['on_buffer']),
      onChange: TautulliUtilities.ensureBooleanFromJson(json['on_change']),
      onConcurrent:
          TautulliUtilities.ensureBooleanFromJson(json['on_concurrent']),
      onCreated: TautulliUtilities.ensureBooleanFromJson(json['on_created']),
      onNewDevice:
          TautulliUtilities.ensureBooleanFromJson(json['on_newdevice']),
      onPause: TautulliUtilities.ensureBooleanFromJson(json['on_pause']),
      onPlexServerDown:
          TautulliUtilities.ensureBooleanFromJson(json['on_intdown']),
      onPlexServerRemoteAccessDown:
          TautulliUtilities.ensureBooleanFromJson(json['on_extdown']),
      onPlexServerRemoteAccessUp:
          TautulliUtilities.ensureBooleanFromJson(json['on_extup']),
      onPlexServerUp: TautulliUtilities.ensureBooleanFromJson(json['on_intup']),
      onPlexUpdate:
          TautulliUtilities.ensureBooleanFromJson(json['on_pmsupdate']),
      onResume: TautulliUtilities.ensureBooleanFromJson(json['on_resume']),
      onStop: TautulliUtilities.ensureBooleanFromJson(json['on_stop']),
      onTautulliDatabaseCorruption:
          TautulliUtilities.ensureBooleanFromJson(json['on_plexpydbcorrupt']),
      onTautulliUpdate:
          TautulliUtilities.ensureBooleanFromJson(json['on_plexpyupdate']),
      onWatched: TautulliUtilities.ensureBooleanFromJson(json['on_watched']),
    );

Map<String, dynamic> _$TautulliNotifierConfigActionsToJson(
    TautulliNotifierConfigActions instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('on_play', instance.onPlay);
  writeNotNull('on_stop', instance.onStop);
  writeNotNull('on_pause', instance.onPause);
  writeNotNull('on_resume', instance.onResume);
  writeNotNull('on_change', instance.onChange);
  writeNotNull('on_buffer', instance.onBuffer);
  writeNotNull('on_watched', instance.onWatched);
  writeNotNull('on_concurrent', instance.onConcurrent);
  writeNotNull('on_newdevice', instance.onNewDevice);
  writeNotNull('on_created', instance.onCreated);
  writeNotNull('on_intdown', instance.onPlexServerDown);
  writeNotNull('on_intup', instance.onPlexServerUp);
  writeNotNull('on_extdown', instance.onPlexServerRemoteAccessDown);
  writeNotNull('on_extup', instance.onPlexServerRemoteAccessUp);
  writeNotNull('on_pmsupdate', instance.onPlexUpdate);
  writeNotNull('on_plexpyupdate', instance.onTautulliUpdate);
  writeNotNull('on_plexpydbcorrupt', instance.onTautulliDatabaseCorruption);
  return val;
}
