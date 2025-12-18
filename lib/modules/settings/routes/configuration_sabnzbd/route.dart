import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/sabnzbd.dart';
import 'package:zagreus/router/routes/settings.dart';

class ConfigurationSABnzbdRoute extends StatefulWidget {
  const ConfigurationSABnzbdRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<ConfigurationSABnzbdRoute> createState() => _State();
}

class _State extends State<ConfigurationSABnzbdRoute>
    with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar(),
      body: _body(),
    );
  }

  PreferredSizeWidget _appBar() {
    final instanceName = ZagProfile.getActiveInstanceName('sabnzbd');
    final title = instanceName != null
        ? '${ZagModule.SABNZBD.title} $instanceName'
        : ZagModule.SABNZBD.title;
    
    final currentProfile = ZagreusDatabase.ENABLED_PROFILE.read();
    final instances = ZagProfile.getInstancesForModule(currentProfile, 'sabnzbd');
    final hasInstances = instances.isNotEmpty;
    
    return ZagAppBar(
      title: title,
      scrollControllers: [scrollController],
      actions: [
        if (hasInstances)
          ZagIconButton(
            icon: Icons.swap_horiz_rounded,
            onPressed: _showInstanceSelector,
          ),
      ],
    );
  }

  void _showInstanceSelector() async {
    final currentProfile = ZagreusDatabase.ENABLED_PROFILE.read();
    final instances = ZagProfile.getInstancesForModule(currentProfile, 'sabnzbd');
    final currentInstance = ZagInstanceContext().getActiveInstance('sabnzbd');
    
    final options = <String?>[null, ...instances];
    
    final result = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Select Instance', style: TextStyle(color: ZagColours.textColor(ctx))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((instanceKey) {
            final isSelected = instanceKey == currentInstance;
            final name = instanceKey == null 
                ? ZagModule.SABNZBD.title
                : '${ZagModule.SABNZBD.title} ${ZagProfile.getInstanceDisplayName(instanceKey) ?? ""}';
            return ListTile(
              title: Text(name, style: TextStyle(color: ZagColours.textColor(ctx))),
              leading: isSelected 
                  ? Icon(Icons.check, color: ZagModule.SABNZBD.color)
                  : const SizedBox(width: 24),
              onTap: () => Navigator.pop(ctx, instanceKey),
            );
          }).toList(),
        ),
      ),
    );
    
    if (!mounted) return;
    
    final didSelect = result != null || (result == null && currentInstance != null);
    if (didSelect && result != currentInstance) {
      ZagInstanceContext().setActiveInstance('sabnzbd', result);
      setState(() {});
    }
  }

  Widget _body() {
    final instanceName = ZagProfile.getActiveInstanceName('sabnzbd');
    final isInstance = instanceName != null;
    
    return ZagListView(
      controller: scrollController,
      children: [
        ZagModule.SABNZBD.informationBanner(),
        _enabledToggle(),
        _connectionDetailsPage(),
        ZagDivider(),
        _defaultPagesPage(),
        ZagDivider(),
        if (isInstance) ...[
          _renameInstance(),
          _deleteInstance(),
        ] else _addDuplicateInstance(),
      ],
    );
  }

  Widget _enabledToggle() {
    final instanceName = ZagProfile.getActiveInstanceName('sabnzbd');
    final displayName = instanceName != null
        ? '${ZagModule.SABNZBD.title} $instanceName'
        : ZagModule.SABNZBD.title;
    
    return ZagBox.profiles.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: 'settings.EnableModule'.tr(args: [displayName]),
        trailing: ZagSwitch(
          value: ZagProfile.forModule('sabnzbd').sabnzbdEnabled,
          onChanged: (value) {
            final profile = ZagProfile.forModule('sabnzbd');
            profile.sabnzbdEnabled = value;
            profile.save();
            context.read<SABnzbdState>().reset();
          },
        ),
      ),
    );
  }

  Widget _connectionDetailsPage() {
    return ZagBlock(
      title: 'settings.ConnectionDetails'.tr(),
      body: [
        TextSpan(
          text: 'settings.ConnectionDetailsDescription'.tr(
            args: [ZagModule.SABNZBD.title],
          ),
        )
      ],
      trailing: const ZagIconButton.arrow(),
      onTap: SettingsRoutes.CONFIGURATION_SABNZBD_CONNECTION_DETAILS.go,
    );
  }

  Widget _defaultPagesPage() {
    return ZagBlock(
      title: 'settings.DefaultPages'.tr(),
      body: [TextSpan(text: 'settings.DefaultPagesDescription'.tr())],
      trailing: const ZagIconButton.arrow(),
      onTap: SettingsRoutes.CONFIGURATION_SABNZBD_DEFAULT_PAGES.go,
    );
  }

  Widget _addDuplicateInstance() {
    return ZagBlock(
      title: 'Add Duplicate Instance',
      body: [
        TextSpan(
          text: 'Create another ${ZagModule.SABNZBD.title} instance',
        ),
      ],
      trailing: const ZagIconButton(icon: ZagIcons.ADD),
      onTap: () async {
        final controller = TextEditingController();
        final result = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Instance Name', style: TextStyle(color: ZagColours.textColor(context))),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'e.g., Primary, Secondary',
                hintStyle: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: ZagColours.currentAccent),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: ZagColours.currentAccent.withOpacity(ZagUI.OPACITY_SPLASH),
                  ),
                ),
              ),
              autofocus: true,
              cursorColor: ZagColours.currentAccent,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            actions: [
              ZagDialog.cancel(context),
              ZagDialog.button(
                text: 'Create',
                onPressed: () => Navigator.pop(context, controller.text),
              ),
            ],
          ),
        );

        if (result == null || result.isEmpty) return;

        if (result.contains('_')) {
          showZagErrorSnackBar(
            title: 'Invalid Name',
            message: 'Instance names cannot contain underscores',
          );
          return;
        }

        final currentProfile = ZagreusDatabase.ENABLED_PROFILE.read();
        final shadowKey = await ZagProfile.createInstance(
          moduleKey: ZagModule.SABNZBD.key,
          instanceName: result,
          parentProfile: currentProfile,
        );

        if (shadowKey == null) {
          showZagErrorSnackBar(
            title: 'Failed to Create Instance',
            message: 'An instance with that name may already exist',
          );
          return;
        }

        showZagSuccessSnackBar(
          title: 'Instance Created',
          message: '${ZagModule.SABNZBD.title} $result has been added',
        );

        ZagDrawer.clearModuleOrderCache();
        setState(() {});
      },
    );
  }

  Widget _renameInstance() {
    final instanceName = ZagProfile.getActiveInstanceName('sabnzbd');
    final instanceKey = ZagInstanceContext().getActiveInstance('sabnzbd');
    
    return ZagBlock(
      title: 'Rename Instance',
      body: [
        TextSpan(
          text: 'Change the name of ${ZagModule.SABNZBD.title} $instanceName',
        ),
      ],
      trailing: const ZagIconButton(icon: Icons.edit_rounded),
      onTap: () async {
        final controller = TextEditingController(text: instanceName);
        
        final newName = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Rename Instance', style: TextStyle(color: ZagColours.textColor(context))),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Instance Name',
                hintText: 'e.g. Primary, Secondary',
              ),
              onSubmitted: (value) => Navigator.pop(context, value),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: const Text('Rename'),
              ),
            ],
          ),
        );

        if (newName == null || newName.trim().isEmpty || instanceKey == null) return;
        
        if (newName.contains('_')) {
          showZagErrorSnackBar(
            title: 'Invalid Name',
            message: 'Instance names cannot contain underscores',
          );
          return;
        }

        final newKey = await ZagProfile.renameInstance(instanceKey, newName);
        if (newKey == null) {
          showZagErrorSnackBar(
            title: 'Rename Failed',
            message: 'Could not rename the instance',
          );
          return;
        }
        
        // Update active instance to new key
        ZagInstanceContext().setActiveInstance('sabnzbd', newKey);
        
        // Refresh drawer
        ZagDrawer.clearModuleOrderCache();
        
        showZagSuccessSnackBar(
          title: 'Instance Renamed',
          message: '${ZagModule.SABNZBD.title} is now "$newName"',
        );

        setState(() {});
      },
    );
  }

  Widget _deleteInstance() {
    final instanceName = ZagProfile.getActiveInstanceName('sabnzbd');
    final instanceKey = ZagInstanceContext().getActiveInstance('sabnzbd');
    
    return ZagBlock(
      title: 'Delete Instance',
      body: [
        TextSpan(
          text: 'Remove ${ZagModule.SABNZBD.title} $instanceName and its settings',
        ),
      ],
      trailing: const ZagIconButton(icon: ZagIcons.DELETE),
      onTap: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Delete Instance?', style: TextStyle(color: ZagColours.textColor(context))),
            content: Text(
              'Are you sure you want to delete ${ZagModule.SABNZBD.title} $instanceName? This cannot be undone.',
              style: TextStyle(color: ZagColours.textColor(context)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );

        if (confirm != true || instanceKey == null) return;

        await ZagProfile.deleteInstance(instanceKey);
        ZagInstanceContext().clearActiveInstance('sabnzbd');
        ZagDrawer.clearModuleOrderCache();
        
        showZagSuccessSnackBar(
          title: 'Instance Deleted',
          message: '${ZagModule.SABNZBD.title} $instanceName has been removed',
        );

        if (mounted) {
          Navigator.of(context).pop();
        }
      },
    );
  }
}
