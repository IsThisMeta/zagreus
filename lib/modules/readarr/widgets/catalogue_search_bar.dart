import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/readarr.dart';

class ReadarrCatalogueSearchBar extends StatelessWidget {
  const ReadarrCatalogueSearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'readarr.SearchCatalogue'.tr(),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
