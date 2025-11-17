import 'package:flutter/material.dart';
import 'package:zagreus/modules/readarr.dart';

class ReadarrMissingTile extends StatelessWidget {
  final ReadarrMissingData data;

  const ReadarrMissingTile({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(data.title),
      subtitle: const Text('Missing book placeholder'),
      leading: const Icon(Icons.error_outline),
    );
  }
}
