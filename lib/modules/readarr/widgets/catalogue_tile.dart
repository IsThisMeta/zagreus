import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/int/bytes.dart';
import 'package:zagreus/extensions/string/string.dart';
import 'package:zagreus/modules/readarr.dart';
import 'package:zagreus/router/routes/readarr.dart';

class ReadarrCatalogueTile extends StatelessWidget {
  static final itemExtent = ZagBlock.calculateItemExtent(2);

  final ReadarrCatalogueData data;

  const ReadarrCatalogueTile({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ReadarrState>(
      builder: (context, state, _) {
        return ZagBlock(
          key: ObjectKey(data),
          backgroundUrl: data.fanartURI(),
          backgroundHeaders: ZagProfile.forModule('readarr').readarrHeaders,
          posterUrl: data.posterURI(),
          posterHeaders: ZagProfile.forModule('readarr').readarrHeaders,
          posterPlaceholderIcon: Icons.menu_book_rounded,
          disabled: !(data.monitored ?? false),
          title: data.title,
          body: [
            _subtitle1(context, state),
            _subtitle2(context, state),
          ],
          onTap: () => _onTap(),
          onLongPress: () => _onLongPress(context),
        );
      },
    );
  }

  TextSpan _buildChildTextSpan(
    BuildContext context,
    String? text,
    ReadarrCatalogueSorting sorting,
    ReadarrState state,
  ) {
    TextStyle? style;
    if (state.sortCatalogueType == sorting) {
      style = TextStyle(
        color: ZagColours.currentAccent,
        fontWeight: ZagUI.FONT_WEIGHT_BOLD,
      );
    }
    return TextSpan(
      text: text,
      style: style,
    );
  }

  TextSpan _subtitle1(BuildContext context, ReadarrState state) {
    return TextSpan(
      children: [
        _buildChildTextSpan(
          context,
          data.bookStats,
          ReadarrCatalogueSorting.books,
          state,
        ),
        TextSpan(text: ZagUI.TEXT_BULLET.pad()),
        _buildChildTextSpan(
          context,
          data.sizeOnDisk.asBytes(),
          ReadarrCatalogueSorting.size,
          state,
        ),
      ],
    );
  }

  TextSpan _subtitle2(BuildContext context, ReadarrState state) {
    return TextSpan(
      children: [
        _buildChildTextSpan(
          context,
          data.quality ?? ZagUI.TEXT_EMDASH,
          ReadarrCatalogueSorting.quality,
          state,
        ),
        TextSpan(text: ZagUI.TEXT_BULLET.pad()),
        _buildChildTextSpan(
          context,
          data.metadata ?? ZagUI.TEXT_EMDASH,
          ReadarrCatalogueSorting.metadata,
          state,
        ),
      ],
    );
  }

  void _onTap() {
    ReadarrRoutes.AUTHOR.go(params: {
      'author': data.authorID.toString(),
    });
  }

  Future<void> _onLongPress(BuildContext context) async {
    final values = await ReadarrDialogs.editAuthor(context, data);
    if (values[0] == true) {
      final action = values[1] as String;
      switch (action) {
        case 'edit_author':
          ReadarrRoutes.AUTHOR_EDIT.go(params: {
            'author': data.authorID.toString(),
          });
          break;
        case 'refresh_author':
          final api = ReadarrAPI.from(ZagProfile.forModule('readarr'));
          await api.refreshAuthor(data.authorID);
          showZagSnackBar(
            title: 'readarr.Readarr'.tr(),
            message: 'readarr.RefreshingAuthor'.tr(),
            type: ZagSnackbarType.INFO,
          );
          break;
        case 'remove_author':
          final deleteValues = await ReadarrDialogs.deleteAuthor(context);
          if (deleteValues[0] == true) {
            final api = ReadarrAPI.from(ZagProfile.forModule('readarr'));
            await api.removeAuthor(data.authorID, deleteFiles: deleteValues[1]);
            showZagSnackBar(
              title: 'readarr.Readarr'.tr(),
              message: 'readarr.AuthorRemoved'.tr(),
              type: ZagSnackbarType.SUCCESS,
            );
          }
          break;
      }
    }
  }
}
