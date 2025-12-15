import 'package:zagreus/core.dart';

part 'qualityprofile.g.dart';

@HiveType(typeId: 21, adapterName: 'ReadarrQualityProfileAdapter')
class ReadarrQualityProfile {
  @HiveField(0)
  int? id;
  @HiveField(1)
  String? name;

  ReadarrQualityProfile({
    required this.id,
    required this.name,
  });
}
