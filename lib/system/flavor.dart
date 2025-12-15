import 'package:flutter/material.dart';
import 'package:zagreus/system/environment.dart';
import 'package:zagreus/vendor.dart';
import 'package:zagreus/widgets/ui.dart';

const FLAVOR_EDGE = 'edge';
const FLAVOR_BETA = 'beta';
const FLAVOR_STABLE = 'stable';

enum ZagFlavor {
  EDGE(FLAVOR_EDGE),
  BETA(FLAVOR_BETA),
  STABLE(FLAVOR_STABLE);

  final String key;
  const ZagFlavor(this.key);

  static ZagFlavor fromKey(String key) {
    switch (key) {
      case FLAVOR_EDGE:
        return ZagFlavor.EDGE;
      case FLAVOR_BETA:
        return ZagFlavor.BETA;
      case FLAVOR_STABLE:
        return ZagFlavor.STABLE;
    }
    throw Exception('Invalid ZagFlavor');
  }

  static ZagFlavor get current => ZagFlavor.fromKey(ZagEnvironment.flavor);

  static bool get isEdge => current == ZagFlavor.EDGE;
  static bool get isBeta => current == ZagFlavor.BETA;
  static bool get isStable => current == ZagFlavor.STABLE;
}

extension ZagFlavorExtension on ZagFlavor {
  bool isRunningFlavor() {
    ZagFlavor flavor = ZagFlavor.current;
    if (flavor == this) return true;

    switch (this) {
      case ZagFlavor.EDGE:
        return false;
      case ZagFlavor.BETA:
        return flavor == ZagFlavor.EDGE;
      case ZagFlavor.STABLE:
        return true;
    }
  }

  String get downloadLink {
    String base = 'https://builds.zagreus.app/#latest';
    switch (this) {
      case ZagFlavor.EDGE:
        return '$base/${this.key}/';
      case ZagFlavor.BETA:
        return '$base/${this.key}/';
      case ZagFlavor.STABLE:
        return '$base/${this.key}/';
    }
  }

  String get name {
    switch (this) {
      case ZagFlavor.EDGE:
        return 'zagreus.Edge'.tr();
      case ZagFlavor.BETA:
        return 'zagreus.Beta'.tr();
      case ZagFlavor.STABLE:
        return 'zagreus.Stable'.tr();
    }
  }

  Color get color {
    switch (this) {
      case ZagFlavor.EDGE:
        return ZagColours.red;
      case ZagFlavor.BETA:
        return ZagColours.blue;
      case ZagFlavor.STABLE:
        return ZagColours.currentAccent;
    }
  }
}
