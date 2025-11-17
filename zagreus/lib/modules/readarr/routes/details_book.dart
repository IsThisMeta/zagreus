import 'package:flutter/material.dart';
import 'package:zagreus/modules/readarr.dart';

class AuthorBookDetailsRoute extends StatelessWidget {
  final int authorId;
  final int bookId;
  final bool monitored;

  const AuthorBookDetailsRoute({
    Key? key,
    required this.authorId,
    required this.bookId,
    required this.monitored,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Details')),
      body: const Center(child: Text('Book Details - Coming Soon')),
    );
  }
}
