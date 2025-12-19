import 'package:flutter/material.dart';

class RecentlyDownloadedShowsSection extends StatelessWidget {
  final Widget header;
  final List<Widget> items;
  final EdgeInsets contentPadding;

  const RecentlyDownloadedShowsSection({
    super.key,
    required this.header,
    required this.items,
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
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }
}
