class LidarrReleaseData {
  String title;
  String guid;
  String quality;
  String protocol;
  String indexer;
  String infoUrl;
  bool approved;
  int releaseWeight;
  int size;
  int indexerId;
  int? seeders;
  int? leechers;
  double ageHours;
  List<dynamic> rejections;
  List<String>? customFormats;
  int? customFormatScore;

  LidarrReleaseData({
    required this.title,
    required this.guid,
    required this.quality,
    required this.protocol,
    required this.indexer,
    required this.infoUrl,
    required this.approved,
    required this.releaseWeight,
    required this.size,
    required this.indexerId,
    required this.ageHours,
    required this.rejections,
    this.seeders,
    this.leechers,
    this.customFormats,
    this.customFormatScore,
  });

  bool get isTorrent {
    return protocol == 'torrent';
  }

  String? zagCustomFormatScore({bool nullOnEmpty = false}) {
    if ((customFormatScore ?? 0) != 0) {
      String prefix = customFormatScore! > 0 ? '+' : '';
      return '$prefix$customFormatScore';
    }
    if (nullOnEmpty) return null;
    return '—';
  }
}
