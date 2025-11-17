import 'package:flutter/material.dart';
import 'package:zagreus/modules/readarr.dart';

class ReadarrReleasesSortButton extends StatelessWidget {
  const ReadarrReleasesSortButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.sort),
      onPressed: () {},
      tooltip: 'Sort releases',
    );
  }
}
