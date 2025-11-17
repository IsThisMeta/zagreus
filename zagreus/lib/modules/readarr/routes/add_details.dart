import 'package:flutter/material.dart';
import 'package:zagreus/modules/readarr.dart';

class AddAuthorDetailsRoute extends StatelessWidget {
  final ReadarrSearchData? data;

  const AddAuthorDetailsRoute({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Author Details')),
      body: const Center(child: Text('Add Author Details - Coming Soon')),
    );
  }
}
