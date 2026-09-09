class QBitTrackerData {
  final String url;
  final int status;
  final int tier;
  final int numPeers;
  final int numSeeds;
  final int numLeeches;
  final int numDownloaded;
  final String message;

  QBitTrackerData({
    required this.url,
    required this.status,
    required this.tier,
    required this.numPeers,
    required this.numSeeds,
    required this.numLeeches,
    required this.numDownloaded,
    required this.message,
  });

  factory QBitTrackerData.fromJson(Map<String, dynamic> json) {
    return QBitTrackerData(
      url: json['url'] ?? '',
      status: json['status'] ?? 0,
      tier: json['tier'] ?? 0,
      numPeers: json['num_peers'] ?? 0,
      numSeeds: json['num_seeds'] ?? 0,
      numLeeches: json['num_leeches'] ?? 0,
      numDownloaded: json['num_downloaded'] ?? 0,
      message: json['msg'] ?? '',
    );
  }

  static List<QBitTrackerData> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => QBitTrackerData.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  String get statusText {
    switch (status) {
      case 0:
        return 'Disabled';
      case 1:
        return 'Not Contacted';
      case 2:
        return 'Working';
      case 3:
        return 'Updating';
      case 4:
        return 'Not Working';
      default:
        return 'Unknown';
    }
  }

  bool get isWorking => status == 2;
  bool get isDisabled => status == 0;
  bool get isNotWorking => status == 4;
}
