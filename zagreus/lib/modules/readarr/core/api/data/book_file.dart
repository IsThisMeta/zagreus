class ReadarrBookFileData {
  int id;
  int? bookID;
  int? authorID;
  String? path;
  int? size;
  DateTime? dateAdded;
  String? quality;

  ReadarrBookFileData({
    required this.id,
    this.bookID,
    this.authorID,
    this.path,
    this.size,
    this.dateAdded,
    this.quality,
  });
}
