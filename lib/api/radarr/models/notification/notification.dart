import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'notification.g.dart';

/// Model for a Radarr notification/webhook connection
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class RadarrNotification {
  @JsonKey(name: 'id')
  int? id;

  @JsonKey(name: 'name')
  String? name;

  @JsonKey(name: 'fields')
  List<RadarrNotificationField>? fields;

  @JsonKey(name: 'implementationName')
  String? implementationName;

  @JsonKey(name: 'implementation')
  String? implementation;

  @JsonKey(name: 'configContract')
  String? configContract;

  @JsonKey(name: 'infoLink')
  String? infoLink;

  @JsonKey(name: 'message')
  Map<String, dynamic>? message;

  @JsonKey(name: 'tags')
  List<int>? tags;

  @JsonKey(name: 'presets')
  List<RadarrNotificationField>? presets;

  @JsonKey(name: 'link')
  String? link;

  @JsonKey(name: 'onGrab')
  bool? onGrab;

  @JsonKey(name: 'onDownload')
  bool? onDownload;

  @JsonKey(name: 'onUpgrade')
  bool? onUpgrade;

  @JsonKey(name: 'onRename')
  bool? onRename;

  @JsonKey(name: 'onMovieAdded')
  bool? onMovieAdded;

  @JsonKey(name: 'onMovieDelete')
  bool? onMovieDelete;

  @JsonKey(name: 'onMovieFileDelete')
  bool? onMovieFileDelete;

  @JsonKey(name: 'onMovieFileDeleteForUpgrade')
  bool? onMovieFileDeleteForUpgrade;

  @JsonKey(name: 'onHealthIssue')
  bool? onHealthIssue;

  @JsonKey(name: 'includeHealthWarnings')
  bool? includeHealthWarnings;

  @JsonKey(name: 'onApplicationUpdate')
  bool? onApplicationUpdate;

  @JsonKey(name: 'onManualInteractionRequired')
  bool? onManualInteractionRequired;

  @JsonKey(name: 'supportsOnGrab')
  bool? supportsOnGrab;

  @JsonKey(name: 'supportsOnDownload')
  bool? supportsOnDownload;

  @JsonKey(name: 'supportsOnUpgrade')
  bool? supportsOnUpgrade;

  @JsonKey(name: 'supportsOnRename')
  bool? supportsOnRename;

  @JsonKey(name: 'supportsOnMovieAdded')
  bool? supportsOnMovieAdded;

  @JsonKey(name: 'supportsOnMovieDelete')
  bool? supportsOnMovieDelete;

  @JsonKey(name: 'supportsOnMovieFileDelete')
  bool? supportsOnMovieFileDelete;

  @JsonKey(name: 'supportsOnMovieFileDeleteForUpgrade')
  bool? supportsOnMovieFileDeleteForUpgrade;

  @JsonKey(name: 'supportsOnHealthIssue')
  bool? supportsOnHealthIssue;

  @JsonKey(name: 'supportsOnApplicationUpdate')
  bool? supportsOnApplicationUpdate;

  @JsonKey(name: 'supportsOnManualInteractionRequired')
  bool? supportsOnManualInteractionRequired;

  RadarrNotification({
    this.id,
    this.name,
    this.fields,
    this.implementationName,
    this.implementation,
    this.configContract,
    this.infoLink,
    this.message,
    this.tags,
    this.presets,
    this.link,
    this.onGrab,
    this.onDownload,
    this.onUpgrade,
    this.onRename,
    this.onMovieAdded,
    this.onMovieDelete,
    this.onMovieFileDelete,
    this.onMovieFileDeleteForUpgrade,
    this.onHealthIssue,
    this.includeHealthWarnings,
    this.onApplicationUpdate,
    this.onManualInteractionRequired,
    this.supportsOnGrab,
    this.supportsOnDownload,
    this.supportsOnUpgrade,
    this.supportsOnRename,
    this.supportsOnMovieAdded,
    this.supportsOnMovieDelete,
    this.supportsOnMovieFileDelete,
    this.supportsOnMovieFileDeleteForUpgrade,
    this.supportsOnHealthIssue,
    this.supportsOnApplicationUpdate,
    this.supportsOnManualInteractionRequired,
  });

  /// Create a new webhook notification with Zagreus settings
  factory RadarrNotification.webhook({
    required String name,
    required String url,
    String? username,
    String? password,
    List<int>? tags,
  }) {
    return RadarrNotification(
      name: name,
      implementation: 'Webhook',
      implementationName: 'Webhook',
      configContract: 'WebhookSettings',
      fields: [
        RadarrNotificationField(
          name: 'url',
          value: url,
        ),
        RadarrNotificationField(
          name: 'method',
          value: '1', // POST - must be string!
        ),
        RadarrNotificationField(
          name: 'username',
          value: username ?? '',
        ),
        RadarrNotificationField(
          name: 'password',
          value: password ?? '',
        ),
      ],
      tags: tags ?? [],
      // Enable all notification types
      onGrab: true,
      onDownload: true,
      onUpgrade: true,
      onRename: true,
      onMovieAdded: true,
      onMovieDelete: true,
      onMovieFileDelete: true,
      onMovieFileDeleteForUpgrade: true,
      onHealthIssue: true,
      includeHealthWarnings: false,
      onApplicationUpdate: false,
      onManualInteractionRequired: true,
    );
  }

  /// Returns a JSON-encoded string version of this object.
  String toJson() => json.encode(_$RadarrNotificationToJson(this));

  /// Deserialize a JSON map to a [RadarrNotification] object.
  factory RadarrNotification.fromJson(Map<String, dynamic> json) =>
      _$RadarrNotificationFromJson(json);
}

/// Model for notification field configuration
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class RadarrNotificationField {
  @JsonKey(name: 'name')
  String? name;

  @JsonKey(name: 'value')
  dynamic value;

  @JsonKey(name: 'type')
  String? type;

  @JsonKey(name: 'advanced')
  bool? advanced;

  @JsonKey(name: 'order')
  int? order;

  @JsonKey(name: 'label')
  String? label;

  @JsonKey(name: 'helpText')
  String? helpText;

  @JsonKey(name: 'helpLink')
  String? helpLink;

  @JsonKey(name: 'privacy')
  String? privacy;

  @JsonKey(name: 'placeholder')
  String? placeholder;

  @JsonKey(name: 'isFloat')
  bool? isFloat;

  @JsonKey(name: 'selectOptions')
  List<Map<String, dynamic>>? selectOptions;

  @JsonKey(name: 'selectOptionsProviderAction')
  String? selectOptionsProviderAction;

  @JsonKey(name: 'section')
  String? section;

  @JsonKey(name: 'hidden')
  String? hidden;

  RadarrNotificationField({
    this.name,
    this.value,
    this.type,
    this.advanced,
    this.order,
    this.label,
    this.helpText,
    this.helpLink,
    this.privacy,
    this.placeholder,
    this.isFloat,
    this.selectOptions,
    this.selectOptionsProviderAction,
    this.section,
    this.hidden,
  });

  /// Returns a JSON-encoded string version of this object.
  String toJson() => json.encode(_$RadarrNotificationFieldToJson(this));

  /// Deserialize a JSON map to a [RadarrNotificationField] object.
  factory RadarrNotificationField.fromJson(Map<String, dynamic> json) =>
      _$RadarrNotificationFieldFromJson(json);
}
