import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';

class ZagButtonContainer extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets padding;
  final int buttonsPerRow;
  final double? buttonHeight;

  const ZagButtonContainer({
    Key? key,
    required this.children,
    this.buttonsPerRow = 2,
    this.padding = const EdgeInsets.symmetric(horizontal: 6.0),
    this.buttonHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children
            .chunked(buttonsPerRow)
            .map((child) => Row(
                  children: child
                      .map<Expanded>((button) => Expanded(
                            child: buttonHeight == null
                                ? button
                                : SizedBox(
                                    height: buttonHeight,
                                    child: button,
                                  ),
                          ))
                      .toList(),
                ))
            .toList(),
      ),
      padding: padding,
    );
  }
}
