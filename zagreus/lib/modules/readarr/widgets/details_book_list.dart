import 'package:flutter/material.dart';
import 'package:zagreus/modules/readarr.dart';

class ReadarrDetailsBookList extends StatelessWidget {
  final int authorId;

  const ReadarrDetailsBookList({
    Key? key,
    required this.authorId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Books for author ID: $authorId'),
          const SizedBox(height: 8),
          const Text('Book list placeholder'),
        ],
      ),
    );
  }
}
