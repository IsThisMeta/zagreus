import 'package:zagreus/core.dart';

part 'metadata.g.dart';

@HiveType(typeId: 20, adapterName: 'ReadarrMetadataProfileAdapter')
class ReadarrMetadataProfile {
  @HiveField(0)
  int? id;
  @HiveField(1)
  String? name;

  ReadarrMetadataProfile({
    required this.id,
    required this.name,
  });
}
