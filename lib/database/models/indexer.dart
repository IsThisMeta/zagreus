import 'package:zagreus/core.dart';

part 'indexer.g.dart';

@JsonSerializable()
@HiveType(typeId: 1, adapterName: 'ZagIndexerAdapter')
class ZagIndexer extends HiveObject {
  @JsonKey()
  @HiveField(0, defaultValue: '')
  String displayName;

  @JsonKey()
  @HiveField(1, defaultValue: '')
  String host;

  @JsonKey(name: 'key')
  @HiveField(2, defaultValue: '')
  String apiKey;

  @JsonKey()
  @HiveField(3, defaultValue: <String, String>{})
  Map<String, String> headers;

  @JsonKey(defaultValue: false)
  @HiveField(4, defaultValue: false)
  bool isProwlarr;

  ZagIndexer._internal({
    required this.displayName,
    required this.host,
    required this.apiKey,
    required this.headers,
    required this.isProwlarr,
  });

  factory ZagIndexer({
    String? displayName,
    String? host,
    String? apiKey,
    Map<String, String>? headers,
    bool? isProwlarr,
  }) {
    return ZagIndexer._internal(
      displayName: displayName ?? '',
      host: host ?? '',
      apiKey: apiKey ?? '',
      headers: headers ?? {},
      isProwlarr: isProwlarr ?? false,
    );
  }

  @override
  String toString() => json.encode(this.toJson());

  Map<String, dynamic> toJson() => _$ZagIndexerToJson(this);

  factory ZagIndexer.fromJson(Map<String, dynamic> json) {
    return _$ZagIndexerFromJson(json);
  }

  factory ZagIndexer.clone(ZagIndexer profile) {
    return ZagIndexer.fromJson(profile.toJson());
  }

  factory ZagIndexer.get(String key) {
    return ZagBox.indexers.read(key)!;
  }
}
