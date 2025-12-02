import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/overseerr.dart';
import 'package:zagreus/router/routes/settings.dart';

class ConfigurationOverseerrRoute extends StatefulWidget {
  const ConfigurationOverseerrRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<ConfigurationOverseerrRoute> createState() => _State();
}

class _State extends State<ConfigurationOverseerrRoute>
    with ZagScrollControllerMixin {
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
    final instanceName = ZagProfile.getActiveInstanceName('overseerr');
    final title = instanceName != null
        ? '${ZagModule.OVERSEERR.title} $instanceName'
        : ZagModule.OVERSEERR.title;
    
    final currentProfile = ZagreusDatabase.ENABLED_PROFILE.read();
    final instances = ZagProfile.getInstancesForModule(currentProfile, 'overseerr');
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
    final instances = ZagProfile.getInstancesForModule(currentProfile, 'overseerr');
    final currentInstance = ZagInstanceContext().getActiveInstance('overseerr');
    
    final options = <String?>[null, ...instances];
    
    final result = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Instance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((instanceKey) {
            final isSelected = instanceKey == currentInstance;
            final name = instanceKey == null 
                ? ZagModule.OVERSEERR.title
                : '${ZagModule.OVERSEERR.title} ${ZagProfile.getInstanceDisplayName(instanceKey) ?? ""}';
            return ListTile(
              title: Text(name),
              leading: isSelected 
                  ? Icon(Icons.check, color: ZagModule.OVERSEERR.color)
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
      ZagInstanceContext().setActiveInstance('overseerr', result);
      setState(() {});
    }
  }

  Widget _body() {
    final instanceName = ZagProfile.getActiveInstanceName('overseerr');
    final isInstance = instanceName != null;
    
    return ZagListView(
      controller: scrollController,
      children: [
        ZagModule.OVERSEERR.informationBanner(),
        _enabledToggle(),
        _connectionDetailsPage(),
        ZagDivider(),
        if (isInstance) _deleteInstance() else _addDuplicateInstance(),
      ],
    );
  }

  Widget _enabledToggle() {
    final instanceName = ZagProfile.getActiveInstanceName('overseerr');
    final displayName = instanceName != null
        ? '${ZagModule.OVERSEERR.title} $instanceName'
        : ZagModule.OVERSEERR.title;
    
    return ZagBox.profiles.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: 'settings.EnableModule'.tr(args: [displayName]),
        trailing: ZagSwitch(
          value: ZagProfile.forModule('overseerr').overseerrEnabled,
          onChanged: (value) {
            final profile = ZagProfile.forModule('overseerr');
            profile.overseerrEnabled = value;
            profile.save();
            context.read<OverseerrState>().reset();
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
            args: [ZagModule.OVERSEERR.title],
          ),
        ),
      ],
      trailing: const ZagIconButton.arrow(),
      onTap: SettingsRoutes.CONFIGURATION_OVERSEERR_CONNECTION_DETAILS.go,
    );
  }

  Widget _addDuplicateInstance() {
    return ZagBlock(
      title: 'Add Duplicate Instance',
      body: [
        TextSpan(
          text: 'Create another ${ZagModule.OVERSEERR.title} instance with separate connection details',
        ),
      ],
      trailing: const ZagIconButton(icon: ZagIcons.ADD),
      onTap: () async {
        final controller = TextEditingController();
        final result = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Instance Name'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'e.g., Movies, TV',
              ),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: const Text('Create'),
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
          moduleKey: ZagModule.OVERSEERR.key,
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
          message: '${ZagModule.OVERSEERR.title} $result has been added',
        );

        ZagDrawer.clearModuleOrderCache();
        setState(() {});
      },
    );
  }

  Widget _deleteInstance() {
    final instanceName = ZagProfile.getActiveInstanceName('overseerr');
    final instanceKey = ZagInstanceContext().getActiveInstance('overseerr');
    
    return ZagBlock(
      title: 'Delete Instance',
      body: [
        TextSpan(
          text: 'Remove ${ZagModule.OVERSEERR.title} $instanceName and its settings',
        ),
      ],
      trailing: const ZagIconButton(icon: ZagIcons.DELETE),
      onTap: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Instance?'),
            content: Text(
              'Are you sure you want to delete ${ZagModule.OVERSEERR.title} $instanceName? This cannot be undone.',
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
        ZagInstanceContext().clearActiveInstance('overseerr');
        ZagDrawer.clearModuleOrderCache();
        
        showZagSuccessSnackBar(
          title: 'Instance Deleted',
          message: '${ZagModule.OVERSEERR.title} $instanceName has been removed',
        );

        if (mounted) {
          Navigator.of(context).pop();
        }
      },
    );
  }
}
