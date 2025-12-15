import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';

class ZagTableCard extends StatelessWidget {
  final String? title;
  final List<ZagTableContent>? content;
  final List<ZagButton>? buttons;

  const ZagTableCard({
    Key? key,
    this.content,
    this.buttons,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagCard(
      context: context,
      child: Padding(
        child: _body(),
        padding: EdgeInsets.only(
          left: ZagUI.DEFAULT_MARGIN_SIZE / 2,
          right: ZagUI.DEFAULT_MARGIN_SIZE / 2,
          top: ZagUI.DEFAULT_MARGIN_SIZE - ZagUI.DEFAULT_MARGIN_SIZE / 4,
          bottom: buttons?.isEmpty ?? true
              ? ZagUI.DEFAULT_MARGIN_SIZE - ZagUI.DEFAULT_MARGIN_SIZE / 4
              : 0,
        ),
      ),
    );
  }

  Widget _body() {
    return Column(
      children: [
        if (title?.isNotEmpty ?? false) _title(),
        ..._content(),
        _buttons(),
      ],
    );
  }

  Widget _title() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: ZagUI.DEFAULT_MARGIN_SIZE),
          child: ZagText.title(text: title!),
        ),
      ],
    );
  }

  List<Widget> _content() {
    return content!
        .map((child) => Padding(
              child: child,
              padding: const EdgeInsets.symmetric(
                horizontal: ZagUI.DEFAULT_MARGIN_SIZE / 2,
              ),
            ))
        .toList();
  }

  Widget _buttons() {
    if (buttons == null) return Container(height: 0.0);
    return Padding(
      child: Row(
        children:
            buttons!.map<Widget>((button) => Expanded(child: button)).toList(),
      ),
      padding: const EdgeInsets.only(
        top: ZagUI.DEFAULT_MARGIN_SIZE / 2 - ZagUI.DEFAULT_MARGIN_SIZE / 4,
        bottom: ZagUI.DEFAULT_MARGIN_SIZE / 2,
      ),
    );
  }
}
