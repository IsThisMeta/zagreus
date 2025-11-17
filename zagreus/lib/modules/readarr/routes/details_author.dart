import 'package:flutter/material.dart';
import 'package:zagreus/modules/readarr.dart';

class AuthorDetailsRoute extends StatelessWidget {
  final ReadarrCatalogueData? data;
  final int authorId;

  const AuthorDetailsRoute({
    Key? key,
    required this.data,
    required this.authorId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Author Details')),
      body: const Center(child: Text('Author Details - Coming Soon')),
    );
  }
}
