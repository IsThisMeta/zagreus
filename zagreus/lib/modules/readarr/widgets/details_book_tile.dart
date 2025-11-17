import 'package:flutter/material.dart';
import 'package:zagreus/modules/readarr.dart';

class ReadarrDetailsBookTile extends StatelessWidget {
  final ReadarrBookData data;

  const ReadarrDetailsBookTile({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(data.title),
      subtitle: const Text('Book tile placeholder'),
      leading: const Icon(Icons.book),
    );
  }
}
