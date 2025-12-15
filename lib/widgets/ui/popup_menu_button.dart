import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zagreus/core.dart';

class ZagPopupMenuButton<T> extends PopupMenuButton<T> {
  ZagPopupMenuButton({
    required PopupMenuItemSelected<T> onSelected,
    required PopupMenuItemBuilder<T> itemBuilder,
    Key? key,
    IconData? icon,
    Widget? child,
    String? tooltip,
  }) : super(
          key: key,
          shape: ZagUI.shapeBorder,
          tooltip: tooltip,
          icon: icon == null ? null : Icon(icon),
          child: child,
          onSelected: (result) {
            HapticFeedback.selectionClick();
            onSelected(result);
          },
          itemBuilder: itemBuilder,
        );
}
