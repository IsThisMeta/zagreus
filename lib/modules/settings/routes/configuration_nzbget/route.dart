import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/nzbget.dart';
import 'package:zagreus/router/routes/settings.dart';
import 'package:zagreus/utils/zagreus_pro.dart';

class ConfigurationNZBGetRoute extends StatefulWidget {
  const ConfigurationNZBGetRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<ConfigurationNZBGetRoute> createState() => _State();
}

class _State extends State<ConfigurationNZBGetRoute>
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
    final instanceName = ZagProfile.getActiveInstanceName('nzbget');
    final title = instanceName != null
        ? '${ZagModule.NZBGET.title} $instanceName'
        : ZagModule.NZBGET.title;
    
    final currentProfile = ZagreusDatabase.ENABLED_PROFILE.read();
    final instances = ZagProfile.getInstancesForModule(currentProfile, 'nzbget');
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
    final instances = ZagProfile.getInstancesForModule(currentProfile, 'nzbget');
    final currentInstance = ZagInstanceContext().getActiveInstance('nzbget');
    
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
                ? ZagModule.NZBGET.title
                : '${ZagModule.NZBGET.title} ${ZagProfile.getInstanceDisplayName(instanceKey) ?? ""}';
            return ListTile(
              title: Text(name, style: TextStyle(color: ZagColours.textColor(ctx))),
              leading: isSelected 
                  ? Icon(Icons.check, color: ZagModule.NZBGET.color)
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
      ZagInstanceContext().setActiveInstance('nzbget', result);
      setState(() {});
    }
  }

  Widget _body() {
    final instanceName = ZagProfile.getActiveInstanceName('nzbget');
    final isInstance = instanceName != null;
    final isPro = ZagreusPro.isEnabled;
    
    return ZagListView(
      controller: scrollController,
      children: [
        ZagModule.NZBGET.informationBanner(),
        _enabledToggle(),
        _connectionDetailsPage(),
        ZagDivider(),
        _defaultPagesPage(),
        ZagDivider(),
        if (isInstance) ...[
          _renameInstance(),
          _deleteInstance(),
        ] else if (isPro) _addDuplicateInstance(),
      ],
    );
  }

  Widget _enabledToggle() {
    final instanceName = ZagProfile.getActiveInstanceName('nzbget');
    final displayName = instanceName != null
        ? '${ZagModule.NZBGET.title} $instanceName'
        : ZagModule.NZBGET.title;
    
    return ZagBox.profiles.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: 'settings.EnableModule'.tr(args: [displayName]),
        trailing: ZagSwitch(
          value: ZagProfile.forModule('nzbget').nzbgetEnabled,
          onChanged: (value) {
            final profile = ZagProfile.forModule('nzbget');
            profile.nzbgetEnabled = value;
            profile.save();
            context.read<NZBGetState>().reset();
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
          text: 'settings.ConnectionDetailsDescription'
              .tr(args: [ZagModule.NZBGET.title]),
        ),
      ],
      trailing: const ZagIconButton.arrow(),
      onTap: SettingsRoutes.CONFIGURATION_NZBGET_CONNECTION_DETAILS.go,
    );
  }

  Widget _defaultPagesPage() {
    return ZagBlock(
      title: 'settings.DefaultPages'.tr(),
      body: [TextSpan(text: 'settings.DefaultPagesDescription'.tr())],
      trailing: const ZagIconButton.arrow(),
      onTap: SettingsRoutes.CONFIGURATION_NZBGET_DEFAULT_PAGES.go,
    );
  }

  Widget _addDuplicateInstance() {
    return ZagBlock(
      title: 'Add Duplicate Instance',
      body: [
        TextSpan(
          text: 'Create another ${ZagModule.NZBGET.title} instance',
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
          moduleKey: ZagModule.NZBGET.key,
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
          message: '${ZagModule.NZBGET.title} $result has been added',
        );

        ZagDrawer.clearModuleOrderCache();
        setState(() {});
      },
    );
  }

  Widget _renameInstance() {
    final instanceName = ZagProfile.getActiveInstanceName('nzbget');
    final instanceKey = ZagInstanceContext().getActiveInstance('nzbget');
    
    return ZagBlock(
      title: 'Rename Instance',
      body: [
        TextSpan(
          text: 'Change the name of ${ZagModule.NZBGET.title} $instanceName',
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
        ZagInstanceContext().setActiveInstance('nzbget', newKey);
        
        // Refresh drawer
        ZagDrawer.clearModuleOrderCache();
        
        showZagSuccessSnackBar(
          title: 'Instance Renamed',
          message: '${ZagModule.NZBGET.title} is now "$newName"',
        );

        setState(() {});
      },
    );
  }

  Widget _deleteInstance() {
    final instanceName = ZagProfile.getActiveInstanceName('nzbget');
    final instanceKey = ZagInstanceContext().getActiveInstance('nzbget');
    
    return ZagBlock(
      title: 'Delete Instance',
      body: [
        TextSpan(
          text: 'Remove ${ZagModule.NZBGET.title} $instanceName and its settings',
        ),
      ],
      trailing: const ZagIconButton(icon: ZagIcons.DELETE),
      onTap: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Delete Instance?', style: TextStyle(color: ZagColours.textColor(context))),
            content: Text(
              'Are you sure you want to delete ${ZagModule.NZBGET.title} $instanceName? This cannot be undone.',
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
        ZagInstanceContext().clearActiveInstance('nzbget');
        ZagDrawer.clearModuleOrderCache();
        
        showZagSuccessSnackBar(
          title: 'Instance Deleted',
          message: '${ZagModule.NZBGET.title} $instanceName has been removed',
        );

        if (mounted) {
          Navigator.of(context).pop();
        }
      },
    );
  }
}
