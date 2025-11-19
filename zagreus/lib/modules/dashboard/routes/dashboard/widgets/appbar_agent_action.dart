import 'package:flutter/material.dart';

class DashboardAppBarAgentAction extends StatelessWidget {
  final VoidCallback onPressed;

  const DashboardAppBarAgentAction({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.smart_toy),
      tooltip: 'Z Agent',
      onPressed: onPressed,
    );
  }
}
