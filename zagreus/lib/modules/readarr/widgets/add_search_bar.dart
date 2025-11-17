import 'package:flutter/material.dart';
import 'package:zagreus/modules/readarr.dart';

class ReadarrAddSearchBar extends StatelessWidget {
  const ReadarrAddSearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Search for authors to add...',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }
}
