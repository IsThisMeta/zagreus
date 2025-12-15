part of 'notification.dart';

/// Model for notification field configuration
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class SonarrNotificationField {
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

  SonarrNotificationField({
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

  /// Deserialize a JSON map to a [SonarrNotificationField] object.
  factory SonarrNotificationField.fromJson(Map<String, dynamic> json) =>
      _$SonarrNotificationFieldFromJson(json);

  /// Serialize a [SonarrNotificationField] object to a JSON map.
  Map<String, dynamic> toJson() => _$SonarrNotificationFieldToJson(this);
}