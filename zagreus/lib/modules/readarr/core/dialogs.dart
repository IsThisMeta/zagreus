import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/int/bytes.dart';
import 'package:zagreus/modules/readarr.dart';

class ReadarrDialogs {
  Future<Tuple2<bool, ReadarrMonitorStatus?>> selectMonitoringOption(
    BuildContext context,
  ) async {
    bool _flag = false;
    ReadarrMonitorStatus? _value;

    void _setValues(bool flag, ReadarrMonitorStatus value) {
      _flag = flag;
      _value = value;
      Navigator.of(context, rootNavigator: true).pop();
    }

    await ZagDialog.dialog(
      context: context,
      title: 'Monitoring Options',
      content: List.generate(
        ReadarrMonitorStatus.values.length,
        (index) => ZagDialog.tile(
          text: ReadarrMonitorStatus.values[index].readable,
          icon: ZagIcons.MONITOR_ON,
          iconColor: ZagColours().byListIndex(index),
          onTap: () => _setValues(true, ReadarrMonitorStatus.values[index]),
        ),
      ),
      contentPadding: ZagDialog.listDialogContentPadding(),
      barrierDismissible: false,
    );
    return Tuple2(_flag, _value);
  }

  static Future<List<dynamic>> editQualityProfile(
      BuildContext context, List<ReadarrQualityProfile> qualities) async {
    bool _flag = false;
    ReadarrQualityProfile? _quality;

    void _setValues(bool flag, ReadarrQualityProfile quality) {
      _flag = flag;
      _quality = quality;
      Navigator.of(context, rootNavigator: true).pop();
    }

    await ZagDialog.dialog(
      context: context,
      title: 'Quality Profile',
      content: List.generate(
        qualities.length,
        (index) => ZagDialog.tile(
          icon: Icons.portrait_rounded,
          iconColor: ZagColours().byListIndex(index),
          text: qualities[index].name!,
          onTap: () => _setValues(true, qualities[index]),
        ),
      ),
      contentPadding: ZagDialog.listDialogContentPadding(),
      barrierDismissible: false,
    );
    return [_flag, _quality];
  }

  static Future<List<dynamic>> editMetadataProfile(
      BuildContext context, List<ReadarrMetadataProfile> metadatas) async {
    bool _flag = false;
    ReadarrMetadataProfile? _metadata;

    void _setValues(bool flag, ReadarrMetadataProfile metadata) {
      _flag = flag;
      _metadata = metadata;
      Navigator.of(context, rootNavigator: true).pop();
    }

    await ZagDialog.dialog(
      context: context,
      title: 'Metadata Profile',
      content: List.generate(
        metadatas.length,
        (index) => ZagDialog.tile(
          icon: Icons.portrait_rounded,
          iconColor: ZagColours().byListIndex(index),
          text: metadatas[index].name!,
          onTap: () => _setValues(true, metadatas[index]),
        ),
      ),
      contentPadding: ZagDialog.listDialogContentPadding(),
      barrierDismissible: false,
    );
    return [_flag, _metadata];
  }

  static Future<List<dynamic>> deleteAuthor(BuildContext context) async {
    bool _flag = false;
    bool _files = false;

    void _setValues(bool flag, bool files) {
      _flag = flag;
      _files = files;
      Navigator.of(context, rootNavigator: true).pop();
    }

    await ZagDialog.dialog(
      context: context,
      title: 'Remove Author',
      buttons: [
        ZagDialog.button(
          text: 'Remove + Files',
          textColor: ZagColours.red,
          onPressed: () => _setValues(true, true),
        ),
        ZagDialog.button(
          text: 'Remove',
          textColor: ZagColours.red,
          onPressed: () => _setValues(true, false),
        ),
      ],
      content: [
        ZagDialog.textContent(
            text: 'Are you sure you want to remove the author from Readarr?'),
      ],
      contentPadding: ZagDialog.textDialogContentPadding(),
    );
    return [_flag, _files];
  }

  static Future<List<dynamic>> downloadWarning(BuildContext context) async {
    bool _flag = false;

    void _setValues(bool flag) {
      _flag = flag;
      Navigator.of(context, rootNavigator: true).pop();
    }

    await ZagDialog.dialog(
      context: context,
      title: 'Download Release',
      buttons: <Widget>[
        ZagDialog.button(
          text: 'Download',
          onPressed: () => _setValues(true),
        ),
      ],
      content: [
        ZagDialog.textContent(
            text:
                'Are you sure you want to download this release? It has been marked as a rejected release by Readarr.'),
      ],
      contentPadding: ZagDialog.textDialogContentPadding(),
    );
    return [_flag];
  }

  static Future<List<dynamic>> searchAllMissing(BuildContext context) async {
    bool _flag = false;

    void _setValues(bool flag) {
      _flag = flag;
      Navigator.of(context, rootNavigator: true).pop();
    }

    await ZagDialog.dialog(
      context: context,
      title: 'Search All Missing',
      buttons: <Widget>[
        ZagDialog.button(
          text: 'Search',
          onPressed: () => _setValues(true),
        ),
      ],
      content: [
        ZagDialog.textContent(
            text: 'Are you sure you want to search for all missing books?'),
      ],
      contentPadding: ZagDialog.textDialogContentPadding(),
    );
    return [_flag];
  }

