import 'package:flutter/material.dart';
import 'package:zagreus/modules/readarr.dart';

class ReadarrAuthorNavigationBar extends StatelessWidget {
  const ReadarrAuthorNavigationBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      color: Colors.grey[300],
      child: const Center(child: Text('Author Navigation Bar')),
    );
  }
}
