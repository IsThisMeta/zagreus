import 'package:flutter/material.dart';
import 'package:zagreus/modules/readarr.dart';

class ReadarrCatalogueTile extends StatelessWidget {
  final ReadarrCatalogueData data;

  const ReadarrCatalogueTile({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(data.title),
      subtitle: const Text('Author tile placeholder'),
      leading: const Icon(Icons.person),
    );
  }
}
