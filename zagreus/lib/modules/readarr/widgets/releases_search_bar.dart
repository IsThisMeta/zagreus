import 'package:flutter/material.dart';
import 'package:zagreus/modules/readarr.dart';

class ReadarrReleasesSearchBar extends StatelessWidget {
  const ReadarrReleasesSearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Search releases...',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }
}
