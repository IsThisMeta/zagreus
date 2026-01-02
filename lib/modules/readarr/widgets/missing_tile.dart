import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
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
      subtitle: Text('readarr.MissingBookPlaceholder'.tr()),
      leading: const Icon(Icons.error_outline),
    );
  }
}
