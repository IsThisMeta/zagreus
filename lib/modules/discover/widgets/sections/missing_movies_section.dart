import 'package:flutter/material.dart';

class MissingMoviesSection extends StatelessWidget {
  final Widget header;
  final Widget list;

  const MissingMoviesSection({
    super.key,
    required this.header,
    required this.list,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        list,
      ],
    );
  }
}
