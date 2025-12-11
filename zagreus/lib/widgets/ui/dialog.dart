import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zagreus/core.dart';

// ignore: avoid_classes_with_only_static_members
abstract class ZagDialog {
  static const HEADER_SIZE = ZagUI.FONT_SIZE_H1;
  static const BODY_SIZE = ZagUI.FONT_SIZE_H3;
  static const BUTTON_SIZE = ZagUI.FONT_SIZE_H4;

  static Widget title({
    required String text,
  }) =>
      Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: ZagDialog.HEADER_SIZE,
          fontWeight: ZagUI.FONT_WEIGHT_BOLD,
        ),
      );

  static TextSpan bolded({
    required String text,
    double fontSize = ZagDialog.BODY_SIZE,
    Color? color,
  }) =>
      TextSpan(
        text: text,
        style: TextStyle(
          color: color ?? ZagColours.currentAccent,
          fontWeight: ZagUI.FONT_WEIGHT_BOLD,
          fontSize: fontSize,
        ),
      );

  static Widget richText({
    required List<TextSpan>? children,
    TextAlign alignment = TextAlign.start,
  }) =>
      RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: ZagDialog.BODY_SIZE,
          ),
          children: children,
        ),
        textAlign: alignment,
      );

  static Widget button({
    required String text,
    required void Function() onPressed,
    Color? textColor,
  }) =>
      Builder(
        builder: (context) => TextButton(
          child: Text(
            text,
            style: TextStyle(
              color: textColor ?? ZagColours.accentColor(context),
              fontSize: ZagDialog.BUTTON_SIZE,
            ),
          ),
          onPressed: () async {
            HapticFeedback.lightImpact();
            onPressed();
          },
        ),
      );

  static Widget cancel(
    BuildContext context, {
    Color? textColor,
    String? text,
  }) =>
      TextButton(
        child: Text(
          text ?? 'zagreus.Cancel'.tr(),
          style: TextStyle(
            color: textColor ?? Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: ZagDialog.BUTTON_SIZE,
          ),
        ),
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).pop();
        },
      );

  static Widget content({
    required List<Widget> children,
  }) =>
      SingleChildScrollView(
        child: ListBody(
          children: children,
        ),
        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 1.0),
      );

  static Widget textContent({
    required String text,
    TextAlign textAlign = TextAlign.center,
    Color? color,
  }) =>
      Builder(
        builder: (context) => Text(
          text,
          style: TextStyle(
            color: color ?? Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
            fontSize: ZagDialog.BODY_SIZE,
          ),
          textAlign: textAlign,
        ),
      );

  static TextSpan textSpanContent({
    required String text,
  }) =>
      TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white,
          fontSize: ZagDialog.BODY_SIZE,
        ),
      );

  static Widget textInput({
    required TextEditingController controller,
    required void Function(String)? onSubmitted,
    required String title,
  }) =>
      TextField(
        autofocus: true,
        autocorrect: false,
        controller: controller,
        decoration: InputDecoration(
          labelText: title,
          labelStyle: TextStyle(
            color: ZagColours.grey,
            decoration: TextDecoration.none,
            fontSize: ZagDialog.BODY_SIZE,
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: ZagColours.currentAccent),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
                color: ZagColours.currentAccent.withOpacity(ZagUI.OPACITY_SPLASH)),
          ),
        ),
        style: TextStyle(
          color: Colors.white,
          fontSize: ZagDialog.BODY_SIZE,
        ),
        cursorColor: ZagColours.currentAccent,
        textInputAction: TextInputAction.done,
        onSubmitted: onSubmitted,
      );

  static Widget textFormInput({
    required TextEditingController controller,
    required String title,
    required ValueChanged<String>? onSubmitted,
    required FormFieldValidator<String>? validator,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) =>
      Builder(
        builder: (context) => TextFormField(
          autofocus: true,
          autocorrect: false,
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            labelText: title,
            labelStyle: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
              decoration: TextDecoration.none,
              fontSize: ZagDialog.BODY_SIZE,
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: ZagColours.currentAccent),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                  color: ZagColours.currentAccent.withOpacity(ZagUI.OPACITY_SPLASH)),
            ),
            suffixIcon: suffixIcon,
          ),
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: ZagDialog.BODY_SIZE,
          ),
          cursorColor: ZagColours.currentAccent,
          textInputAction: TextInputAction.done,
          validator: validator,
          onFieldSubmitted: onSubmitted,
        ),
      );

  static Widget tile({
    required IconData? icon,
    Color? iconColor,
    required String text,
    RichText? subtitle,
    Function? onTap,
  }) =>
      ListTile(
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon ?? Icons.error_outline_rounded,
              color: iconColor ?? ZagColours.currentAccent,
            ),
          ],
        ),
        title: Text(
          text,
          style: TextStyle(
            fontSize: ZagDialog.BODY_SIZE,
          ),
        ),
        subtitle: subtitle,
        onTap: onTap == null
            ? null
            : () async {
                HapticFeedback.selectionClick();
                onTap();
              },
        contentPadding: tileContentPadding(),
      );

  static CheckboxListTile checkbox({
    required String title,
    required bool? value,
    required void Function(bool?) onChanged,
  }) =>
      CheckboxListTile(
        title: Text(
          title,
          style: TextStyle(
            fontSize: BODY_SIZE,
          ),
        ),
        value: value,
        onChanged: onChanged,
        contentPadding: tileContentPadding(),
      );

  static EdgeInsets tileContentPadding() =>
      const EdgeInsets.symmetric(horizontal: 32.0, vertical: 0.0);
  static EdgeInsets textDialogContentPadding() =>
      const EdgeInsets.fromLTRB(24.0, 32.0, 24.0, 14.0);
  static EdgeInsets listDialogContentPadding() =>
      const EdgeInsets.fromLTRB(0.0, 26.0, 0.0, 0.0);
  static EdgeInsets inputTextDialogContentPadding() =>
      const EdgeInsets.fromLTRB(24.0, 34.0, 24.0, 22.0);
  static EdgeInsets inputDialogContentPadding() =>
      const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 22.0);

  static Future<void> dialog({
    required BuildContext context,
    required String? title,
    required EdgeInsets contentPadding,
    bool showCancelButton = true,
    String? cancelButtonText,
    List<Widget>? buttons,
    List<Widget>? content,
    Widget? customContent,
    bool barrierDismissible = true,
  }) async {
    if (customContent == null)
      assert(content != null, 'customContent and content both cannot be null');
    await showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        actions: <Widget>[
          if (showCancelButton)
            ZagDialog.cancel(
              context,
              text: cancelButtonText,
              textColor: buttons == null ? ZagColours.currentAccentLight : null,
            ),
          if (buttons != null) ...buttons,
        ],
        title: ZagDialog.title(text: title!),
        content: customContent ?? ZagDialog.content(children: content!),
        contentPadding: contentPadding,
        shape: ZagUI.shapeBorder,
      ),
    );
  }
}