  static Future<List<dynamic>> editAuthor(
      BuildContext context, ReadarrCatalogueData entry) async {
    List<List<dynamic>> _options = [
      ['Edit Author', Icons.edit_rounded, 'edit_author'],
      ['Refresh Author', Icons.refresh_rounded, 'refresh_author'],
      ['Remove Author', Icons.delete_rounded, 'remove_author'],
    ];
    bool _flag = false;
    String _value = '';

    void _setValues(bool flag, String value) {
      _flag = flag;
      _value = value;
      Navigator.of(context, rootNavigator: true).pop();
    }

    await ZagDialog.dialog(
      context: context,
      title: entry.title,
      content: List.generate(
        _options.length,
        (index) => ZagDialog.tile(
          icon: _options[index][1],
          iconColor: ZagColours().byListIndex(index),
          text: _options[index][0],
          onTap: () => _setValues(true, _options[index][2]),
        ),
      ),
      contentPadding: ZagDialog.listDialogContentPadding(),
      barrierDismissible: false,
    );
    return [_flag, _value];
  }

  static Future<List<dynamic>> editRootFolder(
      BuildContext context, List<ReadarrRootFolder> folders) async {
    bool _flag = false;
    ReadarrRootFolder? _folder;

    void _setValues(bool flag, ReadarrRootFolder folder) {
      _flag = flag;
      _folder = folder;
      Navigator.of(context, rootNavigator: true).pop();
    }

    await ZagDialog.dialog(
      context: context,
      title: 'Root Folder',
      content: List.generate(
        folders.length,
        (index) => ZagDialog.tile(
          text: folders[index].path!,
          subtitle: ZagDialog.richText(
            children: [
              ZagDialog.bolded(
                text: folders[index].freeSpace.asBytes(),
                fontSize: ZagDialog.BUTTON_SIZE,
              ),
            ],
          ) as RichText?,
          icon: Icons.folder_rounded,
          iconColor: ZagColours().byListIndex(index),
          onTap: () => _setValues(true, folders[index]),
        ),
      ),
      contentPadding: ZagDialog.listDialogContentPadding(),
      barrierDismissible: false,
    );
    return [_flag, _folder];
  }

  static Future<List<dynamic>> globalSettings(BuildContext context) async {
    List<List<dynamic>> _options = [
      ['View Web GUI', Icons.language_rounded, 'web_gui'],
      ['Update Library', Icons.autorenew_rounded, 'update_library'],
      ['Run RSS Sync', Icons.rss_feed_rounded, 'rss_sync'],
      ['Search All Missing', Icons.search_rounded, 'missing_search'],
      ['Backup Database', Icons.save_rounded, 'backup'],
    ];
    bool _flag = false;
    String _value = '';

    void _setValues(bool flag, String value) {
      _flag = flag;
      _value = value;
      Navigator.of(context, rootNavigator: true).pop();
    }

    await ZagDialog.dialog(
      context: context,
      title: 'Settings',
      content: List.generate(
        _options.length,
        (index) => ZagDialog.tile(
          text: _options[index][0],
          icon: _options[index][1],
          iconColor: ZagColours().byListIndex(index),
          onTap: () => _setValues(true, _options[index][2]),
        ),
      ),
      contentPadding: ZagDialog.listDialogContentPadding(),
      barrierDismissible: false,
    );
    return [_flag, _value];
  }

  static Future<List<dynamic>> defaultPage(BuildContext context) async {
    bool _flag = false;
    int _index = 0;

    void _setValues(bool flag, int index) {
      _flag = flag;
      _index = index;
      Navigator.of(context, rootNavigator: true).pop();
    }

    await ZagDialog.dialog(
      context: context,
      title: 'Page',
      content: List.generate(
        ReadarrNavigationBar.titles.length,
        (index) => ZagDialog.tile(
          text: ReadarrNavigationBar.titles[index],
          icon: ReadarrNavigationBar.icons[index],
          iconColor: ZagColours().byListIndex(index),
          onTap: () => _setValues(true, index),
        ),
      ),
      contentPadding: ZagDialog.listDialogContentPadding(),
      barrierDismissible: false,
    );

    return [_flag, _index];
  }

  Future<void> addAuthorOptions(BuildContext context) async {
    await ZagDialog.dialog(
      context: context,
      title: 'zagreus.Options'.tr(),
      buttons: [
        ZagDialog.button(
          text: 'zagreus.Close'.tr(),
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
        ),
      ],
      showCancelButton: false,
      content: [
        ReadarrDatabase.ADD_AUTHOR_SEARCH_FOR_MISSING_BOOKS.listenableBuilder(
          builder: (context, _) => ZagDialog.checkbox(
            title: 'readarr.StartSearchForMissingBooks'.tr(),
            value: ReadarrDatabase.ADD_AUTHOR_SEARCH_FOR_MISSING_BOOKS.read(),
            onChanged: (value) {
              ReadarrDatabase.ADD_AUTHOR_SEARCH_FOR_MISSING_BOOKS.update(value!);
            },
          ),
        ),
      ],
      contentPadding: ZagDialog.listDialogContentPadding(),
    );
  }
}
