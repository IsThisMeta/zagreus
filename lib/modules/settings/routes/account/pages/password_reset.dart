import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/supabase/auth.dart';
import 'package:zagreus/utils/validator.dart';

class AccountPasswordResetRoute extends StatefulWidget {
  const AccountPasswordResetRoute({
    Key? key,
  }) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<AccountPasswordResetRoute>
    with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar() as PreferredSizeWidget?,
      body: _body(),
      bottomNavigationBar: _bottomActionBar(),
    );
  }

  Widget _appBar() {
    return ZagAppBar(
      title: 'settings.ResetPassword'.tr(),
      scrollControllers: [scrollController],
    );
  }

  Widget _bottomActionBar() {
    return ZagBottomActionBar(
      actions: [
        ZagButton.text(
          text: 'settings.ResetPassword'.tr(),
          icon: Icons.vpn_key_rounded,
          onTap: _resetPassword,
        ),
      ],
    );
  }

  Widget _body() {
    return ZagListView(
      controller: scrollController,
      children: [
        AutofillGroup(
          child: ZagCard(
            context: context,
            child: Column(
              children: [
                ZagTextInputBar(
                  controller: _emailController,
                  isFormField: true,
                  margin: const EdgeInsets.all(12.0),
                  labelIcon: Icons.person_rounded,
                  labelText: 'settings.Email'.tr(),
                  action: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [
                    AutofillHints.username,
                    AutofillHints.email,
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _resetPassword() async {
    if (_validateEmailAddress()) {
      ZagSupabaseAuth()
          .resetPassword(_emailController.text)
          .then((_) => showZagSuccessSnackBar(
                title: 'settings.EmailSentSuccess'.tr(),
                message: 'settings.EmailSentSuccessMessage'.tr(),
              ))
          .catchError((error, stack) {
        ZagLogger().error(
          'Failed to reset password: ${_emailController.text}',
          error,
          stack,
        );
        showZagErrorSnackBar(
          title: 'settings.EmailSentFailure'.tr(),
          error: error,
        );
      });
    }
  }

  bool _validateEmailAddress({bool showSnackBarOnFailure = true}) {
    if (!ZagValidator().email(_emailController.text)) {
      if (showSnackBarOnFailure) {
        showZagErrorSnackBar(
          title: 'settings.InvalidEmail'.tr(),
          message: 'settings.InvalidEmailMessage'.tr(),
        );
      }
      return false;
    }
    return true;
  }
}
