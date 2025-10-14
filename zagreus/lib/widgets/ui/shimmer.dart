import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:shimmer/shimmer.dart';

class ZagShimmer extends StatelessWidget {
  final Widget child;

  const ZagShimmer({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      child: child,
      baseColor: Theme.of(context).primaryColor,
      highlightColor: ZagColours.currentAccent,
    );
  }
}
