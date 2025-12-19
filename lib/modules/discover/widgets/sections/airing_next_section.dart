import 'package:flutter/material.dart';

class AiringNextSection extends StatelessWidget {
  final Widget header;
  final Widget content;
  final EdgeInsets contentPadding;

  const AiringNextSection({
    super.key,
    required this.header,
    required this.content,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        Padding(
          padding: contentPadding,
          child: content,
        ),
      ],
    );
  }
}
