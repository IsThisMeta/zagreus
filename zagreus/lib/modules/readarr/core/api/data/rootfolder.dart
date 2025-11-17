import 'package:zagreus/core.dart';

part 'rootfolder.g.dart';

@HiveType(typeId: 22, adapterName: 'ReadarrRootFolderAdapter')
class ReadarrRootFolder {
  @HiveField(0)
  int? id;
  @HiveField(1)
  String? path;
  @HiveField(2)
  int? freeSpace;

  factory ReadarrRootFolder.empty() => ReadarrRootFolder(
        id: -1,
        path: '',
        freeSpace: 0,
      );

  ReadarrRootFolder({
    required this.id,
    required this.path,
    required this.freeSpace,
  });
}
