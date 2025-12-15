import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';

part 'list_view_option.g.dart';

const _BLOCK_VIEW = 'BLOCK_VIEW';
const _GRID_VIEW = 'GRID_VIEW';

@HiveType(typeId: 29, adapterName: 'ZagListViewOptionAdapter')
enum ZagListViewOption {
  @HiveField(0)
  BLOCK_VIEW(_BLOCK_VIEW),
  @HiveField(1)
  GRID_VIEW(_GRID_VIEW);

  final String key;
  const ZagListViewOption(this.key);

  static ZagListViewOption? fromKey(String? key) {
    switch (key) {
      case _BLOCK_VIEW:
        return ZagListViewOption.BLOCK_VIEW;
      case _GRID_VIEW:
        return ZagListViewOption.GRID_VIEW;
    }
    return null;
  }
}

extension ZagListViewOptionExtension on ZagListViewOption {
  String get readable {
    switch (this) {
      case ZagListViewOption.BLOCK_VIEW:
        return 'zagreus.BlockView'.tr();
      case ZagListViewOption.GRID_VIEW:
        return 'zagreus.GridView'.tr();
    }
  }

  IconData get icon {
    switch (this) {
      case ZagListViewOption.BLOCK_VIEW:
        return Icons.view_list_rounded;
      case ZagListViewOption.GRID_VIEW:
        return Icons.grid_view_rounded;
    }
  }
}
