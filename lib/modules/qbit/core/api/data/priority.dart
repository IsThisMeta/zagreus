enum QBitPriority {
  doNotDownload(0, 'Do Not Download'),
  normal(1, 'Normal'),
  high(6, 'High'),
  maximum(7, 'Maximum');

  final int value;
  final String name;

  const QBitPriority(this.value, this.name);

  static QBitPriority fromValue(int value) {
    switch (value) {
      case 0:
        return QBitPriority.doNotDownload;
      case 1:
        return QBitPriority.normal;
      case 6:
        return QBitPriority.high;
      case 7:
        return QBitPriority.maximum;
      default:
        return QBitPriority.normal;
    }
  }
}

enum QBitFilePriority {
  doNotDownload(0, 'Do Not Download'),
  normal(1, 'Normal'),
  high(6, 'High'),
  maximum(7, 'Maximum'),
  mixed(-1, 'Mixed');

  final int value;
  final String name;

  const QBitFilePriority(this.value, this.name);

  static QBitFilePriority fromValue(int value) {
    switch (value) {
      case 0:
        return QBitFilePriority.doNotDownload;
      case 1:
        return QBitFilePriority.normal;
      case 6:
        return QBitFilePriority.high;
      case 7:
        return QBitFilePriority.maximum;
      default:
        return QBitFilePriority.mixed;
    }
  }
}
