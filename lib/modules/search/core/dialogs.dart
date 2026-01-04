import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/search.dart';
import 'package:zagreus/utils/profile_tools.dart';

class SearchDialogs {
  /// Shows download dialog with profile selector and download client options.
  /// Set [isTorrent] to true to hide "Download to Device" option (Apple restriction).
  Future<Tuple2<bool, SearchDownloadType?>> downloadResult(
    BuildContext context, {
    bool isTorrent = false,
  }) async {
    bool _flag = false;
    SearchDownloadType? _type;

    void _setValues(bool flag, SearchDownloadType type) {
      _flag = flag;
      _type = type;
      Navigator.of(context).pop();
    }

    await ZagDialog.dialog(
      context: context,
      title: 'search.Download'.tr(),
      customContent: ZagreusDatabase.ENABLED_PROFILE.listenableBuilder(
        builder: (context, _) => ZagDialog.content(
          children: [
            Padding(
              child: ZagPopupMenuButton<String>(
                tooltip: 'zagreus.ChangeProfiles'.tr(),
                child: Container(
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Text(
                          ZagreusDatabase.ENABLED_PROFILE.read(),
                          style: TextStyle(
                            fontSize: ZagUI.FONT_SIZE_H3,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down_rounded,
                        color: ZagColours.currentAccent,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.only(bottom: 2.0),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: ZagColours.currentAccent,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
                onSelected: (result) {
                  HapticFeedback.selectionClick();
                  ZagProfileTools().changeTo(result);
                },
                itemBuilder: (context) {
                  return <PopupMenuEntry<String>>[
                    for (final profile in ZagBox.profiles.keys.cast<String>())
                      PopupMenuItem<String>(
                        value: profile,
                        child: Text(
                          profile,
                          style: TextStyle(
                            fontSize: ZagUI.FONT_SIZE_H3,
                            color: ZagreusDatabase.ENABLED_PROFILE.read() ==
                                    profile
                                ? ZagColours.accent
                                : Colors.white,
                          ),
                        ),
                      )
                  ];
                },
              ),
              padding: ZagDialog.tileContentPadding()
                  .add(const EdgeInsets.only(bottom: 16.0)),
            ),
            if (ZagProfile.current.sabnzbdEnabled)
              ZagDialog.tile(
                icon: SearchDownloadType.SABNZBD.icon,
                iconColor: ZagColours().byListIndex(0),
                text: SearchDownloadType.SABNZBD.name,
                onTap: () => _setValues(true, SearchDownloadType.SABNZBD),
              ),
            if (ZagProfile.current.nzbgetEnabled)
              ZagDialog.tile(
                icon: SearchDownloadType.NZBGET.icon,
                iconColor: ZagColours().byListIndex(1),
                text: SearchDownloadType.NZBGET.name,
                onTap: () => _setValues(true, SearchDownloadType.NZBGET),
              ),
            // Hide "Download to Device" for torrents (Apple restriction)
            if (!isTorrent)
              ZagDialog.tile(
                icon: SearchDownloadType.FILESYSTEM.icon,
                iconColor: ZagColours().byListIndex(2),
                text: SearchDownloadType.FILESYSTEM.name,
                onTap: () => _setValues(true, SearchDownloadType.FILESYSTEM),
              ),
          ],
        ),
      ),
      contentPadding: ZagDialog.listDialogContentPadding(),
    );
    return Tuple2(_flag, _type);
  }
}
