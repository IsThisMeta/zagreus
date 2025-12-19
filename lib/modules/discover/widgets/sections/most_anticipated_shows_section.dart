import 'package:flutter/material.dart';

class MostAnticipatedShowsSection extends StatelessWidget {
  final Widget header;
  final Widget content;

  const MostAnticipatedShowsSection({
    super.key,
    required this.header,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        content,
      ],
    );
  }
}
