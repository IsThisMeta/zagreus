import 'package:flutter/material.dart';
import 'package:zagreus/modules/readarr.dart';

class AuthorBookReleasesRoute extends StatelessWidget {
  final int bookId;

  const AuthorBookReleasesRoute({
    Key? key,
    required this.bookId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Releases')),
      body: const Center(child: Text('Book Releases - Coming Soon')),
    );
  }
}
