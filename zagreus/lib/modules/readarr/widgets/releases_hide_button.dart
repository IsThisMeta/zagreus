import 'package:flutter/material.dart';
import 'package:zagreus/modules/readarr.dart';

class ReadarrReleasesHideButton extends StatelessWidget {
  const ReadarrReleasesHideButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.visibility_off),
      onPressed: () {},
      tooltip: 'Hide releases',
    );
  }
}
