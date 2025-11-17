import 'package:flutter/material.dart';
import 'package:zagreus/modules/readarr.dart';

class ReadarrDetailsOverview extends StatelessWidget {
  final ReadarrCatalogueData data;

  const ReadarrDetailsOverview({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text('Author details overview placeholder'),
        ],
      ),
    );
  }
}
