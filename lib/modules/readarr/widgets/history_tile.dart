import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/readarr.dart';

class ReadarrHistoryTile extends StatelessWidget {
  final ReadarrHistoryData data;

  const ReadarrHistoryTile({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(data.title),
      subtitle: Text('readarr.HistoryEventPlaceholder'.tr()),
      leading: const Icon(Icons.history),
    );
  }
}
