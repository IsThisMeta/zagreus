import 'package:flutter/material.dart';
import 'package:zagreus/modules/readarr.dart';

class ReadarrCatalogueSortButton extends StatelessWidget {
  const ReadarrCatalogueSortButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.sort),
      onPressed: () {},
      tooltip: 'Sort catalogue',
    );
  }
}
