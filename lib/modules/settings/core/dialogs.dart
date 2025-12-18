import 'package:flutter/material.dart';

import 'package:wake_on_lan/wake_on_lan.dart';
import 'package:zagreus/database/box.dart';
import 'package:zagreus/database/models/external_module.dart';
import 'package:zagreus/database/models/profile.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/modules.dart';
import 'package:zagreus/modules/dashboard/core/adapters/calendar_starting_day.dart';
import 'package:zagreus/modules/dashboard/core/adapters/calendar_starting_size.dart';
import 'package:zagreus/modules/dashboard/core/adapters/calendar_starting_type.dart';
import 'package:zagreus/modules/settings/core/types/header.dart';
import 'package:zagreus/system/state.dart';
import 'package:zagreus/utils/validator.dart';
import 'package:zagreus/vendor.dart';
import 'package:zagreus/widgets/ui.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/supabase/types.dart';

class SettingsDialogs {
  Future<Tuple2<bool, int>> setDefaultOption(
    BuildContext context, {
    required String title,
    required List<String?> values,
    required List<IconData> icons,
  }) async {
    bool _flag = false;
    int _index = 0;

    void _setValues(bool flag, int index) {
      _flag = flag;
      _index = index;
      Navigator.of(context, rootNavigator: true).pop();
    }

    await ZagDialog.dialog(
      context: context,
      title: title,
      content: List.generate(
        values.length,
        (index) => ZagDialog.tile(
          text: values[index]!,
          icon: icons[index],
          iconColor: ZagColours().byListIndex(index),
          onTap: () => _setValues(true, index),
        ),
      ),
      contentPadding: ZagDialog.listDialogContentPadding(),
    );

    return Tuple2(_flag, _index);
  }

  Future<bool> confirmAccountSignOut(BuildContext context) async {
    bool _flag = false;

    void _setValues(bool flag) {
      _flag = flag;
      Navigator.of(context).pop();
    }

    await ZagDialog.dialog(
      context: context,
      title: 'settings.SignOut'.tr(),
      buttons: [
        ZagDialog.button(
          text: 'settings.SignOut'.tr(),
          textColor: ZagColours.red,
          onPressed: () => _setValues(true),
        ),
      ],
      content: [
        ZagDialog.textContent(text: 'settings.SignOutHint1'.tr()),
      ],
      contentPadding: ZagDialog.textDialogContentPadding(),
    );
    return _flag;
  }

  Future<Tuple2<bool, String>> editHost(
    BuildContext context, {
    String prefill = '',
  }) async {
    bool _flag = false;
    final _formKey = GlobalKey<FormState>();
    final _textController = TextEditingController()..text = prefill;

    void _setValues(bool flag) {
      if (_formKey.currentState!.validate()) {
        _flag = flag;
        Navigator.of(context).pop();
      }
    }

    await ZagDialog.dialog(
      context: context,
      title: 'settings.Host'.tr(),
      buttons: [
        ZagDialog.button(
          text: 'zagreus.Set'.tr(),
          onPressed: () => _setValues(true),
        ),
      ],
      content: [
        ZagDialog.textContent(
          text: '${ZagUI.TEXT_BULLET} ${'settings.HostHint1'.tr()}',
          textAlign: TextAlign.left,
        ),
        ZagDialog.textContent(
          text: '${ZagUI.TEXT_BULLET} ${'settings.HostHint2'.tr()}',
          textAlign: TextAlign.left,
        ),
        ZagDialog.textContent(
          text: '${ZagUI.TEXT_BULLET} ${'settings.HostHint3'.tr()}',
          textAlign: TextAlign.left,
        ),
        ZagDialog.textContent(
          text: '${ZagUI.TEXT_BULLET} ${'settings.HostHint4'.tr()}',
          textAlign: TextAlign.left,
        ),
        ZagDialog.textContent(
          text: '${ZagUI.TEXT_BULLET} ${'settings.HostHint5'.tr()}',
          textAlign: TextAlign.left,
        ),
        Form(
          key: _formKey,
          child: ZagDialog.textFormInput(
            controller: _textController,
            title: 'settings.Host'.tr(),
            keyboardType: TextInputType.url,
            onSubmitted: (_) => _setValues(true),
            validator: (value) {
              // Allow empty value
              if (value?.isEmpty ?? true) return null;
              // Test for https:// or http://
              RegExp exp = RegExp(r"^(http|https)://", caseSensitive: false);
              if (exp.hasMatch(value!)) return null;
              return 'settings.HostValidation'.tr();
            },
          ),
        ),
      ],
      contentPadding: ZagDialog.inputTextDialogContentPadding(),
    );
    return Tuple2(_flag, _textController.text);
  }

