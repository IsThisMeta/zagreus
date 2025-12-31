import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/readarr.dart';
import 'package:zagreus/router/routes/readarr.dart';

class ReadarrDetailsSettingsButton extends StatefulWidget {
  final ReadarrCatalogueData? data;
  final Function(bool) remove;

  const ReadarrDetailsSettingsButton({
    Key? key,
    required this.data,
    required this.remove,
  }) : super(key: key);

  @override
  State<ReadarrDetailsSettingsButton> createState() => _State();
}

class _State extends State<ReadarrDetailsSettingsButton> {
  @override
  Widget build(BuildContext context) => Consumer<ReadarrState>(
        builder: (context, model, widget) => ZagIconButton(
          icon: Icons.more_vert_rounded,
          onPressed: () async => _handlePopup(context),
        ),
      );

  Future<void> _handlePopup(BuildContext context) async {
    List<dynamic> values =
        await ReadarrDialogs.editAuthor(context, widget.data!);
    if (values[0])
      switch (values[1]) {
        case 'refresh_author':
          _refreshAuthor(context);
          break;
        case 'edit_author':
          _enterEditAuthor(context);
          break;
        case 'remove_author':
          _removeAuthor(context);
          break;
        default:
          ZagLogger()
              .warning('Invalid method passed through popup. (${values[1]})');
      }
  }

  Future<void> _enterEditAuthor(BuildContext context) async {
    ReadarrRoutes.AUTHOR_EDIT.go(
      extra: widget.data,
      params: {
        'author': widget.data!.authorID.toString(),
      },
    );
  }

  Future<void> _refreshAuthor(BuildContext context) async {
    final _api = ReadarrAPI.from(ZagProfile.forModule('readarr'));
    await _api
        .refreshAuthor(widget.data!.authorID)
        .then((_) => showZagSuccessSnackBar(
            title: 'Refreshing...', message: widget.data!.title))
        .catchError((error) =>
            showZagErrorSnackBar(title: 'Failed to Refresh', error: error));
  }

  Future<void> _removeAuthor(BuildContext context) async {
    final _api = ReadarrAPI.from(ZagProfile.forModule('readarr'));
    List values = await ReadarrDialogs.deleteAuthor(context);
    if (values[0]) {
      if (values[1]) {
        values = await ZagDialogs()
            .deleteCatalogueWithFiles(context, widget.data!.title);
        if (values[0]) {
          await _api
              .removeAuthor(widget.data!.authorID, deleteFiles: true)
              .then((_) => widget.remove(true))
              .catchError((error) => showZagErrorSnackBar(
                  title: 'Failed to Remove (With Data)', error: error));
        }
      } else {
        await _api
            .removeAuthor(widget.data!.authorID)
            .then((_) => widget.remove(false))
            .catchError((error) =>
                showZagErrorSnackBar(title: 'Failed to Remove', error: error));
      }
    }
  }
}
