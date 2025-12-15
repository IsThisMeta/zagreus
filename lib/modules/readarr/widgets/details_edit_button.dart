import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/readarr.dart';
import 'package:zagreus/router/routes/readarr.dart';

class ReadarrDetailsEditButton extends StatefulWidget {
  final ReadarrCatalogueData? data;

  const ReadarrDetailsEditButton({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  State<ReadarrDetailsEditButton> createState() => _State();
}

class _State extends State<ReadarrDetailsEditButton> {
  @override
  Widget build(BuildContext context) => Consumer<ReadarrState>(
        builder: (context, model, widget) => ZagIconButton(
          icon: Icons.edit_rounded,
          onPressed: () async => _enterEditAuthor(context),
        ),
      );

  Future<void> _enterEditAuthor(BuildContext context) async {
    ReadarrRoutes.AUTHOR_EDIT.go(
      extra: widget.data,
      params: {
        'author': widget.data!.authorID.toString(),
      },
    );
  }
}
