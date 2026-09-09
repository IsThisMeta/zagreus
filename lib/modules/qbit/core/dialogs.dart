import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/qbit/core/api/data.dart';
import 'package:zagreus/modules/qbit/widgets/navigation_bar.dart';

class QBitDialogs {
  QBitDialogs._();

  static Future<List<dynamic>> globalSettings(BuildContext context) async {
    List<List<dynamic>> _options = [
      ['View Web GUI', Icons.language_rounded, 'web_gui'],
      ['Add Torrent', Icons.add_rounded, 'add_torrent'],
      ['Pause All', Icons.pause_rounded, 'pause_all'],
      ['Resume All', Icons.play_arrow_rounded, 'resume_all'],
    ];
    bool _flag = false;
    String _value = '';

    void _setValues(bool flag, String value) {
      _flag = flag;
      _value = value;
      Navigator.of(context).pop();
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
    );
    return [_flag, _value];
  }

  static Future<List<dynamic>> torrentSettings(
      BuildContext context, String title, bool isPaused) async {
    List<List<dynamic>> _options = [
      isPaused
          ? ['Resume Torrent', Icons.play_arrow_rounded, 'status']
          : ['Pause Torrent', Icons.pause_rounded, 'status'],
      ['Change Category', Icons.category_rounded, 'category'],
      ['Rename Torrent', Icons.text_format_rounded, 'rename'],
      ['Recheck Torrent', Icons.refresh_rounded, 'recheck'],
      ['Reannounce', Icons.announcement_rounded, 'reannounce'],
      ['Delete Torrent', Icons.delete_rounded, 'delete'],
    ];
    bool _flag = false;
    String _value = '';

    void _setValues(bool flag, String value) {
      _flag = flag;
      _value = value;
      Navigator.of(context).pop();
    }

    await ZagDialog.dialog(
      context: context,
      title: title,
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
    );
    return [_flag, _value];
  }

  static Future<List<dynamic>> deleteTorrent(BuildContext context) async {
    bool _flag = false;
    bool _deleteFiles = false;

    void _setValues(bool flag, bool deleteFiles) {
      _flag = flag;
      _deleteFiles = deleteFiles;
      Navigator.of(context).pop();
    }

    await ZagDialog.dialog(
      context: context,
      title: 'Delete Torrent',
      buttons: [
        ZagDialog.button(
          text: 'Keep Files',
          onPressed: () => _setValues(true, false),
        ),
        ZagDialog.button(
          text: 'Delete Files',
          textColor: ZagColours.red,
          onPressed: () => _setValues(true, true),
        ),
      ],
      content: [
        ZagDialog.textContent(
            text: 'Are you sure you want to delete this torrent?'),
      ],
      contentPadding: ZagDialog.textDialogContentPadding(),
    );
    return [_flag, _deleteFiles];
  }

  static Future<List<dynamic>> renameTorrent(
      BuildContext context, String originalName) async {
    bool _flag = false;
    final _formKey = GlobalKey<FormState>();
    final _textController = TextEditingController()..text = originalName;

    void _setValues(bool flag) {
      if (_formKey.currentState!.validate()) {
        _flag = flag;
        Navigator.of(context).pop();
      }
    }

    await ZagDialog.dialog(
      context: context,
      title: 'Rename Torrent',
      buttons: [
        ZagDialog.button(
          text: 'Rename',
          onPressed: () => _setValues(true),
        ),
      ],
      content: [
        Form(
          key: _formKey,
          child: ZagDialog.textFormInput(
            controller: _textController,
            title: 'Torrent Name',
            onSubmitted: (_) => _setValues(true),
            validator: (value) =>
                (value?.isEmpty ?? true) ? 'Please enter a valid name' : null,
          ),
        ),
      ],
      contentPadding: ZagDialog.inputDialogContentPadding(),
    );
    return [_flag, _textController.text];
  }

