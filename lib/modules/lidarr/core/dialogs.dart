import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/int/bytes.dart';
import 'package:zagreus/modules/lidarr.dart';

class LidarrDialogs {
  Future<Tuple2<bool, LidarrMonitorStatus?>> selectMonitoringOption(
    BuildContext context,
  ) async {
    bool _flag = false;
    LidarrMonitorStatus? _value;

    void _setValues(bool flag, LidarrMonitorStatus value) {
      _flag = flag;
      _value = value;
      Navigator.of(context, rootNavigator: true).pop();
    }

    await ZagDialog.dialog(
      context: context,
      title: 'Monitoring Options',
      content: List.generate(
        LidarrMonitorStatus.values.length,
        (index) => ZagDialog.tile(
          text: LidarrMonitorStatus.values[index].readable,
          icon: ZagIcons.MONITOR_ON,
          iconColor: ZagColours().byListIndex(index),
          onTap: () => _setValues(true, LidarrMonitorStatus.values[index]),
        ),
      ),
      contentPadding: ZagDialog.listDialogContentPadding(),
      barrierDismissible: false,
    );
    return Tuple2(_flag, _value);
  }

  static Future<List<dynamic>> editQualityProfile(
      BuildContext context, List<LidarrQualityProfile> qualities) async {
    bool _flag = false;
    LidarrQualityProfile? _quality;

    void _setValues(bool flag, LidarrQualityProfile quality) {
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
      BuildContext context, List<LidarrMetadataProfile> metadatas) async {
    bool _flag = false;
    LidarrMetadataProfile? _metadata;

    void _setValues(bool flag, LidarrMetadataProfile metadata) {
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

  static Future<List<dynamic>> deleteArtist(BuildContext context) async {
    bool _flag = false;
    bool _files = false;

    void _setValues(bool flag, bool files) {
      _flag = flag;
      _files = files;
      Navigator.of(context, rootNavigator: true).pop();
    }

    await ZagDialog.dialog(
      context: context,
      title: 'Remove Artist',
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
            text: 'Are you sure you want to remove the artist from Lidarr?'),
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
                'Are you sure you want to download this release? It has been marked as a rejected release by Lidarr.'),
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
            text: 'Are you sure you want to search for all missing albums?'),
      ],
      contentPadding: ZagDialog.textDialogContentPadding(),
    );
    return [_flag];
  }

  static Future<List<dynamic>> editArtist(
      BuildContext context, LidarrCatalogueData entry) async {
    List<List<dynamic>> _options = [
      ['Edit Artist', Icons.edit_rounded, 'edit_artist'],
      ['Refresh Artist', Icons.refresh_rounded, 'refresh_artist'],
      ['Remove Artist', Icons.delete_rounded, 'remove_artist'],
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
      BuildContext context, List<LidarrRootFolder> folders) async {
    bool _flag = false;
    LidarrRootFolder? _folder;

    void _setValues(bool flag, LidarrRootFolder folder) {
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
          ),
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
        LidarrNavigationBar.titles.length,
        (index) => ZagDialog.tile(
          text: LidarrNavigationBar.titles[index],
          icon: LidarrNavigationBar.icons[index],
          iconColor: ZagColours().byListIndex(index),
          onTap: () => _setValues(true, index),
        ),
      ),
      contentPadding: ZagDialog.listDialogContentPadding(),
      barrierDismissible: false,
    );

    return [_flag, _index];
  }

  Future<void> addArtistOptions(BuildContext context) async {
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
        LidarrDatabase.ADD_ARTIST_SEARCH_FOR_MISSING.listenableBuilder(
          builder: (context, _) => ZagDialog.checkbox(
            title: 'lidarr.StartSearchForMissingAlbums'.tr(),
            value: LidarrDatabase.ADD_ARTIST_SEARCH_FOR_MISSING.read(),
            onChanged: (value) {
              LidarrDatabase.ADD_ARTIST_SEARCH_FOR_MISSING.update(value!);
            },
          ),
        ),
      ],
      contentPadding: ZagDialog.listDialogContentPadding(),
    );
  }
}
