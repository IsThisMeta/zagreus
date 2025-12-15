import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/string/string.dart';
import 'package:zagreus/extensions/string/links.dart';

enum _Type {
  CONTENT,
  SPACER,
}

class ZagTableContent extends StatelessWidget {
  final String? title;
  final String? body;
  final String? url;
  final bool bodyIsUrl;
  final int titleFlex;
  final int bodyFlex;
  final double spacerSize;
  final TextAlign titleAlign;
  final TextAlign bodyAlign;
  final _Type type;

  const ZagTableContent._({
    Key? key,
    this.title,
    this.body,
    this.url,
    this.bodyIsUrl = false,
    this.titleAlign = TextAlign.end,
    this.bodyAlign = TextAlign.start,
    this.titleFlex = 5,
    this.bodyFlex = 10,
    this.spacerSize = ZagUI.DEFAULT_MARGIN_SIZE,
    required this.type,
  });

  factory ZagTableContent.spacer({
    Key? key,
    double spacerSize = ZagUI.DEFAULT_MARGIN_SIZE,
  }) =>
      ZagTableContent._(
        key: key,
        type: _Type.SPACER,
        spacerSize: spacerSize,
      );

  factory ZagTableContent({
    Key? key,
    String? title,
    required String? body,
    String? url,
    bool bodyIsUrl = false,
    TextAlign titleAlign = TextAlign.end,
    TextAlign bodyAlign = TextAlign.start,
    int titleFlex = 1,
    int bodyFlex = 2,
  }) =>
      ZagTableContent._(
        key: key,
        title: title,
        body: body,
        url: url,
        bodyIsUrl: bodyIsUrl,
        titleAlign: titleAlign,
        bodyAlign: bodyAlign,
        titleFlex: titleFlex,
        bodyFlex: bodyFlex,
        type: _Type.CONTENT,
      );

  @override
  Widget build(BuildContext context) {
    if (type == _Type.SPACER) return SizedBox(height: spacerSize);
    return Row(
      children: [
        if (title != null) _title(context),
        _subtitle(context),
      ],
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  Widget _title(BuildContext context) {
    return Expanded(
      child: Padding(
        child: Text(
          title?.toUpperCase() ?? ZagUI.TEXT_EMDASH,
          textAlign: titleAlign,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white.withOpacity(0.5)
                : Colors.black.withOpacity(0.5),
            fontSize: ZagUI.FONT_SIZE_H3,
          ),
        ),
        padding: const EdgeInsets.only(
          top: ZagUI.DEFAULT_MARGIN_SIZE / 4,
          bottom: ZagUI.DEFAULT_MARGIN_SIZE / 4,
          right: ZagUI.DEFAULT_MARGIN_SIZE / 4,
        ),
      ),
      flex: titleFlex,
    );
  }

  Widget _subtitle(BuildContext context) {
    return Expanded(
      child: InkWell(
        child: Padding(
          child: Text(
            body ?? ZagUI.TEXT_EMDASH,
            textAlign: bodyAlign,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.white.withOpacity(0.9)
                  : Colors.black.withOpacity(0.9),
              fontSize: ZagUI.FONT_SIZE_H3,
            ),
          ),
          padding: const EdgeInsets.only(
            top: ZagUI.DEFAULT_MARGIN_SIZE / 4,
            bottom: ZagUI.DEFAULT_MARGIN_SIZE / 4,
            left: ZagUI.DEFAULT_MARGIN_SIZE / 2,
          ),
        ),
        borderRadius: BorderRadius.circular(ZagUI.BORDER_RADIUS),
        onTap: _onTap(),
        onLongPress: _onLongPress(),
      ),
      flex: bodyFlex,
    );
  }

  void Function()? _onTap() {
    final sanitizedUrl = url ?? '';
    if (sanitizedUrl.isEmpty && !bodyIsUrl) return null;
    if (sanitizedUrl.isNotEmpty) return sanitizedUrl.openLink;
    return body!.openLink;
  }

  void Function()? _onLongPress() {
    final sanitizedUrl = url ?? '';
    if (sanitizedUrl.isEmpty && !bodyIsUrl) return null;
    if (sanitizedUrl.isNotEmpty) return sanitizedUrl.copyToClipboard;
    return body!.copyToClipboard;
  }
}
