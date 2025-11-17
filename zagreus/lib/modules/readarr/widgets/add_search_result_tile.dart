import 'package:flutter/material.dart';
import 'package:zagreus/modules/readarr.dart';

class ReadarrAddSearchResultTile extends StatelessWidget {
  final ReadarrSearchData data;

  const ReadarrAddSearchResultTile({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(data.title),
      subtitle: const Text('Add search result placeholder'),
      trailing: const Icon(Icons.add),
    );
  }
}
