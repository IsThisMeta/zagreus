class QBitStatusData {
  final int dlInfoSpeed;
  final int dlInfoData;
  final int upInfoSpeed;
  final int upInfoData;
  final int dlRateLimit;
  final int upRateLimit;
  final int dhtNodes;
  final String connectionStatus;

  QBitStatusData({
    required this.dlInfoSpeed,
    required this.dlInfoData,
    required this.upInfoSpeed,
    required this.upInfoData,
    required this.dlRateLimit,
    required this.upRateLimit,
    required this.dhtNodes,
    required this.connectionStatus,
  });

  factory QBitStatusData.fromJson(Map<String, dynamic> json) {
    return QBitStatusData(
      dlInfoSpeed: json['dl_info_speed'] ?? 0,
      dlInfoData: json['dl_info_data'] ?? 0,
      upInfoSpeed: json['up_info_speed'] ?? 0,
      upInfoData: json['up_info_data'] ?? 0,
      dlRateLimit: json['dl_rate_limit'] ?? 0,
      upRateLimit: json['up_rate_limit'] ?? 0,
      dhtNodes: json['dht_nodes'] ?? 0,
      connectionStatus: json['connection_status'] ?? 'disconnected',
    );
  }

  bool get isConnected => connectionStatus == 'connected';
  bool get isFirewalled => connectionStatus == 'firewalled';
  bool get isDisconnected => connectionStatus == 'disconnected';

  String get connectionStatusText {
    switch (connectionStatus) {
      case 'connected':
        return 'Connected';
      case 'firewalled':
        return 'Firewalled';
      case 'disconnected':
        return 'Disconnected';
      default:
        return connectionStatus;
    }
  }
}