  static Future<List<dynamic>> changeCategory(
      BuildContext context, List<QBitCategoryData> categories) async {
    bool _flag = false;
    QBitCategoryData? _category;

    void _setValues(bool flag, QBitCategoryData category) {
      _flag = flag;
      _category = category;
      Navigator.of(context).pop();
    }

    await ZagDialog.dialog(
      context: context,
      title: 'Change Category',
      content: List.generate(
        categories.length,
        (index) => ZagDialog.tile(
          text: categories[index].displayName,
          icon: Icons.category_rounded,
          iconColor: ZagColours().byListIndex(index),
          onTap: () => _setValues(true, categories[index]),
        ),
      ),
      contentPadding: ZagDialog.listDialogContentPadding(),
    );
    return [_flag, _category];
  }

  static Future<List<dynamic>> addTorrent(BuildContext context) async {
    List<List<dynamic>> _options = [
      ['Add by Magnet/URL', Icons.link_rounded, 'link'],
      ['Add by File', Icons.sd_card_rounded, 'file'],
    ];
    bool _flag = false;
    String _type = '';

    void _setValues(bool flag, String type) {
      _flag = flag;
      _type = type;
      Navigator.of(context).pop();
    }

    await ZagDialog.dialog(
      context: context,
      title: 'Add Torrent',
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
    );
    return [_flag, _type];
  }

  static Future<List<dynamic>> addTorrentUrl(BuildContext context) async {
    bool _flag = false;
    final _formKey = GlobalKey<FormState>();
    final _textController = TextEditingController();

    void _setValues(bool flag) {
      if (_formKey.currentState!.validate()) {
        _flag = flag;
        Navigator.of(context).pop();
      }
    }

    await ZagDialog.dialog(
      context: context,
      title: 'Add Torrent by URL',
      buttons: [
        ZagDialog.button(
          text: 'Add',
          onPressed: () => _setValues(true),
        ),
      ],
      content: [
        Form(
          key: _formKey,
          child: ZagDialog.textFormInput(
            controller: _textController,
            title: 'Magnet Link or URL',
            keyboardType: TextInputType.url,
            onSubmitted: (_) => _setValues(true),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a URL';
              }
              if (!value.startsWith('magnet:') &&
                  !value.startsWith('http://') &&
                  !value.startsWith('https://')) {
                return 'Please enter a valid magnet link or URL';
              }
              return null;
            },
          ),
        ),
      ],
      contentPadding: ZagDialog.inputDialogContentPadding(),
    );
    return [_flag, _textController.text];
  }

  static Future<List<dynamic>> setFilePriority(BuildContext context) async {
    bool _flag = false;
    QBitFilePriority? _priority;

    void _setValues(bool flag, QBitFilePriority priority) {
      _flag = flag;
      _priority = priority;
      Navigator.of(context).pop();
    }

    final priorities = [
      QBitFilePriority.doNotDownload,
      QBitFilePriority.normal,
      QBitFilePriority.high,
      QBitFilePriority.maximum,
    ];

    await ZagDialog.dialog(
      context: context,
      title: 'Set Priority',
      content: List.generate(
        priorities.length,
        (index) => ZagDialog.tile(
          text: priorities[index].name,
          icon: Icons.low_priority_rounded,
          iconColor: ZagColours().byListIndex(index),
          onTap: () => _setValues(true, priorities[index]),
        ),
      ),
      contentPadding: ZagDialog.listDialogContentPadding(),
    );
    return [_flag, _priority];
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
        QBitNavigationBar.titles.length,
        (index) => ZagDialog.tile(
          text: QBitNavigationBar.titles[index],
          icon: QBitNavigationBar.icons[index],
          iconColor: ZagColours().byListIndex(index),
          onTap: () => _setValues(true, index),
        ),
      ),
      contentPadding: ZagDialog.listDialogContentPadding(),
    );

    return [_flag, _index];
  }
}
