import 'package:flutter/material.dart';
import 'package:zagreus/modules/readarr.dart';

class ReadarrCatalogueSearchBar extends StatelessWidget {
  const ReadarrCatalogueSearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Search catalogue...',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
