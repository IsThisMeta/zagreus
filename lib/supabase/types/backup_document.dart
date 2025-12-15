class ZagSupabaseBackupDocument {
  final String? id;
  final int? timestamp;
  final String? title;
  final String? description;

  ZagSupabaseBackupDocument({
    required this.id,
    required this.timestamp,
    required this.title,
    required this.description,
  });

  factory ZagSupabaseBackupDocument.fromMap(
    Map<String, dynamic> data,
  ) {
    return ZagSupabaseBackupDocument(
      id: data['id'],
      timestamp: data['timestamp'],
      title: data['title'],
      description: data['description'],
    );
  }

  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'timestamp': timestamp,
      'description': description,
    };
  }
}