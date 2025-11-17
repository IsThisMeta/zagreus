import 'package:flutter/material.dart';
import 'package:zagreus/modules/readarr.dart';

class ReadarrDetailsSettingsButton extends StatelessWidget {
  final ReadarrCatalogueData data;

  const ReadarrDetailsSettingsButton({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.settings),
      onPressed: () {},
      tooltip: 'Settings for ${data.title}',
    );
  }
}
