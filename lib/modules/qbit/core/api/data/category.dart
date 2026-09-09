class QBitCategoryData {
  final String name;
  final String savePath;

  QBitCategoryData({
    required this.name,
    required this.savePath,
  });

  factory QBitCategoryData.fromJson(String name, Map<String, dynamic> json) {
    return QBitCategoryData(
      name: name,
      savePath: json['savePath'] ?? '',
    );
  }

  static List<QBitCategoryData> fromCategoriesJson(Map<String, dynamic> json) {
    final List<QBitCategoryData> categories = [
      QBitCategoryData(name: '', savePath: ''), // No category option
    ];
    json.forEach((key, value) {
      categories.add(QBitCategoryData.fromJson(key, value as Map<String, dynamic>));
    });
    return categories;
  }

  String get displayName => name.isEmpty ? 'No Category' : name;
}
