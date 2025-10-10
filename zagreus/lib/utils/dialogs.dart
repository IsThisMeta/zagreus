import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zagreus/core.dart';

class ZagDialogs {
  /// Show an an edit text prompt.
  ///
  /// Can pass in [prefill] String to prefill the [TextFormField]. Can also pass in a list of [TextSpan] tp show text above the field.
  ///
  /// Returns list containing:
  /// - 0: Flag (true if they hit save, false if they cancelled the prompt)
  /// - 1: Value from the [TextEditingController].
  Future<Tuple2<bool, String>> editText(
      BuildContext context, String dialogTitle,
      {String prefill = '', List<TextSpan>? extraText}) async {
    bool _flag = false;
    final _formKey = GlobalKey<FormState>();
    final _textController = TextEditingController()..text = prefill;

    void _setValues(bool flag) {
      if (_formKey.currentState?.validate() ?? false) {
        _flag = flag;
        Navigator.of(context, rootNavigator: true).pop();
      }
    }

    await ZagDialog.dialog(
      context: context,
      title: dialogTitle,
      buttons: [
        ZagDialog.button(
          text: 'Save',
          onPressed: () => _setValues(true),
        ),
      ],
      content: [
        if (extraText?.isNotEmpty ?? false)
          ZagDialog.richText(children: extraText),
        Form(
          key: _formKey,
          child: ZagDialog.textFormInput(
            controller: _textController,
            title: dialogTitle,
            onSubmitted: (_) => _setValues(true),
            validator: (_) => null,
          ),
        ),
      ],
      contentPadding: (extraText?.length ?? 0) == 0
          ? ZagDialog.inputDialogContentPadding()
          : ZagDialog.inputTextDialogContentPadding(),
    );
    return Tuple2(_flag, _textController.text);
  }

  /// Show a text preview dialog.
  ///
  /// Can pass in boolean [alignLeft] to left align the text in the dialog (useful for bulleted lists)
  Future<void> textPreview(
      BuildContext context, String? dialogTitle, String text,
      {bool alignLeft = false}) async {
    await ZagDialog.dialog(
      context: context,
      title: dialogTitle,
      cancelButtonText: 'Close',
      buttons: [
        ZagDialog.button(
            text: 'Copy',
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: text));
              showZagSuccessSnackBar(
                  title: 'Copied Content',
                  message: 'Copied text to the clipboard');
              Navigator.of(context, rootNavigator: true).pop();
            }),
      ],
      content: [
        ZagDialog.textContent(
          text: text,
          textAlign: alignLeft ? TextAlign.start : TextAlign.center,
        ),
      ],
      contentPadding: ZagDialog.textDialogContentPadding(),
    );
  }

  /// Show a text preview dialog with Add button instead of Copy.
  ///
  /// Used for adding media items to Radarr/Sonarr with saved settings.
  Future<void> textPreviewWithAdd(
      BuildContext context, String? dialogTitle, String text,
      {required VoidCallback onAdd, bool alignLeft = false}) async {
    await ZagDialog.dialog(
      context: context,
      title: dialogTitle,
      cancelButtonText: 'Close',
      buttons: [
        ZagDialog.button(
            text: 'Add',
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
              onAdd();
            }),
      ],
      content: [
        ZagDialog.textContent(
          text: text,
          textAlign: alignLeft ? TextAlign.start : TextAlign.center,
        ),
      ],
      contentPadding: ZagDialog.textDialogContentPadding(),
    );
  }

  Future<void> showRejections(
      BuildContext context, List<String> rejections) async {
    if (rejections.isEmpty)
      return textPreview(
        context,
        'Rejection Reasons',
        'No rejections found',
      );

    await ZagDialog.dialog(
      context: context,
      title: 'Rejection Reasons',
      cancelButtonText: 'Close',
      content: List.generate(
        rejections.length,
        (index) => ZagDialog.tile(
          text: rejections[index],
          icon: Icons.report_outlined,
          iconColor: ZagColours.red,
        ),
      ),
      contentPadding: ZagDialog.listDialogContentPadding(),
    );
  }

  Future<void> showMessages(BuildContext context, List<String> messages) async {
    if (messages.isEmpty) {
      return textPreview(context, 'Messages', 'No messages found');
    }
    await ZagDialog.dialog(
      context: context,
      title: 'Messages',
      cancelButtonText: 'Close',
      content: List.generate(
        messages.length,
        (index) => ZagDialog.tile(
          text: messages[index],
          icon: Icons.info_outline_rounded,
          iconColor: ZagColours.accent,
        ),
      ),
      contentPadding: ZagDialog.listDialogContentPadding(),
    );
  }

  /// **Will be removed in future**
  ///
  /// Show a delete catalogue with all files warning dialog.
  Future<List<dynamic>> deleteCatalogueWithFiles(
      BuildContext context, String moduleTitle) async {
    bool _flag = false;

    void _setValues(bool flag) {
      _flag = flag;
      Navigator.of(context, rootNavigator: true).pop();
    }

    await ZagDialog.dialog(
      context: context,
      title: 'Delete All Files',
      buttons: [
        ZagDialog.button(
          text: 'Delete',
          textColor: ZagColours.red,
          onPressed: () => _setValues(true),
        ),
      ],
      content: [
        ZagDialog.textContent(
            text:
                'Are you sure you want to delete all the files and folders for $moduleTitle?'),
      ],
      contentPadding: ZagDialog.textDialogContentPadding(),
    );
    return [_flag];
  }

  Future<ZagModule?> selectDownloadClient() async {
    final profile = ZagProfile.current;
    final context = ZagState.context;
    ZagModule? module;

    await ZagDialog.dialog(
      context: context,
      title: 'zagreus.DownloadClient'.tr(),
      content: [
        if (profile.nzbgetEnabled)
          ZagDialog.tile(
            text: ZagModule.NZBGET.title,
            icon: ZagModule.NZBGET.icon,
            iconColor: ZagModule.NZBGET.color,
            onTap: () {
              module = ZagModule.NZBGET;
              Navigator.of(context).pop();
            },
          ),
        if (profile.sabnzbdEnabled)
          ZagDialog.tile(
            text: ZagModule.SABNZBD.title,
            icon: ZagModule.SABNZBD.icon,
            iconColor: ZagModule.SABNZBD.color,
            onTap: () {
              module = ZagModule.SABNZBD;
              Navigator.of(context).pop();
            },
          ),
      ],
      contentPadding: ZagDialog.listDialogContentPadding(),
    );

    return module;
  }
}
