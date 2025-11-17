import 'package:flutter/material.dart';
import 'package:zagreus/modules/readarr.dart';

class AuthorEditRoute extends StatelessWidget {
  final ReadarrCatalogueData? data;
  final int authorId;

  const AuthorEditRoute({
    Key? key,
    required this.data,
    required this.authorId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Author')),
      body: const Center(child: Text('Edit Author - Coming Soon')),
    );
  }
}
