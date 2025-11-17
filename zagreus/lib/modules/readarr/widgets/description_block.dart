import 'package:flutter/material.dart';
import 'package:zagreus/modules/readarr.dart';

class ReadarrDescriptionBlock extends StatelessWidget {
  final String description;

  const ReadarrDescriptionBlock({
    Key? key,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(description),
        ],
      ),
    );
  }
}
