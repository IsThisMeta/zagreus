import 'package:flutter/material.dart';
import 'package:zagreus/modules/readarr.dart';

class ReadarrDetailsEditButton extends StatelessWidget {
  final int authorId;

  const ReadarrDetailsEditButton({
    Key? key,
    required this.authorId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.edit),
      onPressed: () {},
      tooltip: 'Edit author $authorId',
    );
  }
}