  Future<Tuple2<bool, String>> editExternalModuleHost(
    BuildContext context, {
    String prefill = '',
  }) async {
    bool _flag = false;
    final _formKey = GlobalKey<FormState>();
    final _textController = TextEditingController()..text = prefill;

    void _setValues(bool flag) {
      if (_formKey.currentState!.validate()) {
        _flag = flag;
        Navigator.of(context).pop();
      }
    }

    await ZagDialog.dialog(
      context: context,
      title: 'settings.Host'.tr(),
      buttons: [
        ZagDialog.button(
          text: 'zagreus.Set'.tr(),
          onPressed: () => _setValues(true),
        ),
      ],
      content: [
        ZagDialog.textContent(
          text: '${ZagUI.TEXT_BULLET} ${'settings.HostHint1'.tr()}',
          textAlign: TextAlign.left,
        ),
        ZagDialog.textContent(
          text: '${ZagUI.TEXT_BULLET} ${'settings.HostHint2'.tr()}',
          textAlign: TextAlign.left,
        ),
        ZagDialog.textContent(
          text: '${ZagUI.TEXT_BULLET} ${'settings.HostHint3'.tr()}',
          textAlign: TextAlign.left,
        ),
        ZagDialog.textContent(
          text: '${ZagUI.TEXT_BULLET} ${'settings.HostHint4'.tr()}',
          textAlign: TextAlign.left,
        ),
        Form(
          key: _formKey,
          child: ZagDialog.textFormInput(
            controller: _textController,
            title: 'settings.Host'.tr(),
            keyboardType: TextInputType.url,
            onSubmitted: (_) => _setValues(true),
            validator: (value) {
              // Allow empty value
              if (value?.isEmpty ?? true) return null;
              // Test for https:// or http://
              RegExp exp = RegExp(r"^(http|https)://", caseSensitive: false);
              if (exp.hasMatch(value!)) return null;
              return 'settings.HostValidation'.tr();
            },
          ),
        ),
      ],
      contentPadding: ZagDialog.inputTextDialogContentPadding(),
    );
    return Tuple2(_flag, _textController.text);
  }

  Future<bool> deleteIndexer(BuildContext context) async {
    bool _flag = false;

    void _setValues(bool flag) {
      _flag = flag;
      Navigator.of(context).pop();
    }

    await ZagDialog.dialog(
      context: context,
      title: 'settings.DeleteIndexer'.tr(),
      buttons: [
        ZagDialog.button(
          text: 'zagreus.Delete'.tr(),
          textColor: ZagColours.red,
          onPressed: () => _setValues(true),
        ),
      ],
      content: [
        ZagDialog.textContent(text: 'settings.DeleteIndexerHint1'.tr()),
      ],
      contentPadding: ZagDialog.textDialogContentPadding(),
    );
    return _flag;
  }

  Future<bool> deleteExternalModule(BuildContext context) async {
    bool _flag = false;

    void _setValues(bool flag) {
      _flag = flag;
      Navigator.of(context).pop();
    }

    await ZagDialog.dialog(
      context: context,
      title: 'settings.DeleteModule'.tr(),
      buttons: [
        ZagDialog.button(
          text: 'zagreus.Delete'.tr(),
          textColor: ZagColours.red,
          onPressed: () => _setValues(true),
        ),
      ],
      content: [
        ZagDialog.textContent(text: 'settings.DeleteModuleHint1'.tr()),
      ],
      contentPadding: ZagDialog.textDialogContentPadding(),
    );
    return _flag;
  }

  Future<bool> deleteHeader(BuildContext context) async {
    bool _flag = false;

    void _setValues(bool flag) {
      _flag = flag;
      Navigator.of(context).pop();
    }

    await ZagDialog.dialog(
      context: context,
      title: 'settings.DeleteHeader'.tr(),
      buttons: [
        ZagDialog.button(
          text: 'zagreus.Delete'.tr(),
          textColor: ZagColours.red,
          onPressed: () => _setValues(true),
        ),
      ],
      content: [
        ZagDialog.textContent(text: 'settings.DeleteHeaderHint1'.tr()),
      ],
      contentPadding: ZagDialog.textDialogContentPadding(),
    );
    return _flag;
  }

  Future<Tuple2<bool, HeaderType?>> addHeader(BuildContext context) async {
    bool _flag = false;
    HeaderType? _type;

    void _setValues(bool flag, HeaderType type) {
      _flag = flag;
      _type = type;
      Navigator.of(context).pop();
    }

    await ZagDialog.dialog(
      context: context,
      title: 'settings.AddHeader'.tr(),
      content: List.generate(
        HeaderType.values.length,
        (index) => ZagDialog.tile(
          text: HeaderType.values[index].name,
          icon: HeaderType.values[index].icon,
          iconColor: ZagColours().byListIndex(index),
          onTap: () => _setValues(true, HeaderType.values[index]),
        ),
      ),
      contentPadding: ZagDialog.listDialogContentPadding(),
    );
    return Tuple2(_flag, _type);
  }

