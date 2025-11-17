import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/readarr.dart';
import 'package:zagreus/router/routes/readarr.dart';

class ReadarrHistoryTile extends StatelessWidget {
  static final double extent = ZagBlock.calculateItemExtent(2);
  final ReadarrHistoryData data;

  const ReadarrHistoryTile({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagBlock(
      title: data.title,
      body: data.subtitle,
      trailing: const ZagIconButton.arrow(),
      onTap: () => _enterAuthor(),
    );
  }

  Future<void> _enterAuthor() async {
    if (data.authorID == -1) {
      showZagInfoSnackBar(
        title: 'No Author Available',
        message: 'There is no author associated with this history entry',
      );
    } else {
      ReadarrRoutes.AUTHOR.go(
        params: {
          'author': data.authorID.toString(),
        },
      );
    }
  }
}
