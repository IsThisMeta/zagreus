import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/readarr.dart';

class ReadarrSearchResultTile extends StatelessWidget {
  final ReadarrCatalogueData data;

  const ReadarrSearchResultTile({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(data.title),
      subtitle: Text('readarr.SearchResultPlaceholder'.tr()),
      leading: const Icon(Icons.search),
    );
  }
}
