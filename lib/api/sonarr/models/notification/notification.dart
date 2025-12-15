import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'notification.g.dart';
part 'notification_field.dart';

/// Model for a Sonarr notification/webhook.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class SonarrNotification {
  @JsonKey(name: 'id')
  int? id;

  @JsonKey(name: 'name')
  String? name;

  @JsonKey(name: 'fields')
  List<SonarrNotificationField>? fields;

  @JsonKey(name: 'implementation')
  String? implementation;

  @JsonKey(name: 'implementationName')
  String? implementationName;

  @JsonKey(name: 'configContract')
  String? configContract;

  @JsonKey(name: 'infoLink')
  String? infoLink;

  @JsonKey(name: 'message')
  Map<String, dynamic>? message;

  @JsonKey(name: 'tags')
  List<int>? tags;

  @JsonKey(name: 'presets')
  List<SonarrNotification>? presets;

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

  @JsonKey(name: 'onSeriesAdd')
  bool? onSeriesAdd;

  @JsonKey(name: 'onSeriesDelete')
  bool? onSeriesDelete;

  @JsonKey(name: 'onEpisodeFileDelete')
  bool? onEpisodeFileDelete;

  @JsonKey(name: 'onEpisodeFileDeleteForUpgrade')
  bool? onEpisodeFileDeleteForUpgrade;

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

  @JsonKey(name: 'supportsOnSeriesAdd')
  bool? supportsOnSeriesAdd;

  @JsonKey(name: 'supportsOnSeriesDelete')
  bool? supportsOnSeriesDelete;

  @JsonKey(name: 'supportsOnEpisodeFileDelete')
  bool? supportsOnEpisodeFileDelete;

  @JsonKey(name: 'supportsOnEpisodeFileDeleteForUpgrade')
  bool? supportsOnEpisodeFileDeleteForUpgrade;

  @JsonKey(name: 'supportsOnHealthIssue')
  bool? supportsOnHealthIssue;

  @JsonKey(name: 'supportsOnApplicationUpdate')
  bool? supportsOnApplicationUpdate;

  @JsonKey(name: 'supportsOnManualInteractionRequired')
  bool? supportsOnManualInteractionRequired;

  SonarrNotification({
    this.id,
    this.name,
    this.fields,
    this.implementation,
    this.implementationName,
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
    this.onSeriesAdd,
    this.onSeriesDelete,
    this.onEpisodeFileDelete,
    this.onEpisodeFileDeleteForUpgrade,
    this.onHealthIssue,
    this.includeHealthWarnings,
    this.onApplicationUpdate,
    this.onManualInteractionRequired,
    this.supportsOnGrab,
    this.supportsOnDownload,
    this.supportsOnUpgrade,
    this.supportsOnRename,
    this.supportsOnSeriesAdd,
    this.supportsOnSeriesDelete,
    this.supportsOnEpisodeFileDelete,
    this.supportsOnEpisodeFileDeleteForUpgrade,
    this.supportsOnHealthIssue,
    this.supportsOnApplicationUpdate,
    this.supportsOnManualInteractionRequired,
  });

  /// Create a new webhook notification with Zagreus settings
  factory SonarrNotification.webhook({
    required String name,
    required String url,
    String? username,
    String? password,
    List<int>? tags,
  }) {
    return SonarrNotification(
      name: name,
      implementation: 'Webhook',
      implementationName: 'Webhook',
      configContract: 'WebhookSettings',
      fields: [
        SonarrNotificationField(
          name: 'url',
          value: url,
        ),
        SonarrNotificationField(
          name: 'method',
          value: 1, // POST
        ),
        SonarrNotificationField(
          name: 'username',
          value: username ?? '',
        ),
        SonarrNotificationField(
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
      onSeriesAdd: true,
      onSeriesDelete: true,
      onEpisodeFileDelete: true,
      onEpisodeFileDeleteForUpgrade: true,
      onHealthIssue: true,
      includeHealthWarnings: false,
      onApplicationUpdate: false,
      onManualInteractionRequired: true,
    );
  }

  /// Returns a JSON-encoded string version of this object.
  String toJson() => json.encode(_$SonarrNotificationToJson(this));

  /// Deserialize a JSON map to a [SonarrNotification] object.
  factory SonarrNotification.fromJson(Map<String, dynamic> json) =>
      _$SonarrNotificationFromJson(json);
}