  Future<Tuple3<bool, String, String>> addCustomHeader(
    BuildContext context,
  ) async {
    bool _flag = false;
    final formKey = GlobalKey<FormState>();
    TextEditingController _key = TextEditingController();
    TextEditingController _value = TextEditingController();

    void _setValues(bool flag) {
      if (formKey.currentState!.validate()) {
        _flag = flag;
        Navigator.of(context).pop();
      }
    }

    await ZagDialog.dialog(
      context: context,
      title: 'settings.CustomHeader'.tr(),
      buttons: [
        ZagDialog.button(
          text: 'zagreus.Add'.tr(),
          onPressed: () => _setValues(true),
        ),
      ],
      content: [
        Form(
          key: formKey,
          child: Column(
            children: [
              ZagDialog.textFormInput(
                controller: _key,
                validator: (value) {
                  if (value?.isNotEmpty ?? false) return null;
                  return 'settings.HeaderKeyValidation'.tr();
                },
                onSubmitted: (_) => _setValues(true),
                title: 'settings.HeaderKey'.tr(),
              ),
              ZagDialog.textFormInput(
                controller: _value,
                validator: (value) {
                  if (value?.isNotEmpty ?? false) return null;
                  return 'settings.HeaderValueValidation'.tr();
                },
                onSubmitted: (_) => _setValues(true),
                title: 'settings.HeaderValue'.tr(),
              ),
            ],
          ),
        ),
      ],
      contentPadding: ZagDialog.inputDialogContentPadding(),
    );
    return Tuple3(_flag, _key.text, _value.text);
  }

  Future<Tuple3<bool, String, String>> addBasicAuthenticationHeader(
    BuildContext context,
  ) async {
    bool _flag = false;
    final _formKey = GlobalKey<FormState>();
    final _username = TextEditingController();
    final _password = TextEditingController();

    void _setValues(bool flag) {
      if (_formKey.currentState!.validate()) {
        _flag = flag;
        Navigator.of(context).pop();
      }
    }

    await ZagDialog.dialog(
      context: context,
      title: 'settings.BasicAuthentication'.tr(),
      buttons: [
        ZagDialog.button(
          text: 'zagreus.Add'.tr(),
          onPressed: () => _setValues(true),
        ),
      ],
      content: [
        ZagDialog.textContent(
          text:
              '${ZagUI.TEXT_BULLET} ${'settings.BasicAuthenticationHint1'.tr()}',
          textAlign: TextAlign.left,
        ),
        ZagDialog.textContent(
          text:
              '${ZagUI.TEXT_BULLET} ${'settings.BasicAuthenticationHint2'.tr()}',
          textAlign: TextAlign.left,
        ),
        ZagDialog.textContent(
          text:
              '${ZagUI.TEXT_BULLET} ${'settings.BasicAuthenticationHint3'.tr()}',
          textAlign: TextAlign.left,
        ),
        Form(
          key: _formKey,
          child: Column(
            children: [
              ZagDialog.textFormInput(
                controller: _username,
                validator: (username) => (username?.isNotEmpty ?? false)
                    ? null
                    : 'settings.UsernameValidation'.tr(),
                onSubmitted: (_) => _setValues(true),
                title: 'settings.Username'.tr(),
              ),
              ZagDialog.textFormInput(
                controller: _password,
                validator: (password) => (password?.isNotEmpty ?? false)
                    ? null
                    : 'settings.PasswordValidation'.tr(),
                onSubmitted: (_) => _setValues(true),
                obscureText: true,
                title: 'settings.Password'.tr(),
              ),
            ],
          ),
        ),
      ],
      contentPadding: ZagDialog.inputTextDialogContentPadding(),
    );
    return Tuple3(_flag, _username.text, _password.text);
  }

  Future<bool> clearLogs(BuildContext context) async {
    bool _flag = false;

    void _setValues(bool flag) {
      _flag = flag;
      Navigator.of(context).pop();
    }

    await ZagDialog.dialog(
      context: context,
      title: 'settings.ClearLogs'.tr(),
      buttons: [
        ZagDialog.button(
          text: 'zagreus.Clear'.tr(),
          onPressed: () => _setValues(true),
          textColor: ZagColours.red,
        ),
      ],
      content: [
        ZagDialog.textContent(text: 'settings.ClearLogsHint1'.tr()),
      ],
      contentPadding: ZagDialog.textDialogContentPadding(),
    );
    return _flag;
  }

  Future<Tuple2<bool, String>> confirmDeleteAccount(
    BuildContext context,
  ) async {
    final _formKey = GlobalKey<FormState>();
    final _textController = TextEditingController();
    bool _flag = false;

    void _setValues(bool flag) {
      if (_formKey.currentState!.validate()) {
        _flag = flag;
        Navigator.of(context).pop();
      }
    }

    await ZagDialog.dialog(
      context: context,
      title: 'settings.DeleteAccount'.tr(),
      buttons: [
        ZagDialog.button(
          text: 'zagreus.Delete'.tr(),
          onPressed: () => _setValues(true),
          textColor: ZagColours.red,
        ),
      ],
      content: [
        ZagDialog.richText(
          children: [
            ZagDialog.bolded(
              text: 'settings.DeleteAccountWarning1'.tr().toUpperCase(),
              color: ZagColours.red,
              fontSize: ZagDialog.BUTTON_SIZE,
            ),
            ZagDialog.textSpanContent(text: '\n\n'),
            ZagDialog.textSpanContent(
              text: 'settings.DeleteAccountHint1'.tr(),
            ),
            ZagDialog.textSpanContent(text: '\n\n'),
            ZagDialog.textSpanContent(
              text: 'settings.DeleteAccountHint2'.tr(),
            ),
          ],
          alignment: TextAlign.center,
        ),
        Form(
          key: _formKey,
          child: ZagDialog.textFormInput(
            controller: _textController,
            title: 'settings.Password'.tr(),
            obscureText: true,
            onSubmitted: (_) => _setValues(true),
            validator: (value) => (value?.isEmpty ?? true)
                ? 'settings.PasswordValidation'.tr()
                : null,
          ),
        ),
      ],
      contentPadding: ZagDialog.textDialogContentPadding(),
    );
    return Tuple2(_flag, _textController.text);
  }

