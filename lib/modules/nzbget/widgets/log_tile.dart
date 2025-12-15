import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/nzbget.dart';

class NZBGetLogTile extends StatelessWidget {
  final NZBGetLogData data;

  const NZBGetLogTile({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagBlock(
      title: data.text,
      body: [TextSpan(text: data.timestamp)],
      trailing: const ZagIconButton.arrow(),
      onTap: () async =>
          ZagDialogs().textPreview(context, 'Log Entry', data.text!),
    );
  }
}
