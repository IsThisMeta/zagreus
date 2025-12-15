// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SonarrNotification _$SonarrNotificationFromJson(Map<String, dynamic> json) =>
    SonarrNotification(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      fields: (json['fields'] as List<dynamic>?)
          ?.map((e) =>
              SonarrNotificationField.fromJson(e as Map<String, dynamic>))
          .toList(),
      implementation: json['implementation'] as String?,
      implementationName: json['implementationName'] as String?,
      configContract: json['configContract'] as String?,
      infoLink: json['infoLink'] as String?,
      message: json['message'] as Map<String, dynamic>?,
      tags: (json['tags'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      presets: (json['presets'] as List<dynamic>?)
          ?.map((e) => SonarrNotification.fromJson(e as Map<String, dynamic>))
          .toList(),
      link: json['link'] as String?,
      onGrab: json['onGrab'] as bool?,
      onDownload: json['onDownload'] as bool?,
      onUpgrade: json['onUpgrade'] as bool?,
      onRename: json['onRename'] as bool?,
      onSeriesAdd: json['onSeriesAdd'] as bool?,
      onSeriesDelete: json['onSeriesDelete'] as bool?,
      onEpisodeFileDelete: json['onEpisodeFileDelete'] as bool?,
      onEpisodeFileDeleteForUpgrade:
          json['onEpisodeFileDeleteForUpgrade'] as bool?,
      onHealthIssue: json['onHealthIssue'] as bool?,
      includeHealthWarnings: json['includeHealthWarnings'] as bool?,
      onApplicationUpdate: json['onApplicationUpdate'] as bool?,
      onManualInteractionRequired: json['onManualInteractionRequired'] as bool?,
      supportsOnGrab: json['supportsOnGrab'] as bool?,
      supportsOnDownload: json['supportsOnDownload'] as bool?,
      supportsOnUpgrade: json['supportsOnUpgrade'] as bool?,
      supportsOnRename: json['supportsOnRename'] as bool?,
      supportsOnSeriesAdd: json['supportsOnSeriesAdd'] as bool?,
      supportsOnSeriesDelete: json['supportsOnSeriesDelete'] as bool?,
      supportsOnEpisodeFileDelete: json['supportsOnEpisodeFileDelete'] as bool?,
      supportsOnEpisodeFileDeleteForUpgrade:
          json['supportsOnEpisodeFileDeleteForUpgrade'] as bool?,
      supportsOnHealthIssue: json['supportsOnHealthIssue'] as bool?,
      supportsOnApplicationUpdate: json['supportsOnApplicationUpdate'] as bool?,
      supportsOnManualInteractionRequired:
          json['supportsOnManualInteractionRequired'] as bool?,
    );

Map<String, dynamic> _$SonarrNotificationToJson(SonarrNotification instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('name', instance.name);
  writeNotNull('fields', instance.fields?.map((e) => e.toJson()).toList());
  writeNotNull('implementation', instance.implementation);
  writeNotNull('implementationName', instance.implementationName);
  writeNotNull('configContract', instance.configContract);
  writeNotNull('infoLink', instance.infoLink);
  writeNotNull('message', instance.message);
  writeNotNull('tags', instance.tags);
  writeNotNull('presets', instance.presets?.map((e) => e.toJson()).toList());
  writeNotNull('link', instance.link);
  writeNotNull('onGrab', instance.onGrab);
  writeNotNull('onDownload', instance.onDownload);
  writeNotNull('onUpgrade', instance.onUpgrade);
  writeNotNull('onRename', instance.onRename);
  writeNotNull('onSeriesAdd', instance.onSeriesAdd);
  writeNotNull('onSeriesDelete', instance.onSeriesDelete);
  writeNotNull('onEpisodeFileDelete', instance.onEpisodeFileDelete);
  writeNotNull(
      'onEpisodeFileDeleteForUpgrade', instance.onEpisodeFileDeleteForUpgrade);
  writeNotNull('onHealthIssue', instance.onHealthIssue);
  writeNotNull('includeHealthWarnings', instance.includeHealthWarnings);
  writeNotNull('onApplicationUpdate', instance.onApplicationUpdate);
  writeNotNull(
      'onManualInteractionRequired', instance.onManualInteractionRequired);
  writeNotNull('supportsOnGrab', instance.supportsOnGrab);
  writeNotNull('supportsOnDownload', instance.supportsOnDownload);
  writeNotNull('supportsOnUpgrade', instance.supportsOnUpgrade);
  writeNotNull('supportsOnRename', instance.supportsOnRename);
  writeNotNull('supportsOnSeriesAdd', instance.supportsOnSeriesAdd);
  writeNotNull('supportsOnSeriesDelete', instance.supportsOnSeriesDelete);
  writeNotNull(
      'supportsOnEpisodeFileDelete', instance.supportsOnEpisodeFileDelete);
  writeNotNull('supportsOnEpisodeFileDeleteForUpgrade',
      instance.supportsOnEpisodeFileDeleteForUpgrade);
  writeNotNull('supportsOnHealthIssue', instance.supportsOnHealthIssue);
  writeNotNull(
      'supportsOnApplicationUpdate', instance.supportsOnApplicationUpdate);
  writeNotNull('supportsOnManualInteractionRequired',
      instance.supportsOnManualInteractionRequired);
  return val;
}

SonarrNotificationField _$SonarrNotificationFieldFromJson(
        Map<String, dynamic> json) =>
    SonarrNotificationField(
      name: json['name'] as String?,
      value: json['value'],
      type: json['type'] as String?,
      advanced: json['advanced'] as bool?,
      order: (json['order'] as num?)?.toInt(),
      label: json['label'] as String?,
      helpText: json['helpText'] as String?,
      helpLink: json['helpLink'] as String?,
      privacy: json['privacy'] as String?,
      placeholder: json['placeholder'] as String?,
      isFloat: json['isFloat'] as bool?,
      selectOptions: (json['selectOptions'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      selectOptionsProviderAction:
          json['selectOptionsProviderAction'] as String?,
      section: json['section'] as String?,
      hidden: json['hidden'] as String?,
    );

Map<String, dynamic> _$SonarrNotificationFieldToJson(
    SonarrNotificationField instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('name', instance.name);
  writeNotNull('value', instance.value);
  writeNotNull('type', instance.type);
  writeNotNull('advanced', instance.advanced);
  writeNotNull('order', instance.order);
  writeNotNull('label', instance.label);
  writeNotNull('helpText', instance.helpText);
  writeNotNull('helpLink', instance.helpLink);
  writeNotNull('privacy', instance.privacy);
  writeNotNull('placeholder', instance.placeholder);
  writeNotNull('isFloat', instance.isFloat);
  writeNotNull('selectOptions', instance.selectOptions);
  writeNotNull(
      'selectOptionsProviderAction', instance.selectOptionsProviderAction);
  writeNotNull('section', instance.section);
  writeNotNull('hidden', instance.hidden);
  return val;
}
