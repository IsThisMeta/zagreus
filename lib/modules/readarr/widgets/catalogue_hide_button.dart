import 'package:flutter/material.dart';
import 'package:zagreus/modules/readarr.dart';

class ReadarrCatalogueHideButton extends StatelessWidget {
  const ReadarrCatalogueHideButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.visibility_off),
      onPressed: () {},
      tooltip: 'Hide unmonitored',
    );
  }
}
