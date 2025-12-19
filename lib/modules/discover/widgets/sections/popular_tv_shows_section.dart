import 'package:flutter/material.dart';

class PopularTvShowsSection extends StatelessWidget {
  final Widget header;
  final Widget content;

  const PopularTvShowsSection({
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
