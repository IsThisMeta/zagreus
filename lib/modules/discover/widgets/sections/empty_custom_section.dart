import 'package:flutter/material.dart';

class EmptyCustomSection extends StatelessWidget {
  final Widget header;
  final Widget body;

  const EmptyCustomSection({
    super.key,
    required this.header,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        body,
      ],
    );
  }
}
