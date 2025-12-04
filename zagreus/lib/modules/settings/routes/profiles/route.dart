import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/settings.dart';
import 'package:zagreus/utils/profile_tools.dart';

class ProfilesRoute extends StatefulWidget {
  const ProfilesRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<ProfilesRoute> createState() => _State();
}

class _State extends State<ProfilesRoute> with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar() as PreferredSizeWidget?,
      body: _body(),
    );
  }

  Widget _appBar() {
    return ZagAppBar(
      title: 'settings.Profiles'.tr(),
      scrollControllers: [scrollController],
    );
  }

  Widget _body() {
    return ZagListView(
      controller: scrollController,
      children: [
        SettingsBanners.PROFILES_SUPPORT.banner(),
        _enabledProfile(),
        _addProfile(),
        _renameProfile(),
        _deleteProfile(),
        ZagDivider(),
        _migrateToMultiInstance(),
      ],
    );
  }

  Widget _migrateToMultiInstance() {
    return ZagBlock(
      title: 'Migrate to Multi-Instance',
      body: [
        const TextSpan(
          text:
              'Convert all profiles into a single profile with multiple instances per module. This combines all your setups into one unified profile.',
        ),
      ],
      trailing: const ZagIconButton(icon: ZagIcons.ARROW_RIGHT),
      onTap: () async {
        final profiles = ZagProfile.visibleList;
        if (profiles.length <= 1) {
          showZagInfoSnackBar(
            title: 'Nothing to Migrate',
            message: 'You only have one profile. Add more profiles first.',
          );
          return;
        }

        bool confirmed = false;
        await ZagDialog.dialog(
          context: context,
          title: 'Migrate Profiles',
          buttons: [
            ZagDialog.button(
              text: 'Migrate',
              textColor: ZagColours.currentAccent,
              onPressed: () {
                confirmed = true;
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
          ],
          content: [
            Text(
              'This will merge all ${profiles.length} profiles into one profile with multi-instance support.\n\n'
              'Each enabled module from each profile will become a separate instance.\n\n'
              'This cannot be undone. Continue?',
              style: TextStyle(color: Colors.white70),
            ),
          ],
          contentPadding: ZagDialog.textDialogContentPadding(),
        );

        if (confirmed) {
          await ZagProfile.migrateToMultiInstance(targetProfileName: 'default');
          showZagSuccessSnackBar(
            title: 'Migration Complete',
            message: 'All profiles merged into multi-instance setup.',
          );
          setState(() {});
        }
      },
    );
  }

  Widget _addProfile() {
    return ZagBlock(
      title: 'settings.AddProfile'.tr(),
      body: [TextSpan(text: 'settings.AddProfileDescription'.tr())],
      trailing: const ZagIconButton(icon: ZagIcons.ADD),
      onTap: () async {
        final dialogs = SettingsDialogs();
        final context = ZagState.context;
        final profiles = ZagProfile.visibleList;

        final selected = await dialogs.addProfile(context, profiles);
        if (selected.item1) {
          ZagProfileTools().create(selected.item2);
        }
      },
    );
  }

  Widget _renameProfile() {
    return ZagBlock(
      title: 'settings.RenameProfile'.tr(),
      body: [TextSpan(text: 'settings.RenameProfileDescription'.tr())],
      trailing: const ZagIconButton(icon: ZagIcons.RENAME),
      onTap: () async {
        final dialogs = SettingsDialogs();
        final context = ZagState.context;
        final profiles = ZagProfile.visibleList;

        final selected = await dialogs.renameProfile(context, profiles);
        if (selected.item1) {
          final name = await dialogs.renameProfileSelected(context, profiles);
          if (name.item1) {
            ZagProfileTools().rename(selected.item2, name.item2);
          }
        }
      },
    );
  }

  Widget _deleteProfile() {
    return ZagBlock(
        title: 'settings.DeleteProfile'.tr(),
        body: [TextSpan(text: 'settings.DeleteProfileDescription'.tr())],
        trailing: const ZagIconButton(icon: ZagIcons.DELETE),
        onTap: () async {
          final dialogs = SettingsDialogs();
          final enabledProfile = ZagreusDatabase.ENABLED_PROFILE.read();
          final context = ZagState.context;
          final profiles = ZagProfile.visibleList;
          profiles.removeWhere((p) => p == enabledProfile);

          if (profiles.isEmpty) {
            showZagInfoSnackBar(
              title: 'settings.NoProfilesFound'.tr(),
              message: 'settings.NoAdditionalProfilesAdded'.tr(),
            );
            return;
          }

          final selected = await dialogs.deleteProfile(context, profiles);
          if (selected.item1) {
            ZagProfileTools().remove(selected.item2);
          }
        });
  }

  Widget _enabledProfile() {
    const db = ZagreusDatabase.ENABLED_PROFILE;
    return db.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: 'settings.EnabledProfile'.tr(),
        body: [TextSpan(text: db.read())],
        trailing: const ZagIconButton(icon: ZagIcons.USER),
        onTap: () async {
          final dialogs = SettingsDialogs();
          final enabledProfile = ZagreusDatabase.ENABLED_PROFILE.read();
          final context = ZagState.context;
          final profiles = ZagProfile.visibleList;
          profiles.removeWhere((p) => p == enabledProfile);

          if (profiles.isEmpty) {
            showZagInfoSnackBar(
              title: 'settings.NoProfilesFound'.tr(),
              message: 'settings.NoAdditionalProfilesAdded'.tr(),
            );
            return;
          }

          final selected = await dialogs.enabledProfile(context, profiles);
          if (selected.item1) {
            ZagProfileTools().changeTo(selected.item2);
          }
        },
      ),
    );
  }
}
