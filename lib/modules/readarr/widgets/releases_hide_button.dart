import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/scroll_controller.dart';
import 'package:zagreus/modules/readarr.dart';

class ReadarrReleasesHideButton extends StatefulWidget {
  final ScrollController controller;

  const ReadarrReleasesHideButton({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<ReadarrReleasesHideButton> createState() => _State();
}

class _State extends State<ReadarrReleasesHideButton> {
  @override
  Widget build(BuildContext context) => ZagCard(
        context: context,
        child: Consumer<ReadarrState>(
          builder: (context, model, widget) => ZagIconButton(
            icon: model.hideRejectedReleases
                ? Icons.visibility_off_rounded
                : Icons.visibility_rounded,
            onPressed: () {
              model.hideRejectedReleases = !model.hideRejectedReleases;
              this.widget.controller.animateToStart();
            },
          ),
        ),
        height: ZagTextInputBar.defaultHeight,
        width: ZagTextInputBar.defaultHeight,
        margin: ZagTextInputBar.appBarMargin
            .subtract(const EdgeInsets.only(left: 12.0)) as EdgeInsets,
        color: Theme.of(context).canvasColor,
      );
}
