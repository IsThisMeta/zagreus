import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/sabnzbd.dart';

class SABnzbdHistoryHideButton extends StatefulWidget {
  final ScrollController controller;

  const SABnzbdHistoryHideButton({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<SABnzbdHistoryHideButton> createState() => _State();
}

class _State extends State<SABnzbdHistoryHideButton> {
  @override
  Widget build(BuildContext context) => ZagCard(
        context: context,
        child: Consumer<SABnzbdState>(
          builder: (context, model, widget) => ZagIconButton(
            icon: model.historyHideFailed
                ? Icons.visibility_off_rounded
                : Icons.visibility_rounded,
            onPressed: () => model.historyHideFailed = !model.historyHideFailed,
          ),
        ),
        height: ZagTextInputBar.defaultHeight,
        width: ZagTextInputBar.defaultHeight,
        margin: const EdgeInsets.only(left: 12.0),
        color: Theme.of(context).canvasColor,
      );
}