  Future<Tuple3<bool, String, String>> updateAccountEmail(
    BuildContext context,
  ) async {
    final _formKey = GlobalKey<FormState>();
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    bool _flag = false;

    void _setValues(bool flag) {
      if (_formKey.currentState!.validate()) {
        _flag = flag;
        Navigator.of(context).pop();
      }
    }

    await ZagDialog.dialog(
      context: context,
      title: 'settings.UpdateEmail'.tr(),
      buttons: [
        ZagDialog.button(
          text: 'zagreus.Update'.tr(),
          onPressed: () => _setValues(true),
        ),
      ],
      content: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              ZagDialog.textFormInput(
                controller: _emailController,
                title: 'settings.Email'.tr(),
                onSubmitted: (_) => _setValues(true),
                validator: (value) {
                  return ZagValidator().email(value ?? '')
                      ? null
                      : 'settings.EmailValidation'.tr();
                },
              ),
              ZagDialog.textFormInput(
                controller: _passwordController,
                title: 'settings.CurrentPassword'.tr(),
                obscureText: true,
                onSubmitted: (_) => _setValues(true),
                validator: (value) {
                  return value?.isEmpty ?? true
                      ? 'settings.PasswordValidation'.tr()
                      : null;
                },
              ),
            ],
          ),
        ),
      ],
      contentPadding: ZagDialog.textDialogContentPadding(),
    );
    return Tuple3(_flag, _emailController.text, _passwordController.text);
  }

  Future<Tuple3<bool, String, String>> updateAccountPassword(
    BuildContext context,
  ) async {
    final _formKey = GlobalKey<FormState>();
    final _currentPassController = TextEditingController();
    final _newPassController = TextEditingController();
    bool _flag = false;

    void _setValues(bool flag) {
      if (_formKey.currentState!.validate()) {
        _flag = flag;
        Navigator.of(context).pop();
      }
    }

    await ZagDialog.dialog(
      context: context,
      title: 'settings.UpdatePassword'.tr(),
      buttons: [
        ZagDialog.button(
          text: 'zagreus.Update'.tr(),
          onPressed: () => _setValues(true),
        ),
      ],
      content: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              ZagDialog.textFormInput(
                controller: _currentPassController,
                title: 'settings.CurrentPassword'.tr(),
                obscureText: true,
                onSubmitted: (_) => _setValues(true),
                validator: (value) {
                  return value?.isEmpty ?? true
                      ? 'settings.PasswordValidation'.tr()
                      : null;
                },
              ),
              ZagDialog.textFormInput(
                controller: _newPassController,
                title: 'settings.NewPassword'.tr(),
                obscureText: true,
                onSubmitted: (_) => _setValues(true),
                validator: (value) {
                  return value?.isEmpty ?? true
                      ? 'settings.PasswordValidation'.tr()
                      : null;
                },
              ),
            ],
          ),
        ),
      ],
      contentPadding: ZagDialog.textDialogContentPadding(),
    );
    return Tuple3(_flag, _newPassController.text, _currentPassController.text);
  }

  Future<Tuple2<bool, String>> addProfile(
    BuildContext context,
    List<String?> profiles,
  ) async {
    final _formKey = GlobalKey<FormState>();
    final _controller = TextEditingController();
    bool _flag = false;

    void _setValues(bool flag) {
      if (_formKey.currentState!.validate()) {
        _flag = flag;
        Navigator.of(context).pop();
      }
    }

    await ZagDialog.dialog(
      context: context,
      title: 'settings.AddProfile'.tr(),
      buttons: [
        ZagDialog.button(
          text: 'zagreus.Add'.tr(),
          onPressed: () => _setValues(true),
        ),
      ],
      content: [
        Form(
          key: _formKey,
          child: ZagDialog.textFormInput(
            controller: _controller,
            validator: (value) {
              if (profiles.contains(value)) {
                return 'settings.ProfileAlreadyExists'.tr();
              }
              if (value?.isEmpty ?? true) {
                return 'settings.ProfileNameRequired'.tr();
              }
              return null;
            },
            onSubmitted: (_) => _setValues(true),
            title: 'settings.ProfileName'.tr(),
          ),
        ),
      ],
      contentPadding: ZagDialog.inputDialogContentPadding(),
    );
    return Tuple2(_flag, _controller.text);
  }

  Future<Tuple2<bool, String>> renameProfile(
    BuildContext context,
    List<String> profiles,
  ) async {
    bool _flag = false;
    String _profile = '';

    void _setValues(bool flag, String profile) {
      _flag = flag;
      _profile = profile;
      Navigator.of(context).pop();
    }

    await ZagDialog.dialog(
      context: context,
      title: 'settings.RenameProfile'.tr(),
      content: List.generate(
        profiles.length,
        (index) => ZagDialog.tile(
          icon: Icons.settings_rounded,
          iconColor: ZagColours().byListIndex(index),
          text: profiles[index],
          onTap: () => _setValues(true, profiles[index]),
        ),
      ),
      contentPadding: ZagDialog.listDialogContentPadding(),
    );
    return Tuple2(_flag, _profile);
  }

  Future<Tuple2<bool, String>> renameProfileSelected(
    BuildContext context,
    List<String?> profiles,
  ) async {
    final _formKey = GlobalKey<FormState>();
    final _controller = TextEditingController();
    bool _flag = false;

    void _setValues(bool flag) {
      if (_formKey.currentState!.validate()) {
        _flag = flag;
        Navigator.of(context).pop();
      }
    }

    await ZagDialog.dialog(
      context: context,
      title: 'settings.RenameProfile'.tr(),
      buttons: [
        ZagDialog.button(
            text: 'zagreus.Rename'.tr(),
            onPressed: () => _setValues(true),
            textColor: ZagColours.currentAccent),
      ],
      content: [
        Form(
          key: _formKey,
          child: ZagDialog.textFormInput(
            controller: _controller,
            validator: (value) {
              if (profiles.contains(value)) {
                return 'settings.ProfileAlreadyExists'.tr();
              }
              if (value?.isEmpty ?? true) {
                return 'settings.ProfileNameRequired'.tr();
              }
              return null;
            },
            onSubmitted: (_) => _setValues(true),
            title: 'settings.ProfileName'.tr(),
          ),
        ),
      ],
      contentPadding: ZagDialog.inputDialogContentPadding(),
    );
    return Tuple2(_flag, _controller.text);
  }

  Future<Tuple2<bool, String>> deleteProfile(
    BuildContext context,
    List<String> profiles,
  ) async {
    bool _flag = false;
    String _profile = '';

    void _setValues(bool flag, String profile) {
      _flag = flag;
      _profile = profile;
      Navigator.of(context).pop();
    }

    await ZagDialog.dialog(
      context: context,
      title: 'settings.DeleteProfile'.tr(),
      content: List.generate(
        profiles.length,
        (index) => ZagDialog.tile(
          icon: Icons.settings_rounded,
          iconColor: ZagColours().byListIndex(index),
          text: profiles[index],
          onTap: () => _setValues(true, profiles[index]),
        ),
      ),
      contentPadding: ZagDialog.listDialogContentPadding(),
    );
    return Tuple2(_flag, _profile);
  }

  Future<Tuple2<bool, String>> enabledProfile(
    BuildContext context,
    List<String> profiles,
  ) async {
    bool _flag = false;
    String _profile = '';

    void _setValues(bool flag, String profile) {
      _flag = flag;
      _profile = profile;
      Navigator.of(context).pop();
    }

    await ZagDialog.dialog(
      context: context,
      title: 'settings.EnabledProfile'.tr(),
      content: List.generate(
        profiles.length,
        (index) => ZagDialog.tile(
          icon: ZagIcons.USER,
          iconColor: ZagColours().byListIndex(index),
          text: profiles[index],
          onTap: () => _setValues(true, profiles[index]),
        ),
      ),
      contentPadding: ZagDialog.listDialogContentPadding(),
    );
    return Tuple2(_flag, _profile);
  }

  Future<Tuple2<bool, CalendarStartingDay?>> editCalendarStartingDay(
    BuildContext context,
  ) async {
    bool _flag = false;
    CalendarStartingDay? _startingDate;

    void _setValues(bool flag, CalendarStartingDay startingDate) {
      _flag = flag;
      _startingDate = startingDate;
      Navigator.of(context).pop();
    }

    await ZagDialog.dialog(
      context: context,
      title: 'settings.StartingDay'.tr(),
      content: List.generate(
        CalendarStartingDay.values.length,
        (index) => ZagDialog.tile(
          icon: Icons.calendar_today_rounded,
          iconColor: ZagColours().byListIndex(index),
          text: CalendarStartingDay.values[index].name,
          onTap: () => _setValues(true, CalendarStartingDay.values[index]),
        ),
      ),
      contentPadding: ZagDialog.listDialogContentPadding(),
    );
    return Tuple2(_flag, _startingDate);
  }

  Future<Tuple2<bool, CalendarStartingSize?>> editCalendarStartingSize(
    BuildContext context,
  ) async {
    bool _flag = false;
    CalendarStartingSize? _startingSize;

    void _setValues(bool flag, CalendarStartingSize startingSize) {
      _flag = flag;
      _startingSize = startingSize;
      Navigator.of(context).pop();
    }

    await ZagDialog.dialog(
      context: context,
      title: 'settings.StartingSize'.tr(),
      content: List.generate(
        CalendarStartingSize.values.length,
        (index) => ZagDialog.tile(
          icon: CalendarStartingSize.values[index].icon,
          iconColor: ZagColours().byListIndex(index),
          text: CalendarStartingSize.values[index].name,
          onTap: () => _setValues(true, CalendarStartingSize.values[index]),
        ),
      ),
      contentPadding: ZagDialog.listDialogContentPadding(),
    );
    return Tuple2(_flag, _startingSize);
  }

  Future<Tuple2<bool, CalendarStartingType?>> editCalendarStartingView(
    BuildContext context,
  ) async {
    bool _flag = false;
    CalendarStartingType? _startingType;

    void _setValues(bool flag, CalendarStartingType startingType) {
      _flag = flag;
      _startingType = startingType;
      Navigator.of(context).pop();
    }

    IconData _getIcon(CalendarStartingType type) {
      switch (type) {
        case CalendarStartingType.CALENDAR:
          return CalendarStartingType.SCHEDULE.icon;
        case CalendarStartingType.SCHEDULE:
          return CalendarStartingType.CALENDAR.icon;
      }
    }

    await ZagDialog.dialog(
      context: context,
      title: 'settings.StartingView'.tr(),
      content: List.generate(
        CalendarStartingType.values.length,
        (index) => ZagDialog.tile(
          icon: _getIcon(CalendarStartingType.values[index]),
          iconColor: ZagColours().byListIndex(index),
          text: CalendarStartingType.values[index].name,
          onTap: () => _setValues(true, CalendarStartingType.values[index]),
        ),
      ),
      contentPadding: ZagDialog.listDialogContentPadding(),
    );
    return Tuple2(_flag, _startingType);
  }

  Future<Tuple2<bool, String>> editBroadcastAddress(
    BuildContext context,
    String prefill,
  ) async {
    bool _flag = false;
    final _formKey = GlobalKey<FormState>();
    final _controller = TextEditingController()..text = prefill;

    void _setValues(bool flag) {
      if (_formKey.currentState!.validate()) {
        _flag = flag;
        Navigator.of(context).pop();
      }
    }

    await ZagDialog.dialog(
      context: context,
      title: 'settings.BroadcastAddress'.tr(),
      buttons: [
        ZagDialog.button(
          text: 'zagreus.Set'.tr(),
          onPressed: () => _setValues(true),
        ),
      ],
      content: [
        ZagDialog.textContent(
          text:
              '${ZagUI.TEXT_BULLET} ${'settings.BroadcastAddressHint1'.tr()}',
          textAlign: TextAlign.left,
        ),
        ZagDialog.textContent(
          text:
              '${ZagUI.TEXT_BULLET} ${'settings.BroadcastAddressHint2'.tr()}',
          textAlign: TextAlign.left,
        ),
        ZagDialog.textContent(
          text:
              '${ZagUI.TEXT_BULLET} ${'settings.BroadcastAddressHint3'.tr()}',
          textAlign: TextAlign.left,
        ),
        Form(
          key: _formKey,
          child: ZagDialog.textFormInput(
            controller: _controller,
            validator: (address) {
              if (address?.isEmpty ?? true) return null;
              return IPAddress.validate(address).state
                  ? null
                  : 'settings.BroadcastAddressValidation'.tr();
            },
            onSubmitted: (_) => _setValues(true),
            title: 'settings.BroadcastAddress'.tr(),
          ),
        ),
      ],
      contentPadding: ZagDialog.inputTextDialogContentPadding(),
    );
    return Tuple2(_flag, _controller.text);
  }

  Future<Tuple2<bool, String>> editMACAddress(
    BuildContext context,
    String prefill,
  ) async {
    bool _flag = false;
    final formKey = GlobalKey<FormState>();
    final _controller = TextEditingController()..text = prefill;

    void _setValues(bool flag) {
      if (formKey.currentState!.validate()) {
        _flag = flag;
        Navigator.of(context).pop();
      }
    }

    await ZagDialog.dialog(
      context: context,
      title: 'settings.MACAddress'.tr(),
      buttons: [
        ZagDialog.button(
          text: 'zagreus.Set'.tr(),
          onPressed: () => _setValues(true),
        ),
      ],
      content: [
        ZagDialog.textContent(
          text: '${ZagUI.TEXT_BULLET} ${'settings.MACAddressHint1'.tr()}',
          textAlign: TextAlign.left,
        ),
        ZagDialog.textContent(
          text: '${ZagUI.TEXT_BULLET} ${'settings.MACAddressHint2'.tr()}',
          textAlign: TextAlign.left,
        ),
        ZagDialog.textContent(
          text: '${ZagUI.TEXT_BULLET} ${'settings.MACAddressHint3'.tr()}',
          textAlign: TextAlign.left,
        ),
        ZagDialog.textContent(
          text: '${ZagUI.TEXT_BULLET} ${'settings.MACAddressHint4'.tr()}',
          textAlign: TextAlign.left,
        ),
        Form(
          key: formKey,
          child: ZagDialog.textFormInput(
            controller: _controller,
            validator: (address) {
              if (address?.isEmpty ?? true) return null;
              return MACAddress.validate(address).state
                  ? null
                  : 'settings.MACAddressValidation'.tr();
            },
            onSubmitted: (_) => _setValues(true),
            title: 'settings.MACAddress'.tr(),
          ),
        ),
      ],
      contentPadding: ZagDialog.inputTextDialogContentPadding(),
    );
    return Tuple2(_flag, _controller.text);
  }

  Future<bool> dismissTooltipBanners(BuildContext context) async {
    bool _flag = false;

    void _setValues(bool flag) {
      _flag = flag;
      Navigator.of(context).pop();
    }

    await ZagDialog.dialog(
      context: context,
      title: 'settings.DismissBanners'.tr(),
      buttons: [
        ZagDialog.button(
          text: 'zagreus.Dismiss'.tr(),
          textColor: ZagColours.red,
          onPressed: () => _setValues(true),
        ),
      ],
      content: [
        ZagDialog.textContent(text: 'settings.DismissBannersHint1'.tr()),
        ZagDialog.textContent(text: ''),
        ZagDialog.textContent(text: 'settings.DismissBannersHint2'.tr()),
      ],
      contentPadding: ZagDialog.textDialogContentPadding(),
    );
    return _flag;
  }

  Future<bool> clearImageCache(BuildContext context) async {
    bool _flag = false;

    void _setValues(bool flag) {
      _flag = flag;
      Navigator.of(context).pop();
    }

    await ZagDialog.dialog(
      context: context,
      title: 'settings.ClearImageCache'.tr(),
      buttons: [
        ZagDialog.button(
          text: 'zagreus.Clear'.tr(),
          textColor: ZagColours.red,
          onPressed: () => _setValues(true),
        ),
      ],
      content: [
        ZagDialog.textContent(text: 'settings.ClearImageCacheHint1'.tr()),
        ZagDialog.textContent(text: ''),
        ZagDialog.textContent(text: 'settings.ClearImageCacheHint2'.tr()),
      ],
      contentPadding: ZagDialog.textDialogContentPadding(),
    );
    return _flag;
  }

  Future<bool> clearConfiguration(BuildContext context) async {
    bool _flag = false;

    void _setValues(bool flag) {
      _flag = flag;
      Navigator.of(context).pop();
    }

    await ZagDialog.dialog(
      context: context,
      title: 'settings.ClearConfiguration'.tr(),
      buttons: [
        ZagDialog.button(
          text: 'zagreus.Clear'.tr(),
          textColor: ZagColours.red,
          onPressed: () => _setValues(true),
        ),
      ],
      content: [
        ZagDialog.textContent(text: 'settings.ClearConfigurationHint1'.tr()),
        ZagDialog.textContent(text: ''),
        ZagDialog.textContent(text: 'settings.ClearConfigurationHint2'.tr()),
        ZagDialog.textContent(text: ''),
        ZagDialog.textContent(text: 'settings.ClearConfigurationHint3'.tr()),
      ],
      contentPadding: ZagDialog.textDialogContentPadding(),
    );
    return _flag;
  }

  Future<Tuple2<bool, String>> decryptBackup(BuildContext context) async {
    bool _flag = false;
    bool _obscureText = true;
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
      title: 'settings.DecryptBackup'.tr(),
      buttons: [
        ZagDialog.button(
          text: 'zagreus.Restore'.tr(),
          onPressed: () => _setValues(true),
        ),
      ],
      content: [
        ZagDialog.textContent(text: 'settings.DecryptBackupHint1'.tr()),
        Form(
          key: _formKey,
          child: StatefulBuilder(
            builder: (context, setState) {
              return ZagDialog.textFormInput(
                controller: _textController,
                title: 'settings.EncryptionKey'.tr(),
                obscureText: _obscureText,
                onSubmitted: (_) => _setValues(true),
                validator: (value) => (value?.length ?? 0) < 8
                    ? 'settings.MinimumCharacters'.tr(args: [8.toString()])
                    : null,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                    color: ZagColours.currentAccent,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
      contentPadding: ZagDialog.inputTextDialogContentPadding(),
    );
    return Tuple2(_flag, _textController.text);
  }

  Future<Tuple2<bool, String>> backupConfiguration(BuildContext context) async {
    bool _flag = false;
    bool _obscureText = true;
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
      title: 'settings.BackupConfiguration'.tr(),
      buttons: [
        ZagDialog.button(
          text: 'zagreus.BackUp'.tr(),
          textColor: ZagColours.currentAccentLight,
          onPressed: () => _setValues(true),
        ),
      ],
      content: [
        ZagDialog.textContent(
          text:
              '${ZagUI.TEXT_BULLET} ${'settings.BackupConfigurationHint1'.tr()}',
          textAlign: TextAlign.left,
        ),
        ZagDialog.textContent(
          text:
              '${ZagUI.TEXT_BULLET} ${'settings.BackupConfigurationHint2'.tr()}',
          textAlign: TextAlign.left,
        ),
        Form(
          key: _formKey,
          child: StatefulBuilder(
            builder: (context, setState) {
              return ZagDialog.textFormInput(
                obscureText: _obscureText,
                controller: _textController,
                title: 'settings.EncryptionKey'.tr(),
                validator: (value) => (value?.length ?? 0) < 8
                    ? 'settings.MinimumCharacters'.tr(args: [8.toString()])
                    : null,
                onSubmitted: (_) => _setValues(true),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                    color: ZagColours.currentAccent,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
      contentPadding: ZagDialog.inputTextDialogContentPadding(),
    );
    return Tuple2(_flag, _textController.text);
  }

  Future<Tuple2<bool, ZagSupabaseBackupDocument?>> getBackupFromCloud(
    BuildContext context,
    List<ZagSupabaseBackupDocument> documents,
  ) async {
    bool _flag = false;
    ZagSupabaseBackupDocument? _document;

    void _setValues(bool flag, ZagSupabaseBackupDocument document) {
      _flag = flag;
      _document = document;
      Navigator.of(context).pop();
    }

    await ZagDialog.dialog(
      context: context,
      title: 'settings.RestoreFromCloud'.tr(),
      content: documents.isEmpty
          ? [ZagDialog.textContent(text: 'settings.NoBackupsFound'.tr())]
          : List.generate(
              documents.length,
              (index) => ZagDialog.tile(
                icon: Icons.cloud_download_rounded,
                iconColor: ZagColours().byListIndex(index),
                text: documents[index].title ?? 'Unknown Backup',
                onTap: () => _setValues(true, documents[index]),
              ),
            ),
      contentPadding: documents.isEmpty 
          ? ZagDialog.textDialogContentPadding()
          : ZagDialog.listDialogContentPadding(),
    );
    return Tuple2(_flag, _document);
  }

  Future<Tuple2<bool, int>> changeBackgroundImageOpacity(
    BuildContext context,
  ) async {
    bool _flag = false;
    int _opacity = 0;
    final _formKey = GlobalKey<FormState>();
    final _textController = TextEditingController()
      ..text = ZagreusDatabase.THEME_IMAGE_BACKGROUND_OPACITY.read().toString();

    void _setValues(bool flag) {
      if (_formKey.currentState!.validate()) {
        _opacity = int.parse(_textController.text);
        _flag = flag;
        Navigator.of(context).pop();
      }
    }

    await ZagDialog.dialog(
      context: context,
      title: 'settings.ImageBackgroundOpacity'.tr(),
      buttons: [
        ZagDialog.button(
          text: 'zagreus.Set'.tr(),
          onPressed: () => _setValues(true),
        ),
      ],
      content: [
        ZagDialog.textContent(
          text: 'settings.ImageBackgroundOpacityHint1'.tr(),
        ),
        ZagDialog.textContent(text: ''),
        ZagDialog.textContent(
          text: 'settings.ImageBackgroundOpacityHint2'.tr(),
        ),
        Form(
          key: _formKey,
          child: ZagDialog.textFormInput(
            controller: _textController,
            title: 'settings.ImageBackgroundOpacity'.tr(),
            keyboardType: TextInputType.number,
            onSubmitted: (_) => _setValues(true),
            validator: (value) {
              int? _opacity = int.tryParse(value!);
              if (_opacity == null || _opacity < 0 || _opacity > 100)
                return 'settings.MustBeValueBetween'.tr(args: [
                  0.toString(),
                  100.toString(),
                ]);
              return null;
            },
          ),
        ),
      ],
      contentPadding: ZagDialog.inputTextDialogContentPadding(),
    );
    return Tuple2(_flag, _opacity);
  }

  Future<void> accountHelpMessage(BuildContext context) async {
    await ZagDialog.dialog(
      context: context,
      title: 'settings.AccountHelp'.tr(),
      content: [ZagDialog.textContent(text: 'settings.AccountHelpHint1'.tr())],
      contentPadding: ZagDialog.textDialogContentPadding(),
      cancelButtonText: 'zagreus.Close'.tr(),
    );
  }

  Future<Tuple2<bool, ZagModule?>> selectBootModule() async {
    final context = ZagState.context;
    bool _flag = false;
    ZagModule? _module;

    void _setValues(ZagModule module) {
      _flag = true;
      _module = module;
      Navigator.of(context).pop();
    }

    final modules = ZagModule.values.filter((module) {
      final enabled = module.isEnabled;
      final featureFlag = module.featureFlag;
      final homeRoute = module.homeRoute != null;

      return homeRoute && enabled && featureFlag;
    }).toList();

    await ZagDialog.dialog(
      context: context,
      title: 'settings.BootModule'.tr(),
      content: List.generate(
        modules.length,
        (index) => ZagDialog.tile(
          text: modules[index].title,
          icon: modules[index].icon,
          iconColor: modules[index].color,
          onTap: () => _setValues(modules[index]),
        ),
      ),
      contentPadding: ZagDialog.listDialogContentPadding(),
    );

    return Tuple2(_flag, _module);
  }
}
