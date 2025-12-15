import 'package:zagreus/core.dart';

part 'external_module.g.dart';

@JsonSerializable()
@HiveType(typeId: 26, adapterName: 'ZagExternalModuleAdapter')
class ZagExternalModule extends HiveObject {
  @JsonKey()
  @HiveField(0, defaultValue: '')
  String displayName;

  @JsonKey()
  @HiveField(1, defaultValue: '')
  String host;

  ZagExternalModule({
    this.displayName = '',
    this.host = '',
  });

  @override
  String toString() => json.encode(this.toJson());

  Map<String, dynamic> toJson() => _$ZagExternalModuleToJson(this);

  factory ZagExternalModule.fromJson(Map<String, dynamic> json) {
    return _$ZagExternalModuleFromJson(json);
  }

  factory ZagExternalModule.clone(ZagExternalModule profile) {
    return ZagExternalModule.fromJson(profile.toJson());
  }

  factory ZagExternalModule.get(String key) {
    return ZagBox.externalModules.read(key)!;
  }
}
