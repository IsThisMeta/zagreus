import 'package:flutter/material.dart';
import 'package:zagreus/modules/readarr.dart';

class ReadarrMissing extends StatelessWidget {
  const ReadarrMissing({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Missing Books')),
      body: const Center(child: Text('Missing Books - Coming Soon')),
    );
  }
}
