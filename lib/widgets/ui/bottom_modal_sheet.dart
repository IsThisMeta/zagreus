import 'package:flutter/material.dart';
import 'package:zagreus/system/state.dart';
import 'package:zagreus/widgets/ui.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class ZagBottomModalSheet<T> {
  @protected
  Future<T?> showModal({
    Widget Function(BuildContext context)? builder,
  }) async {
    return showBarModalBottomSheet<T>(
      context: ZagState.context,
      expand: false,
      backgroundColor:
          ZagTheme.isAMOLEDTheme ? Colors.black : ZagColours.primary,
      shape: ZagShapeBorder(
        topOnly: true,
        useBorder: ZagUI.shouldUseBorder,
      ),
      builder: builder ?? this.builder as Widget Function(BuildContext),
      closeProgressThreshold: 0.90,
      elevation: ZagUI.ELEVATION,
      overlayStyle: ZagTheme().overlayStyle,
    );
  }

  Widget? builder(BuildContext context) => null;

  Future<dynamic> show({
    Widget Function(BuildContext context)? builder,
  }) async =>
      showModal(builder: builder);
}
