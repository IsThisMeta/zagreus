import 'package:flutter/material.dart';

class RecentlyDownloadedMoviesSection extends StatelessWidget {
  final Widget header;
  final Widget list;

  const RecentlyDownloadedMoviesSection({
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
