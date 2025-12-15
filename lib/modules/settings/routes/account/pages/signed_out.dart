import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/supabase/auth.dart';
import 'package:zagreus/router/routes/settings.dart';
import 'package:zagreus/utils/validator.dart';

class SettingsAccountSignedOutPage extends StatefulWidget {
  final ScrollController scrollController;

  const SettingsAccountSignedOutPage({
    Key? key,
    required this.scrollController,
  }) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<SettingsAccountSignedOutPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  ZagLoadingState _state = ZagLoadingState.INACTIVE;

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      body: _body(),
      bottomNavigationBar: _bottomActionBar(),
    );
  }

  Widget _bottomActionBar() {
    return ZagBottomActionBar(
      actions: [
        ZagButton(
          type: ZagButtonType.TEXT,
          text: 'settings.Register'.tr(),
          icon: Icons.app_registration_rounded,
          onTap: _register,
          loadingState: _state,
        ),
        ZagButton(
          type: ZagButtonType.TEXT,
          text: 'settings.SignIn'.tr(),
          icon: Icons.login_rounded,
          onTap: _signIn,
          loadingState: _state,
        ),
      ],
    );
  }

  Widget _body() {
    return ZagListView(
      controller: widget.scrollController,
      children: [
        Padding(
          child: Center(
            child: Image.asset(
              ZagAssets.brandingFull,
              width: 200.0,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16.0),
        ),
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
                    AutofillHints.email
                  ],
                ),
                ZagTextInputBar(
                  controller: _passwordController,
                  isFormField: true,
                  margin: const EdgeInsets.only(
                      bottom: 12.0, left: 12.0, right: 12.0),
                  labelIcon: Icons.vpn_key_rounded,
                  labelText: 'settings.Password'.tr(),
                  obscureText: true,
                  keyboardType: TextInputType.text,
                  autofillHints: const [
                    AutofillHints.password,
                    AutofillHints.newPassword
                  ],
                  action: TextInputAction.done,
                ),
              ],
            ),
          ),
        ),
        Padding(
          child: Center(
            child: InkWell(
              child: Text(
                'settings.ForgotYourPassword'.tr(),
                style: TextStyle(
                  color: ZagColours.currentAccent,
                  fontWeight: ZagUI.FONT_WEIGHT_BOLD,
                  fontSize: ZagUI.FONT_SIZE_H3,
                ),
                textAlign: TextAlign.center,
              ),
              onTap: SettingsRoutes.ACCOUNT_PASSWORD_RESET.go,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8.0),
        )
      ],
    );
  }

  bool _validateEmailAddress({bool showSnackBarOnFailure = true}) {
    if (!ZagValidator().email(_emailController.text)) {
      if (showSnackBarOnFailure)
        showZagErrorSnackBar(
          title: 'settings.InvalidEmail'.tr(),
          message: 'settings.InvalidEmailMessage'.tr(),
        );
      return false;
    }
    return true;
  }

  bool _validatePassword({bool showSnackBarOnFailure = true}) {
    if (_passwordController.text.isEmpty) {
      if (showSnackBarOnFailure)
        showZagErrorSnackBar(
          title: 'settings.InvalidPassword'.tr(),
          message: 'settings.InvalidPasswordMessage'.tr(),
        );
      return false;
    }
    return true;
  }

  Future<void> _register() async {
    if (!_validateEmailAddress() || !_validatePassword()) return;
    if (mounted) setState(() => _state = ZagLoadingState.ACTIVE);
    await ZagSupabaseAuth()
        .registerUser(_emailController.text, _passwordController.text)
        .then((response) {
      if (mounted) setState(() => _state = ZagLoadingState.INACTIVE);
      if (response.state) {
        showZagSuccessSnackBar(
          title: 'settings.RegisteredSuccess'.tr(),
          message: response.authResponse!.user!.email,
        );
      } else {
        showZagErrorSnackBar(
          title: 'settings.RegisteredFailure'.tr(),
          message: response.error?.message ?? 'zagreus.UnknownError'.tr(),
        );
      }
    }).catchError((error, stack) {
      if (mounted) setState(() => _state = ZagLoadingState.INACTIVE);
      showZagErrorSnackBar(
        title: 'settings.RegisteredFailure'.tr(),
        error: error,
      );
    });
  }

  Future<void> _signIn() async {
    if (!_validateEmailAddress() || !_validatePassword()) return;
    if (mounted) setState(() => _state = ZagLoadingState.ACTIVE);
    await ZagSupabaseAuth()
        .signInUser(_emailController.text, _passwordController.text)
        .then((response) {
      if (mounted) setState(() => _state = ZagLoadingState.INACTIVE);
      if (response.state) {
        showZagSuccessSnackBar(
          title: 'settings.SignedInSuccess'.tr(),
          message: response.authResponse!.user!.email,
        );
      } else {
        showZagErrorSnackBar(
          title: 'settings.SignedInFailure'.tr(),
          message: response.error?.message ?? 'zagreus.UnknownError'.tr(),
        );
      }
    }).catchError((error, stack) {
      if (mounted) setState(() => _state = ZagLoadingState.INACTIVE);
      showZagErrorSnackBar(
        title: 'settings.SignedInFailure'.tr(),
        error: error,
      );
    });
  }
}
