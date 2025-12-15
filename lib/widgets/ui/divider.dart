import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';

class ZagDivider extends Divider {
  ZagDivider({
    Key? key,
  }) : super(
          key: key,
          thickness: 1.0,
          color: ZagColours.currentAccent.dimmed(),
          indent: ZagUI.DEFAULT_MARGIN_SIZE * 5,
          endIndent: ZagUI.DEFAULT_MARGIN_SIZE * 5,
        );
}
