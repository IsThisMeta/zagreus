// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RadarrNotification _$RadarrNotificationFromJson(Map<String, dynamic> json) =>
    RadarrNotification(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      fields: (json['fields'] as List<dynamic>?)
          ?.map((e) =>
              RadarrNotificationField.fromJson(e as Map<String, dynamic>))
          .toList(),
      implementationName: json['implementationName'] as String?,
      implementation: json['implementation'] as String?,
      configContract: json['configContract'] as String?,
      infoLink: json['infoLink'] as String?,
      message: json['message'] as Map<String, dynamic>?,
      tags: (json['tags'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      presets: (json['presets'] as List<dynamic>?)
          ?.map((e) =>
              RadarrNotificationField.fromJson(e as Map<String, dynamic>))
          .toList(),
      link: json['link'] as String?,
      onGrab: json['onGrab'] as bool?,
      onDownload: json['onDownload'] as bool?,
      onUpgrade: json['onUpgrade'] as bool?,
      onRename: json['onRename'] as bool?,
      onMovieAdded: json['onMovieAdded'] as bool?,
      onMovieDelete: json['onMovieDelete'] as bool?,
      onMovieFileDelete: json['onMovieFileDelete'] as bool?,
      onMovieFileDeleteForUpgrade: json['onMovieFileDeleteForUpgrade'] as bool?,
      onHealthIssue: json['onHealthIssue'] as bool?,
      includeHealthWarnings: json['includeHealthWarnings'] as bool?,
      onApplicationUpdate: json['onApplicationUpdate'] as bool?,
      onManualInteractionRequired: json['onManualInteractionRequired'] as bool?,
      supportsOnGrab: json['supportsOnGrab'] as bool?,
      supportsOnDownload: json['supportsOnDownload'] as bool?,
      supportsOnUpgrade: json['supportsOnUpgrade'] as bool?,
      supportsOnRename: json['supportsOnRename'] as bool?,
      supportsOnMovieAdded: json['supportsOnMovieAdded'] as bool?,
      supportsOnMovieDelete: json['supportsOnMovieDelete'] as bool?,
      supportsOnMovieFileDelete: json['supportsOnMovieFileDelete'] as bool?,
      supportsOnMovieFileDeleteForUpgrade:
          json['supportsOnMovieFileDeleteForUpgrade'] as bool?,
      supportsOnHealthIssue: json['supportsOnHealthIssue'] as bool?,
      supportsOnApplicationUpdate: json['supportsOnApplicationUpdate'] as bool?,
      supportsOnManualInteractionRequired:
          json['supportsOnManualInteractionRequired'] as bool?,
    );

Map<String, dynamic> _$RadarrNotificationToJson(RadarrNotification instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('name', instance.name);
  writeNotNull('fields', instance.fields?.map((e) => e.toJson()).toList());
  writeNotNull('implementationName', instance.implementationName);
  writeNotNull('implementation', instance.implementation);
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
  writeNotNull('onMovieAdded', instance.onMovieAdded);
  writeNotNull('onMovieDelete', instance.onMovieDelete);
  writeNotNull('onMovieFileDelete', instance.onMovieFileDelete);
  writeNotNull(
      'onMovieFileDeleteForUpgrade', instance.onMovieFileDeleteForUpgrade);
  writeNotNull('onHealthIssue', instance.onHealthIssue);
  writeNotNull('includeHealthWarnings', instance.includeHealthWarnings);
  writeNotNull('onApplicationUpdate', instance.onApplicationUpdate);
  writeNotNull(
      'onManualInteractionRequired', instance.onManualInteractionRequired);
  writeNotNull('supportsOnGrab', instance.supportsOnGrab);
  writeNotNull('supportsOnDownload', instance.supportsOnDownload);
  writeNotNull('supportsOnUpgrade', instance.supportsOnUpgrade);
  writeNotNull('supportsOnRename', instance.supportsOnRename);
  writeNotNull('supportsOnMovieAdded', instance.supportsOnMovieAdded);
  writeNotNull('supportsOnMovieDelete', instance.supportsOnMovieDelete);
  writeNotNull('supportsOnMovieFileDelete', instance.supportsOnMovieFileDelete);
  writeNotNull('supportsOnMovieFileDeleteForUpgrade',
      instance.supportsOnMovieFileDeleteForUpgrade);
  writeNotNull('supportsOnHealthIssue', instance.supportsOnHealthIssue);
  writeNotNull(
      'supportsOnApplicationUpdate', instance.supportsOnApplicationUpdate);
  writeNotNull('supportsOnManualInteractionRequired',
      instance.supportsOnManualInteractionRequired);
  return val;
}

RadarrNotificationField _$RadarrNotificationFieldFromJson(
        Map<String, dynamic> json) =>
    RadarrNotificationField(
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

Map<String, dynamic> _$RadarrNotificationFieldToJson(
    RadarrNotificationField instance) {
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
