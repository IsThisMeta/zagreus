// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queue_status_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RadarrQueueStatusMessage _$RadarrQueueStatusMessageFromJson(
        Map<String, dynamic> json) =>
    RadarrQueueStatusMessage(
      title: json['title'] as String?,
      messages: (json['messages'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$RadarrQueueStatusMessageToJson(
    RadarrQueueStatusMessage instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('title', instance.title);
  writeNotNull('messages', instance.messages);
  return val;
}
