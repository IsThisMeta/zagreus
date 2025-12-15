import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';

part 'indexer_icon.g.dart';

const _GENERIC = 'generic';
const _DOGNZB = 'dognzb';
const _DRUNKENSLUG = 'drunkenslug';
const _NZBFINDER = 'nzbfinder';
const _NZBGEEK = 'nzbgeek';
const _NZBHYDRA = 'nzbhydra';
const _NZBSU = 'nzbsu';

@JsonEnum()
@HiveType(typeId: 22, adapterName: 'ZagIndexerIconAdapter')
enum ZagIndexerIcon {
  @JsonValue(_GENERIC)
  @HiveField(0)
  GENERIC(_GENERIC),

  @JsonValue(_DOGNZB)
  @HiveField(1)
  DOGNZB(_DOGNZB),

  @JsonValue(_DRUNKENSLUG)
  @HiveField(2)
  DRUNKENSLUG(_DRUNKENSLUG),

  @JsonValue(_NZBFINDER)
  @HiveField(3)
  NZBFINDER(_NZBFINDER),

  @JsonValue(_NZBGEEK)
  @HiveField(4)
  NZBGEEK(_NZBGEEK),

  @JsonValue(_NZBHYDRA)
  @HiveField(5)
  NZBHYDRA(_NZBHYDRA),

  @JsonValue(_NZBSU)
  @HiveField(6)
  NZBSU(_NZBSU);

  final String key;
  const ZagIndexerIcon(this.key);

  static ZagIndexerIcon fromKey(String key) {
    switch (key) {
      case _DOGNZB:
        return ZagIndexerIcon.DOGNZB;
      case _DRUNKENSLUG:
        return ZagIndexerIcon.DRUNKENSLUG;
      case _NZBFINDER:
        return ZagIndexerIcon.NZBFINDER;
      case _NZBGEEK:
        return ZagIndexerIcon.NZBGEEK;
      case _NZBHYDRA:
        return ZagIndexerIcon.NZBHYDRA;
      case _NZBSU:
        return ZagIndexerIcon.NZBSU;
      default:
        return ZagIndexerIcon.GENERIC;
    }
  }

  String get name {
    switch (this) {
      case ZagIndexerIcon.GENERIC:
        return 'Generic';
      case ZagIndexerIcon.DOGNZB:
        return 'DOGnzb';
      case ZagIndexerIcon.DRUNKENSLUG:
        return 'DrunkenSlug';
      case ZagIndexerIcon.NZBFINDER:
        return 'NZBFinder';
      case ZagIndexerIcon.NZBGEEK:
        return 'NZBGeek';
      case ZagIndexerIcon.NZBHYDRA:
        return 'NZBHydra2';
      case ZagIndexerIcon.NZBSU:
        return 'NZB.su';
    }
  }

  IconData get icon {
    switch (this) {
      case ZagIndexerIcon.GENERIC:
        return Icons.rss_feed_rounded;
      case ZagIndexerIcon.DOGNZB:
        return Icons.rss_feed_rounded;
      case ZagIndexerIcon.DRUNKENSLUG:
        return Icons.rss_feed_rounded;
      case ZagIndexerIcon.NZBFINDER:
        return Icons.rss_feed_rounded;
      case ZagIndexerIcon.NZBGEEK:
        return Icons.rss_feed_rounded;
      case ZagIndexerIcon.NZBHYDRA:
        return Icons.rss_feed_rounded;
      case ZagIndexerIcon.NZBSU:
        return Icons.rss_feed_rounded;
    }
  }
}
